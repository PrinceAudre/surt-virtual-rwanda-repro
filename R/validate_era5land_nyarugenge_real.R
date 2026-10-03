#!/usr/bin/env Rscript
# Limited independent real-data check of the ERA5-Land annual-temperature contract.
# Production uses the v1.4 calendar-day temporal transform plus exactextractr-based
# area weighting; this cross-check recomputes the annual raster and polygon mean
# independently with explicit calendar weights and terra exact cell fractions.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(jsonlite)
  library(exactextractr)
}))

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1]]) else "R/validate_era5land_nyarugenge_real.R"
root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
source(file.path(root, "R", "relief_temp_transform.R"))

year <- 2023L
district_name <- "Nyarugenge"
source_path <- file.path(root, "cache", "era5land", sprintf("era5land_t2m_%d.nc", year))
evidence_dir <- file.path(root, "generated", "era5land_validation")
dir.create(evidence_dir, recursive = TRUE, showWarnings = FALSE)
if (!file.exists(source_path)) {
  stop("FAIL-CLOSED: ERA5-Land source cache is missing; run the official CDS fetch first.", call. = FALSE)
}

monthly_k <- terra::rast(source_path)
if (terra::nlyr(monthly_k) != 12L) {
  stop(sprintf("FAIL-CLOSED: expected 12 ERA5-Land monthly layers, found %d.", terra::nlyr(monthly_k)), call. = FALSE)
}
if (is.na(sf::st_crs(terra::crs(monthly_k, proj = TRUE)))) {
  stop("FAIL-CLOSED: ERA5-Land raster CRS is missing.", call. = FALSE)
}

boundaries <- sf::st_read(file.path(root, "data", "relief_districts.geojson"), quiet = TRUE)
d <- boundaries[as.character(boundaries$district) == district_name, ]
if (nrow(d) != 1L) stop("FAIL-CLOSED: expected exactly one Nyarugenge polygon.", call. = FALSE)

production_annual_c <- temp_kelvin_to_celsius(temp_calendar_day_weighted_mean(monthly_k, year))
production_raw <- surt_area_weighted_summary(production_annual_c, d)
production_rounded <- temp_district_summary(production_annual_c, d)
if (!is.finite(production_raw$value[[1]])) {
  stop("FAIL-CLOSED: production ERA5-Land summary is non-finite.", call. = FALSE)
}

days <- c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
manual_k <- monthly_k[[1]] * days[[1]]
for (i in 2:12) manual_k <- manual_k + monthly_k[[i]] * days[[i]]
manual_c <- (manual_k / sum(days)) - 273.15

d_raster <- sf::st_transform(d, sf::st_crs(terra::crs(manual_c, proj = TRUE)))
x <- terra::extract(manual_c, terra::vect(d_raster), exact = TRUE, cells = TRUE, ID = FALSE)
value_cols <- setdiff(names(x), c("cell", "fraction"))
if (length(value_cols) != 1L || !all(c("cell", "fraction") %in% names(x))) {
  stop("FAIL-CLOSED: terra ERA5-Land extraction returned an unexpected schema.", call. = FALSE)
}
cell_area <- terra::cellSize(manual_c, mask = FALSE, unit = "m", transform = TRUE)
areas <- terra::values(cell_area, mat = FALSE)[x$cell]
values_x <- as.numeric(x[[value_cols[[1]]]])
weights <- as.numeric(x$fraction) * as.numeric(areas)
valid <- is.finite(values_x) & is.finite(weights) & weights > 0
if (!any(valid)) stop("FAIL-CLOSED: independent ERA5-Land check found no finite cells.", call. = FALSE)
independent_mean_c <- sum(values_x[valid] * weights[valid]) / sum(weights[valid])

difference_c <- as.numeric(production_raw$value[[1]]) - independent_mean_c
if (abs(difference_c) > 0.01) {
  stop(sprintf("FAIL-CLOSED: ERA5-Land cross-engine difference %.6f C exceeds 0.01 C.", difference_c), call. = FALSE)
}
if (abs(as.numeric(production_rounded$value[[1]]) - round(independent_mean_c, 1)) > 1e-9) {
  stop("FAIL-CLOSED: rounded production district value disagrees with independent result.", call. = FALSE)
}
if (production_raw$valid_data_fraction[[1]] < 0.999) {
  stop("FAIL-CLOSED: selected district does not have complete ERA5-Land valid-data coverage.", call. = FALSE)
}

summary <- list(
  schema_version = "1.0",
  status = "passed",
  case = "Nyarugenge ERA5-Land 2023 real-data numerical cross-check",
  district = district_name,
  year = year,
  product = "ERA5-Land monthly averaged reanalysis 2m_temperature",
  product_terms = "Copernicus Products licence",
  production_calendar_day_area_weighted_mean_c = as.numeric(production_raw$value[[1]]),
  production_reported_rounded_mean_c = as.numeric(production_rounded$value[[1]]),
  independent_terra_area_weighted_mean_c = independent_mean_c,
  production_minus_independent_c = difference_c,
  raster_coverage_fraction = as.numeric(production_raw$raster_coverage_fraction[[1]]),
  valid_within_raster_fraction = as.numeric(production_raw$valid_within_raster_fraction[[1]]),
  valid_data_fraction = as.numeric(production_raw$valid_data_fraction[[1]]),
  acceptance_gates = list(max_cross_engine_abs_difference_c = 0.01),
  limitation = "Computational cross-validation of one district and year; not validation of ERA5-Land observational accuracy."
)
json_path <- file.path(evidence_dir, "nyarugenge_era5land_2023_validation_summary.json")
jsonlite::write_json(summary, json_path, pretty = TRUE, auto_unbox = TRUE, digits = 12)
cat(sprintf(
  "[PASS] Nyarugenge ERA5-Land 2023: production %.6f C; terra %.6f C; difference %.6f C; reported %.1f C\n",
  production_raw$value[[1]], independent_mean_c, difference_c, production_rounded$value[[1]]
))
cat(sprintf(
  "[PASS] coverage: raster %.6f; valid within raster %.6f; overall valid %.6f\n",
  production_raw$raster_coverage_fraction[[1]], production_raw$valid_within_raster_fraction[[1]],
  production_raw$valid_data_fraction[[1]]
))
cat(sprintf("[WRITE] %s\n", normalizePath(json_path, winslash = "/", mustWork = TRUE)))
