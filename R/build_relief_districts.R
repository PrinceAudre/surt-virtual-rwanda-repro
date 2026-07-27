#!/usr/bin/env Rscript
# ---------------------------------------------------------------------------------------
# build_relief_districts.R  -  Derive the per-district population choropleth GeoJSON that
# drapes over the experimental MapLibre 3D relief. Offline data-prep tool; NOT sourced by app.R.
#
# SUPERVISED BUILD (owner-authorized). The in-app per-district choropleth was deferred by the
# Phase 4B record to a supervised session BECAUSE the 2D version would extend the PROTECTED
# population overlay adapter (tools/semantic_layers/R/unified_workspace_adapters.R). This tool
# does NOT touch that adapter or its contract: it is a SEPARATE data path feeding only the new
# experimental 3D relief module. Descriptive, aggregate (district-level), non-operational.
#
# INPUTS (both owner-populated / git-ignored - "geometry stays local, fail-closed to Unavailable"):
#   - GEOMETRY: World Bank "Rwanda Admin Boundaries and Villages" District.shp (30 districts,
#     fields Dist_ID/District, CC BY 4.0). Default: 02_data/manual_inputs/rwanda_districts_wb/District.shp
#     (override with arg 1). Reprojected to EPSG:4326.
#   - VALUES: the 30 COMMITTED rounded per-district estimates parsed straight from the single
#     source of truth docs/phase4b_population_exposure/PHASE_4B_OPTION_B_PER_DISTRICT_RESULTS.md
#     (no transcription here). Modelled prototype estimate of population potentially exposed
#     (WorldPop R2025A v1, ODbL) - NOT a census count, NOT official, NOT operational.
#
# OUTPUT (git-ignored, regenerable, served same-origin by Shiny):
#   05_dashboard/www/relief_districts.geojson  (30 features; property: district, population)
#
# FAIL-CLOSED: hard-stops if the shapefile is absent, if fewer/more than 30 values parse, or if
# ANY of the 30 districts fails to match a geometry feature (a silent drop would leave holes /
# mis-joined values in the choropleth). No partial GeoJSON is ever written.
#
# USAGE:  Rscript tools/semantic_layers/experimental_maplibre_relief/build_relief_districts.R [shp_path] [out_geojson]
#         Requires: terra.
# ---------------------------------------------------------------------------------------
suppressWarnings(suppressMessages({ library(terra) }))
args   <- commandArgs(trailingOnly = TRUE)
SHP    <- if (length(args) >= 1 && nzchar(args[1])) args[1] else file.path("02_data", "manual_inputs", "rwanda_districts_wb", "District.shp")
OUT    <- if (length(args) >= 2 && nzchar(args[2])) args[2] else file.path("05_dashboard", "www", "relief_districts.geojson")
MD     <- file.path("docs", "phase4b_population_exposure", "PHASE_4B_OPTION_B_PER_DISTRICT_RESULTS.md")
TOL    <- 0.002   # simplify tolerance in degrees (~200 m) - national-scale relief view

# 1. Parse the 30 committed values from the results table ONLY (slice between its header and the
#    next "## " so no other "Word | number" text can leak in). Single source of truth.
if (!file.exists(MD)) stop(sprintf("FAIL-CLOSED: committed values doc not found: %s", MD))
md   <- readLines(MD, warn = FALSE)
h    <- grep("^##\\s+Per-district result", md)
if (length(h) != 1) stop("FAIL-CLOSED: could not locate the 'Per-district result' table section in the doc.")
nxt  <- grep("^##\\s", md); nxt <- nxt[nxt > h][1]
body <- md[(h + 1):(if (is.na(nxt)) length(md) else nxt - 1)]
rx   <- "([A-Z][a-z]+)[ ]*\\|[ ]*([0-9][0-9,]+)"
hits <- unlist(regmatches(body, gregexpr(rx, body)))
if (length(hits) == 0) stop("FAIL-CLOSED: no 'District | value' pairs parsed from the results table.")
nm   <- sub(rx, "\\1", hits)
val  <- as.numeric(gsub(",", "", sub(rx, "\\2", hits)))
pop  <- data.frame(district = nm, population = val, stringsAsFactors = FALSE)
pop  <- pop[!duplicated(pop$district), ]
if (nrow(pop) != 30) stop(sprintf("FAIL-CLOSED: parsed %d districts, expected 30. Parsed: %s",
                                   nrow(pop), paste(pop$district, collapse = ", ")))
tot  <- sum(pop$population)
if (!(tot > 14e6 && tot < 15e6)) stop(sprintf("FAIL-CLOSED: parsed population sum %s is outside the expected ~14.7M national range; parse likely wrong.", format(tot, big.mark = ",")))
cat(sprintf("parsed 30 committed per-district values; sum = %s (range %s - %s)\n",
            format(tot, big.mark = ","), format(min(pop$population), big.mark = ","), format(max(pop$population), big.mark = ",")))

# 2. Load + reproject + simplify the district geometry (owner-populated, git-ignored).
if (!file.exists(SHP)) {
  stop(sprintf(paste0("FAIL-CLOSED: district shapefile not found at:\n  %s\n",
                      "This is the owner-populated World Bank 'Rwanda Admin Boundaries and Villages' ",
                      "District.shp (CC BY 4.0), kept out of Git. Drop District.shp/.shx/.dbf/.prj there ",
                      "(or pass its path as arg 1) and re-run. No GeoJSON written."), SHP))
}
v <- vect(SHP)
if (!("District" %in% names(v))) stop(sprintf("FAIL-CLOSED: shapefile lacks a 'District' field; has: %s", paste(names(v), collapse = ", ")))
v <- project(v, "EPSG:4326")
v <- simplifyGeom(v, tolerance = TOL)
nvert <- nrow(crds(v))
cat(sprintf("geometry: %d features, %d vertices after simplify (tol %.4f deg)\n", nrow(v), nvert, TOL))
if (nvert > 20000) cat(sprintf("NOTE: %d vertices exceeds the 20k soft budget; raise TOL if the file is heavy.\n", nvert))

# 3. Join population by district name - FAIL-CLOSED on any of the 30 not matching a geometry feature.
gdist   <- as.character(v$District)
missing <- setdiff(pop$district, gdist)
if (length(missing) > 0) {
  stop(sprintf(paste0("FAIL-CLOSED: %d value district(s) have NO matching geometry feature (name mismatch ",
                      "would drop/mis-join choropleth values): %s\nGeometry districts: %s"),
               length(missing), paste(missing, collapse = ", "), paste(sort(gdist), collapse = ", ")))
}
v$population <- pop$population[match(gdist, pop$district)]
if (any(is.na(v$population))) stop("FAIL-CLOSED: some geometry features got no population value after the join.")

# 4. Keep only the two properties the drape needs; write the git-ignored GeoJSON.
v <- v[, c("District", "population")]
names(v)[names(v) == "District"] <- "district"
dir.create(dirname(OUT), recursive = TRUE, showWarnings = FALSE)
if (file.exists(OUT)) file.remove(OUT)
writeVector(v, OUT, filetype = "GeoJSON")
cat(sprintf("wrote %d-district population choropleth GeoJSON -> %s (%s)\n",
            nrow(v), OUT, format(structure(file.info(OUT)$size, class = "object_size"), units = "auto")))
