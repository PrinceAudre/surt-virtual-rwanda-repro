#!/usr/bin/env Rscript
# build_relief_low_lying_hand.R - per-district descriptive low-lying terrain share
# from the CC0 Global 30 m HAND product (ASF/HydroSAR, Copernicus GLO-30 DEM).
# Static terrain descriptor only: not observed flooding, flood probability,
# a validated hazard model, a forecast, surveillance output, or operational advice.
#
# Metric: percentage of VALID HAND-covered district area at or below threshold
# (default 5 m above nearest drainage). Three explicit coverage fractions are
# emitted so raster extent and HAND no-data are never silently conflated.
#
# DATA: Global 30 m HAND, CC0 1.0 Public Domain. Cloud-Optimized GeoTIFF 1x1
# degree tiles are fetched from the anonymous public S3 bucket over HTTPS.
# USAGE: Rscript R/build_relief_low_lying_hand.R [threshold_m] [out] [district_geojson] [cache_dir]

suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))
HERE <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]),
                             winslash = "/", mustWork = TRUE))
ROOT <- normalizePath(file.path(HERE, ".."), winslash = "/", mustWork = TRUE)
source(file.path(HERE, "relief_low_lying_transform.R"))
args <- commandArgs(trailingOnly = TRUE)
THRESH <- if (length(args) >= 1 && nzchar(args[1])) as.numeric(args[1]) else 5
OUT <- if (length(args) >= 2 && nzchar(args[2])) args[2] else file.path(ROOT, "generated", "relief_low_lying_hand.geojson")
GEOM <- if (length(args) >= 3 && nzchar(args[3])) args[3] else file.path(ROOT, "data", "relief_districts.geojson")
CACHE_DIR <- if (length(args) >= 4 && nzchar(args[4])) args[4] else file.path(ROOT, "cache", "hand")
BASE_URL <- "https://glo-30-hand.s3.amazonaws.com/v1/2021"

if (!file.exists(GEOM)) stop(sprintf("FAIL-CLOSED: district geometry not found: %s", GEOM))

hand_tile_url <- function(lat_deg, lon_deg) {
  ns <- if (lat_deg < 0) sprintf("S%02d", -lat_deg) else sprintf("N%02d", lat_deg)
  ew <- if (lon_deg < 0) sprintf("W%03d", -lon_deg) else sprintf("E%03d", lon_deg)
  sprintf("%s/Copernicus_DSM_COG_10_%s_00_%s_00_HAND.tif", BASE_URL, ns, ew)
}

d <- sf::st_read(GEOM, quiet = TRUE)
if (!("district" %in% names(d))) stop("FAIL-CLOSED: district geometry lacks a 'district' property.")
d$district <- as.character(d$district)
bb <- sf::st_bbox(d)
lat_tiles <- seq(floor(bb[["ymin"]]), floor(bb[["ymax"]]))
lon_tiles <- seq(floor(bb[["xmin"]]), floor(bb[["xmax"]]))

dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
options(timeout = max(getOption("timeout"), 1200))
paths <- character(0)
for (la in lat_tiles) for (lo in lon_tiles) {
  url <- hand_tile_url(la, lo)
  tif <- file.path(CACHE_DIR, basename(url))
  if (!file.exists(tif) || file.size(tif) < 1e5) {
    ok <- tryCatch({
      utils::download.file(url, tif, mode = "wb", quiet = TRUE)
      file.exists(tif) && file.size(tif) > 1e5
    }, error = function(e) FALSE)
    if (!ok) {
      if (file.exists(tif)) file.remove(tif)
      stop(sprintf(
        "FAIL-CLOSED: required Rwanda HAND tile did not download: %s. Refusing a partial mosaic.",
        basename(url)
      ))
    }
  }
  paths <- c(paths, tif)
}
cat(sprintf("HAND tiles: all %d Rwanda-bbox tiles cached/fetched -> mosaic + clip\n", length(paths)))

r <- if (length(paths) == 1) terra::rast(paths) else
  terra::vrt(paths, filename = file.path(CACHE_DIR, "hand_rwanda.vrt"), overwrite = TRUE)
r <- terra::crop(r, terra::ext(bb[["xmin"]], bb[["xmax"]], bb[["ymin"]], bb[["ymax"]]))

hand_summary <- low_lying_summary(r, d, THRESH)
d$low_lying_share_pct <- round(hand_summary$low_lying_share_pct, 1)
d$raster_coverage_fraction <- round(hand_summary$raster_coverage_fraction, 6)
d$valid_within_raster_fraction <- round(hand_summary$valid_within_raster_fraction, 6)
d$valid_data_fraction <- round(hand_summary$valid_data_fraction, 6)
# Retain the domain-specific name in the output while making its equivalence to
# the standard overall valid-data fraction explicit.
d$valid_hand_area_fraction <- d$valid_data_fraction
.gt <- low_lying_consistency_gate(
  d$district, d$low_lying_share_pct, low_lying_district_lon(d)
)

d$provenance <- sprintf(
  paste0(
    "HAND (Height Above Nearest Drainage, CC0; ASF/HydroSAR from Copernicus GLO-30 DEM); ",
    "surface-area-weighted %% of valid HAND-covered district area <= %g m; ",
    "raster-footprint and valid-data coverage fractions reported"
  ),
  THRESH
)
keep <- d[, c(
  "district", "low_lying_share_pct", "raster_coverage_fraction",
  "valid_within_raster_fraction", "valid_data_fraction",
  "valid_hand_area_fraction", "provenance"
)]
v <- terra::vect(keep)
dir.create(dirname(OUT), recursive = TRUE, showWarnings = FALSE)
if (file.exists(OUT)) file.remove(OUT)
terra::writeVector(v, OUT, filetype = "GeoJSON")
cat(sprintf(
  paste0(
    "low-lying HAND share: %d districts | %.1f-%.1f %% of valid HAND area <= %g m | ",
    "valid-data fraction %.3f-%.3f | east mean %.1f > west mean %.1f -> %s\n"
  ),
  nrow(keep), min(keep$low_lying_share_pct), max(keep$low_lying_share_pct), THRESH,
  min(keep$valid_data_fraction), max(keep$valid_data_fraction),
  .gt[["east"]], .gt[["west"]], OUT
))
