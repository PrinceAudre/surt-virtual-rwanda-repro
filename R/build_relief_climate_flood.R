#!/usr/bin/env Rscript
# build_relief_climate_flood.R - REAL per-district FLOOD-SUSCEPTIBILITY choropleth from the CC0 global HAND product
# (Height Above Nearest Drainage; ASF/HydroSAR from the Copernicus GLO-30 DEM). Indicator #5, Phase 2 of the
# climate-health feature - the flood -> cholera/AWD terrain context. Offline governed-prepare; NOT sourced by app.R.
# DESCRIPTIVE terrain susceptibility - not a forecast, not surveillance, not operational; operational_use_allowed = FALSE.
#
# DATA: Global 30 m HAND (CC0 1.0 PUBLIC DOMAIN; verified 2026-07-12 - registry.opendata.aws/glo-30-hand). Cloud-
# Optimized GeoTIFF 1x1-deg tiles on the ANONYMOUS public S3 bucket (no AWS account) - fetched here over HTTPS.
# Pixel = vertical distance (m) to the nearest drainage. Citation-requested (not required, CC0): "Global 30m HAND,
# accessed 2026 from https://registry.opendata.aws/glo-30-hand". No credentials, so - unlike ERA5-Land/MODIS - there
# is NO owner key-setup step; it just needs one network run.
#
# METHOD: mosaic the tiles covering Rwanda -> clip -> per-district % of area with HAND <= threshold (default 5 m,
# low-lying near-drainage = inundation-prone). GROUND-TRUTH GATE (fail-closed, in relief_flood_transform.R): every
# fraction in [0,100]% AND eastern lowland/wetland districts more inundation-prone than the steep western highlands.
# GOVERNANCE: aggregate per-district; allow-list ONLY {district, flood_prone_pct, provenance}. FAIL-CLOSED until the
# tiles are cached (writes NOTHING, so nothing renders a half-built layer).
# GEOMETRY: reuses 05_dashboard/www/relief_districts.geojson. OUTPUT (git-ignored): www/relief_climate_flood.geojson
# USAGE: Rscript tools/semantic_layers/experimental_maplibre_relief/build_relief_climate_flood.R [threshold_m] [out]
suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))
HERE <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
# Shared transform + ground-truth helpers (flood_prone_fraction / flood_district_lon / flood_ground_truth_gate) -
# sourced by BOTH this real builder AND the hermetic test, so the gate the real build runs is the exact gate CI
# exercises on a synthetic HAND raster (no multi-tile download to cover it).
source(file.path(HERE, "relief_flood_transform.R"))
args <- commandArgs(trailingOnly = TRUE)
THRESH <- if (length(args) >= 1 && nzchar(args[1])) as.numeric(args[1]) else 5
GEOM <- file.path("05_dashboard", "www", "relief_districts.geojson")
OUT  <- if (length(args) >= 2 && nzchar(args[2])) args[2] else file.path("05_dashboard", "www", "relief_climate_flood.geojson")
CACHE_DIR <- file.path("02_data", "cache", "climate", "hand")
BASE_URL  <- "https://glo-30-hand.s3.amazonaws.com/v1/2021"

if (!file.exists(GEOM)) stop(sprintf("FAIL-CLOSED: district geometry %s not found - build the population layer first.", GEOM))

# --- SEAM (first-real-fetch verify): the exact HAND COG tile URL for a 1x1-deg tile whose SW corner is
# (lat_deg N, lon_deg E). Copernicus GLO-30 convention: name is the SW-corner integer degree, hemisphere-lettered,
# minutes "_00". Rwanda is all southern (S) / all eastern (E). e.g. Copernicus_DSM_COG_10_S02_00_E029_00_HAND.tif.
hand_tile_url <- function(lat_deg, lon_deg) {
  ns <- if (lat_deg < 0) sprintf("S%02d", -lat_deg) else sprintf("N%02d", lat_deg)
  ew <- if (lon_deg < 0) sprintf("W%03d", -lon_deg) else sprintf("E%03d", lon_deg)
  sprintf("%s/Copernicus_DSM_COG_10_%s_00_%s_00_HAND.tif", BASE_URL, ns, ew)
}

d <- sf::st_read(GEOM, quiet = TRUE)
if (!("district" %in% names(d))) stop("FAIL-CLOSED: district geometry lacks a 'district' property.")
d$district <- as.character(d$district)
bb <- sf::st_bbox(d)
# SW-corner integer degrees of every 1-deg tile overlapping Rwanda's bbox.
lat_tiles <- seq(floor(bb[["ymin"]]), floor(bb[["ymax"]]))
lon_tiles <- seq(floor(bb[["xmin"]]), floor(bb[["xmax"]]))

# --- Fetch EVERY candidate tile over Rwanda's bbox ONCE into the git-ignored cache (reuse if present). ALL bbox
# tiles are land (Rwanda + its borders; the tile-name seam is verified against the live bucket), so a missing tile
# is a network / seam failure, NOT a legitimately-absent ocean tile -> fail-closed on ANY missing tile. A PARTIAL
# mosaic is the trap (Codex #68 P1): a district straddling the missing tile's area would let exact_extract silently
# average ONLY its covered cells and write a BIASED partial-coverage % (the per-district NA gate catches a FULLY-
# uncovered district, not a partly-covered one). All-or-nothing. (A per-district coverage check is the wrong fix
# here - it would false-fail the Lake Kivu shore districts, whose lake area is legitimate HAND no-data.) ---
dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
options(timeout = max(getOption("timeout"), 1200))
paths <- character(0)
for (la in lat_tiles) for (lo in lon_tiles) {
  url <- hand_tile_url(la, lo)
  tif <- file.path(CACHE_DIR, basename(url))
  if (!file.exists(tif) || file.size(tif) < 1e5) {
    ok <- tryCatch({ utils::download.file(url, tif, mode = "wb", quiet = TRUE); file.exists(tif) && file.size(tif) > 1e5 },
                   error = function(e) FALSE)
    if (!ok) { if (file.exists(tif)) file.remove(tif)
      stop(sprintf("FAIL-CLOSED: required Rwanda HAND tile did not download: %s (from %s). Every bbox tile is expected land - re-run when the network is available / verify the tile-name SEAM (hand_tile_url). NOT writing a partial mosaic. (Other climate layers are unaffected.)", basename(url), BASE_URL)) }
  }
  paths <- c(paths, tif)
}
cat(sprintf("HAND tiles: all %d Rwanda-bbox tiles cached/fetched -> mosaic + clip\n", length(paths)))

# Mosaic the tiles (terra::vrt stitches lazily without loading all into memory) and crop to Rwanda's bbox.
r <- if (length(paths) == 1) terra::rast(paths) else terra::vrt(paths, filename = file.path(CACHE_DIR, "hand_rwanda.vrt"), overwrite = TRUE)
r <- terra::crop(r, terra::ext(bb[["xmin"]], bb[["xmax"]], bb[["ymin"]], bb[["ymax"]]))

# Per-district % of area with HAND <= threshold + the two-part SCALE [0,100]% + EAST>WEST (lowlands more
# inundation-prone) ground-truth gate. Both live in relief_flood_transform.R (sourced above).
d$flood_prone_pct <- flood_prone_fraction(r, d, THRESH)
.gt <- flood_ground_truth_gate(d$district, d$flood_prone_pct, flood_district_lon(d))  # returns c(east, west) pole means

d$provenance <- sprintf("HAND (Height Above Nearest Drainage, CC0; ASF/HydroSAR from Copernicus GLO-30 DEM); %% of district area <= %g m above nearest drainage", THRESH)
# Allow-list ONLY {district, flood_prone_pct, provenance}.
keep <- d[, c("district", "flood_prone_pct", "provenance")]
v <- terra::vect(keep)
if (file.exists(OUT)) file.remove(OUT)
terra::writeVector(v, OUT, filetype = "GeoJSON")
cat(sprintf("climate flood-susceptibility choropleth: %d districts | %.1f-%.1f %% area <= %g m HAND | east lowlands mean %.1f > west highlands mean %.1f (ground-truth OK) -> %s\n",
            nrow(keep), min(keep$flood_prone_pct), max(keep$flood_prone_pct), THRESH, .gt[["east"]], .gt[["west"]], OUT))
