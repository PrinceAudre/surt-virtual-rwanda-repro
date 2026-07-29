#!/usr/bin/env Rscript
# Build a district-level annual-rainfall GeoJSON from CHIRPS as an explicit
# offline preparation step. This is a single-year descriptive layer, not a
# climatological normal, forecast, surveillance output, or operational output.
#
# DATA: CHIRPS v2.0 annual rainfall (UCSB Climate Hazards Center). LICENSE: PUBLIC DOMAIN / CC0 (Peterson/CHC
# waived copyright. 0.05deg (~5.5km) provides multiple cells per district and
# supports a coverage-fraction-weighted district mean (unlike NASA POWER's 0.5deg,
# which cannot differentiate districts). Courtesy citation: Funk et al. 2015, Sci Data 2:150066.
#
# OFFLINE FETCH + CACHE: the global annual GeoTIFF (~57MB) is downloaded once into cache/chirps/
# (git-ignored) and reused; re-fetched only if absent. So this is a heavy one-time prepare, cheap thereafter.
# Single recent YEAR by default (honest: "annual rainfall <year>", a real observation, not a multi-year normal);
# extend to a multi-year mean later. CONSISTENCY GATE (fail closed): Rwanda's western/highland districts must be
# WETTER than the eastern (Akagera) districts, and every value in a sane 300-3000 mm band - catches a units/
# aggregation/CRS bug that a structural check would miss.
#
# GOVERNANCE: aggregate per-district; allow-list ONLY {district, annual_rainfall_mm, provenance}.
# USAGE: Rscript R/build_relief_climate_rainfall.R [year] [out] [district_geojson] [cache_dir]
suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))
HERE <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]),
                             winslash = "/", mustWork = TRUE))
ROOT <- normalizePath(file.path(HERE, ".."), winslash = "/", mustWork = TRUE)
# Shared transform and consistency helpers (rainfall_district_means / rainfall_district_lon /
# rainfall_consistency_gate) - sourced by both this real builder and the fixture test, so the gate the real
# build runs is the exact gate CI exercises on a synthetic raster (no ~57MB download to cover it).
source(file.path(HERE, "relief_rainfall_transform.R"))
args <- commandArgs(trailingOnly = TRUE)
YEAR <- if (length(args) >= 1 && nzchar(args[1])) as.integer(args[1]) else 2023L
OUT  <- if (length(args) >= 2 && nzchar(args[2])) args[2] else file.path(ROOT, "generated", "relief_climate_rainfall.geojson")
GEOM <- if (length(args) >= 3 && nzchar(args[3])) args[3] else file.path(ROOT, "data", "relief_districts.geojson")
CACHE_DIR <- if (length(args) >= 4 && nzchar(args[4])) args[4] else file.path(ROOT, "cache", "chirps")
TIF  <- file.path(CACHE_DIR, sprintf("chirps-v2.0.%d.tif", YEAR))
URL  <- sprintf("https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_annual/tifs/chirps-v2.0.%d.tif", YEAR)

if (!file.exists(GEOM)) stop(sprintf("FAIL-CLOSED: district geometry not found: %s", GEOM))

# --- Fetch ONCE into the git-ignored cache (reuse if present). Heavy (~57MB) - fail-closed on a bad download. ---
if (!file.exists(TIF) || file.size(TIF) < 4e7) {
  dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
  options(timeout = max(getOption("timeout"), 1200))
  cat(sprintf("fetching CHIRPS annual %d (~57MB, one-time) from %s ...\n", YEAR, URL))
  ok <- tryCatch({ utils::download.file(URL, TIF, mode = "wb", quiet = TRUE); file.exists(TIF) && file.size(TIF) > 4e7 },
                 error = function(e) { cat("download error:", conditionMessage(e), "\n"); FALSE })
  if (!ok) { if (file.exists(TIF)) file.remove(TIF); stop("FAIL-CLOSED: CHIRPS download failed/incomplete - re-run when the network is available.") }
}

r <- terra::rast(TIF)

d <- sf::st_read(GEOM, quiet = TRUE)
if (!("district" %in% names(d))) stop("FAIL-CLOSED: district geometry lacks a 'district' property.")
d$district <- as.character(d$district)

# Coverage-fraction-weighted per-district mean (no-data masked) plus the bounded-value and WEST>EAST consistency gate.
# live in relief_rainfall_transform.R (sourced above) so the exact logic here is what the hermetic test executes.
d$annual_rainfall_mm <- rainfall_district_means(r, d)
.gt <- rainfall_consistency_gate(d$district, d$annual_rainfall_mm, rainfall_district_lon(d))  # returns c(west, east) pole means

d$provenance <- sprintf("CHIRPS v2.0 annual %d (UCSB CHC, public domain/CC0)", YEAR)
# Allow-list ONLY {district, annual_rainfall_mm, provenance}.
keep <- d[, c("district", "annual_rainfall_mm", "provenance")]
v <- terra::vect(keep)
dir.create(dirname(OUT), recursive = TRUE, showWarnings = FALSE)
if (file.exists(OUT)) file.remove(OUT)
terra::writeVector(v, OUT, filetype = "GeoJSON")
cat(sprintf("climate-rainfall choropleth: %d districts | %d-%d mm | west mean %.0f > east mean %.0f (consistency gate OK) | CHIRPS %d -> %s\n",
            nrow(keep), min(keep$annual_rainfall_mm), max(keep$annual_rainfall_mm), .gt["west"], .gt["east"], YEAR, OUT))
