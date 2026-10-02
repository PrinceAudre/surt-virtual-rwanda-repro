#!/usr/bin/env Rscript
# Build district mean temperature from ERA5-Land monthly means as an explicit
# offline preparation step. Descriptive layer only: not a forecast, surveillance
# output, or operational recommendation.
#
# DATA: ERA5-Land monthly averaged 2 m air temperature (Copernicus C3S/ECMWF).
# Annual statistic: calendar-day-weighted mean of the 12 monthly means, followed
# by a true surface-area-weighted district mean over finite annual raster cells.
# Output retains raster-footprint, within-raster finite-data, and overall
# valid-data coverage fractions.
#
# USAGE: Rscript R/build_relief_climate_temperature.R [year] [out] [district_geojson] [cache_dir]

suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))
args <- commandArgs(trailingOnly = TRUE)
YEAR <- if (length(args) >= 1 && nzchar(args[1])) as.integer(args[1]) else 2023L
HERE <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]),
                             winslash = "/", mustWork = TRUE))
ROOT <- normalizePath(file.path(HERE, ".."), winslash = "/", mustWork = TRUE)
OUT <- if (length(args) >= 2 && nzchar(args[2])) args[2] else file.path(ROOT, "generated", "relief_climate_temp.geojson")
GEOM <- if (length(args) >= 3 && nzchar(args[3])) args[3] else file.path(ROOT, "data", "relief_districts.geojson")
CACHE_DIR <- if (length(args) >= 4 && nzchar(args[4])) args[4] else file.path(ROOT, "cache", "era5land")
source(file.path(HERE, "relief_temp_transform.R"))
PY <- file.path(ROOT, "python", "fetch_era5land_temperature.py")
NC <- file.path(CACHE_DIR, sprintf("era5land_t2m_%d.nc", YEAR))
SETUP <- paste(
  "register at https://cds.climate.copernicus.eu and accept the ERA5-Land licence,",
  "install cdsapi, then configure the user's external CDS API credentials."
)

if (!file.exists(GEOM)) stop(sprintf("FAIL-CLOSED: district geometry not found: %s", GEOM))

if (!file.exists(NC)) {
  py <- Sys.which("python"); if (!nzchar(py)) py <- Sys.which("python3")
  if (!nzchar(py)) {
    stop(sprintf("FAIL-CLOSED: Python not found. To fetch ERA5-Land: %s", SETUP))
  }
  cat(sprintf("fetching ERA5-Land 2m_temperature %d via cdsapi ...\n", YEAR))
  code <- tryCatch(system2(py, c(shQuote(PY), YEAR, shQuote(NC))), error = function(e) 1L)
  if (!identical(code, 0L) || !file.exists(NC)) {
    stop(sprintf("FAIL-CLOSED: ERA5-Land fetch did not produce %s. %s", NC, SETUP))
  }
}

monthly_k <- terra::rast(NC)
if (terra::nlyr(monthly_k) != 12L) {
  stop(sprintf(
    "FAIL-CLOSED: %s has %d layer(s), expected 12 monthly means. Delete the cache file and re-run.",
    NC, terra::nlyr(monthly_k)
  ))
}
annual_k <- temp_calendar_day_weighted_mean(monthly_k, YEAR)
r <- temp_kelvin_to_celsius(annual_k)

d <- sf::st_read(GEOM, quiet = TRUE)
if (!("district" %in% names(d))) stop("FAIL-CLOSED: district geometry lacks a 'district' property.")
d$district <- as.character(d$district)

temp_summary <- temp_district_summary(r, d)
d$mean_temp_c <- temp_summary$value
d$raster_coverage_fraction <- round(temp_summary$raster_coverage_fraction, 6)
d$valid_within_raster_fraction <- round(temp_summary$valid_within_raster_fraction, 6)
d$valid_data_fraction <- round(temp_summary$valid_data_fraction, 6)
.gt <- temp_consistency_gate(d$district, d$mean_temp_c, temp_district_lon(d))

d$provenance <- sprintf(
  paste0(
    "ERA5-Land 2m_temperature (Copernicus CDS; Copernicus Products licence), ",
    "calendar-day-weighted annual mean of 12 monthly means, %d; ",
    "surface-area-weighted district mean over finite raster cells; coverage fractions reported"
  ),
  YEAR
)
keep <- d[, c(
  "district", "mean_temp_c", "raster_coverage_fraction",
  "valid_within_raster_fraction", "valid_data_fraction", "provenance"
)]
v <- terra::vect(keep)
dir.create(dirname(OUT), recursive = TRUE, showWarnings = FALSE)
if (file.exists(OUT)) file.remove(OUT)
terra::writeVector(v, OUT, filetype = "GeoJSON")
cat(sprintf(
  paste0(
    "REAL climate-temp: %d districts | %.1f-%.1f C | valid-data fraction %.4f-%.4f | ",
    "calendar-day-weighted %d annual mean | highlands %.1f < lowlands %.1f -> %s\n"
  ),
  nrow(keep), min(keep$mean_temp_c), max(keep$mean_temp_c),
  min(keep$valid_data_fraction), max(keep$valid_data_fraction), YEAR,
  .gt[["west"]], .gt[["east"]], OUT
))
