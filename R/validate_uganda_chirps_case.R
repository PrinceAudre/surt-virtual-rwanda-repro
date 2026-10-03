#!/usr/bin/env Rscript
# Independent numerical cross-check for the source-derived Uganda CHIRPS case.
# The configured harmonizer uses exactextractr for polygon-cell fractions; this
# validator recomputes the mean with terra exact fractions plus cell surface area.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(jsonlite)
}))

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1]]) else "R/validate_uganda_chirps_case.R"
root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
args <- commandArgs(trailingOnly = TRUE)
year <- if (length(args) >= 1L && nzchar(args[[1]])) as.integer(args[[1]]) else 2023L

source_path <- file.path(root, "cache", "chirps", sprintf("chirps-v2.0.%d.tif", year))
boundary_path <- file.path(root, "fixtures", "uganda_natural_earth_110m.geojson")
output_path <- file.path(root, "generated", sprintf("uganda_chirps_%d.geojson", year))
evidence_dir <- file.path(root, "generated", "uganda_chirps_validation")
dir.create(evidence_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(source_path) || file.size(source_path) < 4e7) {
  stop("FAIL-CLOSED: cached CHIRPS source raster is missing or incomplete.", call. = FALSE)
}
if (!file.exists(boundary_path) || !file.exists(output_path)) {
  stop("FAIL-CLOSED: Uganda boundary or configured output is missing.", call. = FALSE)
}
r <- terra::rast(source_path)
if (terra::nlyr(r) != 1L) stop("FAIL-CLOSED: CHIRPS annual raster must have one layer.", call. = FALSE)
if (is.na(sf::st_crs(terra::crs(r, proj = TRUE)))) stop("FAIL-CLOSED: CHIRPS raster CRS is missing.", call. = FALSE)
r <- terra::ifel(r < 0, NA, r)

uganda <- sf::st_read(boundary_path, quiet = TRUE, stringsAsFactors = FALSE)
if (nrow(uganda) != 1L || !identical(as.character(uganda$iso_a3), "UGA")) {
  stop("FAIL-CLOSED: expected one Natural Earth Uganda feature with iso_a3=UGA.", call. = FALSE)
}
if (!all(sf::st_is_valid(uganda))) stop("FAIL-CLOSED: Uganda boundary is invalid.", call. = FALSE)

out <- sf::st_read(output_path, quiet = TRUE, stringsAsFactors = FALSE)
required <- c(
  "unit_id", "annual_rainfall_mm", "raster_coverage_fraction",
  "valid_within_raster_fraction", "valid_data_fraction", "provenance"
)
if (nrow(out) != 1L || !all(required %in% names(out))) {
  stop("FAIL-CLOSED: configured Uganda output has an unexpected schema.", call. = FALSE)
}
if (!identical(as.character(out$unit_id), "UGA")) {
  stop("FAIL-CLOSED: configured Uganda output lost the UGA identifier.", call. = FALSE)
}
if (!grepl("CHIRPS v2.0 annual 2023", out$provenance[[1]], fixed = TRUE) ||
    !grepl("Natural Earth", out$provenance[[1]], fixed = TRUE)) {
  stop("FAIL-CLOSED: configured Uganda output provenance is incomplete.", call. = FALSE)
}
# Independent polygon-cell fractions from terra. Cell surface areas are then
# applied explicitly so the cross-check matches the declared scientific estimand.
x <- terra::extract(
  r,
  terra::vect(sf::st_transform(uganda, sf::st_crs(terra::crs(r, proj = TRUE)))),
  exact = TRUE,
  cells = TRUE,
  ID = FALSE
)
value_cols <- setdiff(names(x), c("cell", "fraction"))
if (length(value_cols) != 1L || !all(c("cell", "fraction") %in% names(x))) {
  stop("FAIL-CLOSED: terra exact extraction returned an unexpected schema.", call. = FALSE)
}
cell_area <- terra::cellSize(r, unit = "m", transform = TRUE)
areas <- terra::values(cell_area, mat = FALSE)[x$cell]
values_x <- as.numeric(x[[value_cols[[1]]]])
weights <- as.numeric(x$fraction) * as.numeric(areas)
valid <- is.finite(values_x) & is.finite(weights) & weights > 0
if (!any(valid)) stop("FAIL-CLOSED: terra cross-check found no valid Uganda CHIRPS cells.", call. = FALSE)
terra_area_mean <- sum(values_x[valid] * weights[valid]) / sum(weights[valid])
configured_mean <- as.numeric(out$annual_rainfall_mm[[1]])
difference_mm <- configured_mean - terra_area_mean

if (!is.finite(configured_mean) || configured_mean <= 0 || configured_mean >= 5000) {
  stop("FAIL-CLOSED: configured Uganda rainfall mean is not plausible.", call. = FALSE)
}
if (abs(difference_mm) > 0.1) {
  stop(sprintf("FAIL-CLOSED: Uganda cross-engine difference %.6f mm exceeds 0.1 mm.", difference_mm), call. = FALSE)
}
if (out$valid_data_fraction[[1]] < 0.99 || out$raster_coverage_fraction[[1]] < 0.99) {
  stop("FAIL-CLOSED: Uganda CHIRPS coverage is below the declared 0.99 gate.", call. = FALSE)
}
summary <- list(
  schema_version = "1.0",
  status = "passed",
  case = "Uganda CHIRPS 2023 source-derived second-country portability",
  source_url = sprintf("https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_annual/tifs/chirps-v2.0.%d.tif", year),
  boundary_source = "Natural Earth 1:110m Admin 0 - Countries",
  boundary_terms = "Public domain",
  configuration = "config/uganda-chirps-2023.json",
  output = sprintf("generated/uganda_chirps_%d.geojson", year),
  unit_id = "UGA",
  configured_surface_area_weighted_mean_mm = configured_mean,
  independent_terra_surface_area_weighted_mean_mm = terra_area_mean,
  configured_minus_independent_mm = difference_mm,
  raster_coverage_fraction = as.numeric(out$raster_coverage_fraction[[1]]),
  valid_within_raster_fraction = as.numeric(out$valid_within_raster_fraction[[1]]),
  valid_data_fraction = as.numeric(out$valid_data_fraction[[1]]),
  acceptance_gates = list(min_valid_data_fraction = 0.99, max_cross_engine_abs_difference_mm = 0.1),
  limitations = c(
    "This case demonstrates a source-derived environmental raster and source-derived second-country boundary through the generic configured workflow.",
    "Agreement is computational cross-validation and does not validate CHIRPS observational accuracy.",
    "The case is national-scale Uganda and does not establish every provider, geography, or downstream interpretation."
  )
)
json_path <- file.path(evidence_dir, sprintf("uganda_chirps_%d_validation_summary.json", year))
jsonlite::write_json(summary, json_path, pretty = TRUE, auto_unbox = TRUE, digits = 12)
cat(sprintf("[PASS] Uganda CHIRPS %d configured mean %.6f mm; terra cross-check %.6f mm; difference %.6f mm\n", year, configured_mean, terra_area_mean, difference_mm))
cat(sprintf("[PASS] coverage: raster %.6f; within-raster valid %.6f; overall valid %.6f\n", out$raster_coverage_fraction[[1]], out$valid_within_raster_fraction[[1]], out$valid_data_fraction[[1]]))
cat(sprintf("[WRITE] %s\n", normalizePath(json_path, winslash = "/", mustWork = TRUE)))
