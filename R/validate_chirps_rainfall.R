#!/usr/bin/env Rscript
# Scoped numerical validation for the public CHIRPS rainfall layer.
#
# This script independently recomputes the archived district means from the
# public CHIRPS annual GeoTIFF using two extraction implementations:
#   1. exactextractr coverage-fraction-weighted means (the release method), and
#   2. terra exact polygon means (a cross-implementation comparison).
# It also quantifies sensitivity to latitude-varying cell area by applying a
# cell-area raster as a second weight in exactextractr.
#
# The validation is intentionally scoped to the public, account-free rainfall
# layer. It does not validate ERA5-Land, MODIS, HAND, hazards, or downstream use.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
  library(jsonlite)
}))

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1]]) else "R/validate_chirps_rainfall.R"
root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
args <- commandArgs(trailingOnly = TRUE)
year <- if (length(args) >= 1L && nzchar(args[[1]])) as.integer(args[[1]]) else 2023L
cache_dir <- if (length(args) >= 2L && nzchar(args[[2]])) args[[2]] else file.path(root, "cache", "chirps")
output_dir <- if (length(args) >= 3L && nzchar(args[[3]])) args[[3]] else file.path(root, "generated", "chirps_validation")

if (is.na(year) || year < 1981L || year > as.integer(format(Sys.Date(), "%Y"))) {
  stop("FAIL-CLOSED: validation year is invalid.", call. = FALSE)
}

dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

tif <- file.path(cache_dir, sprintf("chirps-v2.0.%d.tif", year))
url <- sprintf(
  "https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_annual/tifs/chirps-v2.0.%d.tif",
  year
)

if (!file.exists(tif) || file.size(tif) < 4e7) {
  options(timeout = max(getOption("timeout"), 1200))
  message("Downloading public CHIRPS annual raster: ", url)
  ok <- tryCatch({
    utils::download.file(url, tif, mode = "wb", quiet = TRUE)
    file.exists(tif) && file.size(tif) > 4e7
  }, error = function(e) {
    message("Download error: ", conditionMessage(e))
    FALSE
  })
  if (!ok) {
    if (file.exists(tif)) file.remove(tif)
    stop("FAIL-CLOSED: CHIRPS download failed or was incomplete.", call. = FALSE)
  }
}

geometry_path <- file.path(root, "data", "relief_districts.geojson")
archive_path <- file.path(root, "data", "relief_climate_rainfall.geojson")
if (!file.exists(geometry_path) || !file.exists(archive_path)) {
  stop("FAIL-CLOSED: required archived GeoJSON files are missing.", call. = FALSE)
}

districts <- sf::st_read(geometry_path, quiet = TRUE, stringsAsFactors = FALSE)
archived <- sf::st_read(archive_path, quiet = TRUE, stringsAsFactors = FALSE)
required_archive <- c("district", "annual_rainfall_mm")
if (!all(required_archive %in% names(archived))) {
  stop("FAIL-CLOSED: archived rainfall schema is incomplete.", call. = FALSE)
}
if (nrow(districts) != 30L || nrow(archived) != 30L) {
  stop("FAIL-CLOSED: validation expects exactly 30 Rwanda districts.", call. = FALSE)
}
if (anyDuplicated(districts$district) || anyDuplicated(archived$district)) {
  stop("FAIL-CLOSED: duplicate district identifiers found.", call. = FALSE)
}

r <- terra::rast(tif)
if (terra::nlyr(r) != 1L) stop("FAIL-CLOSED: CHIRPS annual input must have one layer.", call. = FALSE)
r <- terra::ifel(r < 0, NA, r)

# Release-method reproduction.
exact_mean <- as.numeric(exactextractr::exact_extract(
  r,
  districts,
  "mean",
  progress = FALSE
))
if (length(exact_mean) != nrow(districts) || any(!is.finite(exact_mean))) {
  stop("FAIL-CLOSED: exactextractr produced missing or non-finite values.", call. = FALSE)
}

# Cross-implementation extraction using terra's exact cell fractions.
terra_result <- terra::extract(
  r,
  terra::vect(districts),
  fun = "mean",
  na.rm = TRUE,
  exact = TRUE,
  ID = FALSE
)
if (!is.data.frame(terra_result) || ncol(terra_result) != 1L) {
  stop("FAIL-CLOSED: unexpected terra extraction result schema.", call. = FALSE)
}
terra_mean <- as.numeric(terra_result[[1]])
if (length(terra_mean) != nrow(districts) || any(!is.finite(terra_mean))) {
  stop("FAIL-CLOSED: terra produced missing or non-finite values.", call. = FALSE)
}

# Sensitivity to true cell area in geographic coordinates.
cell_area_km2 <- terra::cellSize(r, unit = "km")
area_weighted_mean <- as.numeric(exactextractr::exact_extract(
  r,
  districts,
  "weighted_mean",
  weights = cell_area_km2,
  progress = FALSE
))
if (length(area_weighted_mean) != nrow(districts) || any(!is.finite(area_weighted_mean))) {
  stop("FAIL-CLOSED: area-weighted extraction produced missing values.", call. = FALSE)
}

archive_lookup <- archived$annual_rainfall_mm[match(districts$district, archived$district)]
if (any(!is.finite(archive_lookup))) {
  stop("FAIL-CLOSED: archived rainfall values could not be matched to all districts.", call. = FALSE)
}

results <- data.frame(
  district = as.character(districts$district),
  archived_rounded_mm = as.numeric(archive_lookup),
  exactextractr_mean_mm = exact_mean,
  terra_exact_mean_mm = terra_mean,
  area_weighted_mean_mm = area_weighted_mean,
  archived_minus_rounded_recompute_mm = archive_lookup - round(exact_mean),
  terra_minus_exactextractr_mm = terra_mean - exact_mean,
  area_weighted_minus_coverage_mean_mm = area_weighted_mean - exact_mean,
  stringsAsFactors = FALSE
)

max_archive_rounding_difference <- max(abs(results$archived_minus_rounded_recompute_mm))
max_cross_implementation_difference <- max(abs(results$terra_minus_exactextractr_mm))
rmse_cross_implementation <- sqrt(mean(results$terra_minus_exactextractr_mm^2))
max_area_weighting_difference <- max(abs(results$area_weighted_minus_coverage_mean_mm))
rmse_area_weighting <- sqrt(mean(results$area_weighted_minus_coverage_mean_mm^2))

# Hard acceptance gates are deliberately narrow for archive reproduction and
# modest for cross-implementation floating-point/edge-treatment differences.
if (max_archive_rounding_difference != 0) {
  stop(sprintf(
    "FAIL-CLOSED: archived rounded rainfall does not reproduce; maximum difference %.3f mm.",
    max_archive_rounding_difference
  ), call. = FALSE)
}
if (max_cross_implementation_difference > 2.0) {
  stop(sprintf(
    "FAIL-CLOSED: cross-implementation rainfall difference exceeds 2 mm; maximum %.3f mm.",
    max_cross_implementation_difference
  ), call. = FALSE)
}

csv_path <- file.path(output_dir, sprintf("chirps_%d_district_validation.csv", year))
json_path <- file.path(output_dir, sprintf("chirps_%d_validation_summary.json", year))
utils::write.csv(results, csv_path, row.names = FALSE, digits = 12)

summary <- list(
  schema_version = "1.0",
  status = "passed",
  validation_scope = "CHIRPS annual rainfall only",
  year = year,
  source_url = url,
  source_file = basename(tif),
  source_file_bytes = unname(file.info(tif)$size),
  district_count = nrow(results),
  methods = list(
    release_reproduction = "exactextractr mean weighted by polygon-cell coverage fraction",
    cross_implementation = "terra extract mean with exact polygon-cell fractions",
    sensitivity = "exactextractr weighted_mean using terra cellSize square-kilometre weights"
  ),
  acceptance_gates = list(
    archived_rounded_recompute_max_abs_mm = 0,
    cross_implementation_max_abs_mm = 2.0
  ),
  metrics = list(
    max_archive_rounding_difference_mm = max_archive_rounding_difference,
    max_cross_implementation_difference_mm = max_cross_implementation_difference,
    rmse_cross_implementation_mm = rmse_cross_implementation,
    max_area_weighting_difference_mm = max_area_weighting_difference,
    rmse_area_weighting_mm = rmse_area_weighting
  ),
  limitations = c(
    "This validation covers CHIRPS rainfall only.",
    "The two extraction implementations use the same source raster and district geometry.",
    "Agreement does not validate the CHIRPS observational product itself.",
    "Area-weighting sensitivity is descriptive and does not establish downstream model effects."
  )
)
jsonlite::write_json(summary, json_path, pretty = TRUE, auto_unbox = TRUE, digits = 12)

cat(sprintf(
  paste0(
    "[PASS] CHIRPS %d archive reproduction: 30/30 rounded district values identical\n",
    "[PASS] cross-implementation comparison: max |terra - exactextractr| = %.6f mm; RMSE = %.6f mm\n",
    "[PASS] cell-area sensitivity: max |area-weighted - coverage mean| = %.6f mm; RMSE = %.6f mm\n",
    "[WRITE] %s\n[WRITE] %s\n"
  ),
  year,
  max_cross_implementation_difference,
  rmse_cross_implementation,
  max_area_weighting_difference,
  rmse_area_weighting,
  normalizePath(csv_path, winslash = "/", mustWork = TRUE),
  normalizePath(json_path, winslash = "/", mustWork = TRUE)
))
