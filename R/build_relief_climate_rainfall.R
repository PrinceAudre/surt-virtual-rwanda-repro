#!/usr/bin/env Rscript
# Build district-level annual rainfall from CHIRPS v2.0 as an explicit offline
# preparation step. This is a single-year descriptive layer, not a climatological
# normal, forecast, surveillance output, or operational recommendation.
#
# DATA: CHIRPS v2.0 annual rainfall (UCSB Climate Hazards Center), public domain.
# District values are true surface-area-weighted means over finite CHIRPS cells.
# Output includes raster-footprint, within-raster finite-data, and overall
# valid-data coverage fractions so partial coverage is never silent.
#
# USAGE: Rscript R/build_relief_climate_rainfall.R [year] [out] [district_geojson] [cache_dir]

suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))
HERE <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]),
                             winslash = "/", mustWork = TRUE))
ROOT <- normalizePath(file.path(HERE, ".."), winslash = "/", mustWork = TRUE)
source(file.path(HERE, "relief_rainfall_transform.R"))
args <- commandArgs(trailingOnly = TRUE)
YEAR <- if (length(args) >= 1 && nzchar(args[1])) as.integer(args[1]) else 2023L
OUT <- if (length(args) >= 2 && nzchar(args[2])) args[2] else file.path(ROOT, "generated", "relief_climate_rainfall.geojson")
GEOM <- if (length(args) >= 3 && nzchar(args[3])) args[3] else file.path(ROOT, "data", "relief_districts.geojson")
CACHE_DIR <- if (length(args) >= 4 && nzchar(args[4])) args[4] else file.path(ROOT, "cache", "chirps")
TIF <- file.path(CACHE_DIR, sprintf("chirps-v2.0.%d.tif", YEAR))
URL <- sprintf("https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_annual/tifs/chirps-v2.0.%d.tif", YEAR)

if (!file.exists(GEOM)) stop(sprintf("FAIL-CLOSED: district geometry not found: %s", GEOM))

if (!file.exists(TIF) || file.size(TIF) < 4e7) {
  dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
  options(timeout = max(getOption("timeout"), 1200))
  cat(sprintf("fetching CHIRPS annual %d (~57MB, one-time) from %s ...\n", YEAR, URL))
  ok <- tryCatch({
    utils::download.file(URL, TIF, mode = "wb", quiet = TRUE)
    file.exists(TIF) && file.size(TIF) > 4e7
  }, error = function(e) {
    cat("download error:", conditionMessage(e), "\n")
    FALSE
  })
  if (!ok) {
    if (file.exists(TIF)) file.remove(TIF)
    stop("FAIL-CLOSED: CHIRPS download failed/incomplete - re-run when the network is available.")
  }
}

r <- terra::rast(TIF)
d <- sf::st_read(GEOM, quiet = TRUE)
if (!("district" %in% names(d))) stop("FAIL-CLOSED: district geometry lacks a 'district' property.")
d$district <- as.character(d$district)

rain_summary <- rainfall_district_summary(r, d)
d$annual_rainfall_mm <- rain_summary$value
d$raster_coverage_fraction <- round(rain_summary$raster_coverage_fraction, 6)
d$valid_within_raster_fraction <- round(rain_summary$valid_within_raster_fraction, 6)
d$valid_data_fraction <- round(rain_summary$valid_data_fraction, 6)
.gt <- rainfall_consistency_gate(
  d$district, d$annual_rainfall_mm, rainfall_district_lon(d)
)

d$provenance <- sprintf(
  paste0(
    "CHIRPS v2.0 annual %d (UCSB CHC, public domain); ",
    "surface-area-weighted district mean over finite raster cells; coverage fractions reported"
  ),
  YEAR
)
keep <- d[, c(
  "district", "annual_rainfall_mm", "raster_coverage_fraction",
  "valid_within_raster_fraction", "valid_data_fraction", "provenance"
)]
v <- terra::vect(keep)
dir.create(dirname(OUT), recursive = TRUE, showWarnings = FALSE)
if (file.exists(OUT)) file.remove(OUT)
terra::writeVector(v, OUT, filetype = "GeoJSON")
cat(sprintf(
  paste0(
    "climate-rainfall: %d districts | %d-%d mm | valid-data fraction %.4f-%.4f | ",
    "west mean %.0f > east mean %.0f | CHIRPS %d -> %s\n"
  ),
  nrow(keep), min(keep$annual_rainfall_mm), max(keep$annual_rainfall_mm),
  min(keep$valid_data_fraction), max(keep$valid_data_fraction),
  .gt[["west"]], .gt[["east"]], YEAR, OUT
))
