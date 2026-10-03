#!/usr/bin/env Rscript
# Limited independent real-data check of the HAND threshold-share contract.
# Production uses exactextractr; the cross-check recomputes the same estimand
# with terra exact polygon-cell fractions and square-metre cell areas.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(jsonlite)
  library(exactextractr)
}))

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1]]) else "R/validate_hand_rubavu_real.R"
root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
source(file.path(root, "R", "relief_low_lying_transform.R"))

threshold_m <- 5
district_name <- "Rubavu"
source_url <- paste0(
  "https://glo-30-hand.s3.amazonaws.com/v1/2021/",
  "Copernicus_DSM_COG_10_S02_00_E029_00_HAND.tif"
)
cache_dir <- file.path(root, "cache", "hand_validation")
source_path <- file.path(cache_dir, basename(source_url))
evidence_dir <- file.path(root, "generated", "hand_validation")
dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(evidence_dir, recursive = TRUE, showWarnings = FALSE)
if (!file.exists(source_path) || file.size(source_path) < 1e6) {
  options(timeout = max(getOption("timeout"), 1200))
  cat(sprintf("Fetching public HAND tile for %s...\n", district_name))
  ok <- tryCatch({
    utils::download.file(source_url, source_path, mode = "wb", quiet = TRUE)
    file.exists(source_path) && file.size(source_path) > 1e6
  }, error = function(error) {
    cat("download error:", conditionMessage(error), "\n")
    FALSE
  })
  if (!ok) {
    if (file.exists(source_path)) file.remove(source_path)
    stop("FAIL-CLOSED: public HAND validation tile download failed.", call. = FALSE)
  }
}

boundaries <- sf::st_read(file.path(root, "data", "relief_districts.geojson"), quiet = TRUE)
d <- boundaries[as.character(boundaries$district) == district_name, ]
if (nrow(d) != 1L) stop("FAIL-CLOSED: expected exactly one Rubavu polygon.", call. = FALSE)

hand <- terra::rast(source_path)
if (terra::nlyr(hand) != 1L) stop("FAIL-CLOSED: HAND tile must contain one layer.", call. = FALSE)
if (is.na(sf::st_crs(terra::crs(hand, proj = TRUE)))) stop("FAIL-CLOSED: HAND tile CRS missing.", call. = FALSE)

d_raster <- sf::st_transform(d, sf::st_crs(terra::crs(hand, proj = TRUE)))
hand <- terra::crop(hand, terra::ext(terra::vect(d_raster)), snap = "out")

production <- low_lying_summary(hand, d, threshold_m = threshold_m)
if (nrow(production) != 1L) stop("FAIL-CLOSED: production HAND summary shape is invalid.", call. = FALSE)
hand_masked <- terra::ifel(hand < 0, NA, hand)
x <- terra::extract(hand_masked, terra::vect(d_raster), exact = TRUE, cells = TRUE, ID = FALSE)
value_cols <- setdiff(names(x), c("cell", "fraction"))
if (length(value_cols) != 1L || !all(c("cell", "fraction") %in% names(x))) {
  stop("FAIL-CLOSED: terra HAND extraction returned an unexpected schema.", call. = FALSE)
}
cell_area <- terra::cellSize(hand_masked, mask = FALSE, unit = "m", transform = TRUE)
area_m2 <- terra::values(cell_area, mat = FALSE)[x$cell]
values_x <- as.numeric(x[[value_cols[[1]]]])
weights <- as.numeric(x$fraction) * as.numeric(area_m2)
touched <- is.finite(weights) & weights > 0
valid <- touched & is.finite(values_x)
if (!any(valid)) stop("FAIL-CLOSED: independent HAND check found no finite Rubavu cells.", call. = FALSE)

raster_covered_area_m2 <- sum(weights[touched])
valid_hand_area_m2 <- sum(weights[valid])
threshold_area_m2 <- sum(weights[valid & values_x <= threshold_m])
independent_share_pct <- 100 * threshold_area_m2 / valid_hand_area_m2
independent_valid_within <- valid_hand_area_m2 / raster_covered_area_m2

share_difference_pp <- as.numeric(production$low_lying_share_pct[[1]]) - independent_share_pct
valid_within_difference <- as.numeric(production$valid_within_raster_fraction[[1]]) - independent_valid_within
if (abs(share_difference_pp) > 0.01) {
  stop(sprintf("FAIL-CLOSED: HAND share cross-engine difference %.6f pp exceeds 0.01 pp.", share_difference_pp), call. = FALSE)
}
if (abs(valid_within_difference) > 1e-5) {
  stop(sprintf("FAIL-CLOSED: HAND valid-within-raster difference %.8f exceeds 1e-5.", valid_within_difference), call. = FALSE)
}
if (production$raster_coverage_fraction[[1]] < 0.999) {
  stop("FAIL-CLOSED: selected Rubavu district is not fully covered by the validation tile.", call. = FALSE)
}

summary <- list(
  schema_version = "1.0",
  status = "passed",
  case = "Rubavu public HAND 30 m real-data numerical cross-check",
  district = district_name,
  threshold_m = threshold_m,
  source_url = source_url,
  source_terms = "CC0 1.0 Public Domain",
  production_exactextractr_share_pct = as.numeric(production$low_lying_share_pct[[1]]),
  independent_terra_share_pct = independent_share_pct,
  production_minus_independent_share_pp = share_difference_pp,
  production_raster_coverage_fraction = as.numeric(production$raster_coverage_fraction[[1]]),
  production_valid_within_raster_fraction = as.numeric(production$valid_within_raster_fraction[[1]]),
  independent_valid_within_raster_fraction = independent_valid_within,
  production_valid_data_fraction = as.numeric(production$valid_data_fraction[[1]]),
  production_threshold_area_m2 = as.numeric(production$threshold_area_m2[[1]]),
  independent_threshold_area_m2 = threshold_area_m2,
  production_valid_hand_area_m2 = as.numeric(production$valid_hand_area_m2[[1]]),
  independent_valid_hand_area_m2 = valid_hand_area_m2,
  acceptance_gates = list(max_share_difference_pp = 0.01, max_valid_within_difference = 1e-5),
  limitation = "Computational cross-validation of one public HAND tile and district; not validation of HAND terrain accuracy or flood hazard."
)
json_path <- file.path(evidence_dir, "rubavu_hand_real_validation_summary.json")
jsonlite::write_json(summary, json_path, pretty = TRUE, auto_unbox = TRUE, digits = 12)
cat(sprintf(
  "[PASS] Rubavu HAND <= %.1f m: exactextractr %.6f%%; terra %.6f%%; difference %.6f pp\n",
  threshold_m, production$low_lying_share_pct[[1]], independent_share_pct, share_difference_pp
))
cat(sprintf(
  "[PASS] coverage: raster %.6f; valid within raster %.6f; overall valid %.6f\n",
  production$raster_coverage_fraction[[1]],
  production$valid_within_raster_fraction[[1]],
  production$valid_data_fraction[[1]]
))
cat(sprintf("[WRITE] %s\n", normalizePath(json_path, winslash = "/", mustWork = TRUE)))
