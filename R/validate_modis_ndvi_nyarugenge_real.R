#!/usr/bin/env Rscript
# Independent real-data check of MOD13A3 v061 NDVI subdataset selection,
# raw-DN scaling, pixel-reliability QA, annual aggregation, and district result.
# This validator deliberately does not source the production NDVI helper.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(jsonlite)
}))

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1]]) else
  "R/validate_modis_ndvi_nyarugenge_real.R"
root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
year <- 2023L
district_name <- "Nyarugenge"
accepted_quality <- 0L
min_valid_month_fraction <- 0.5
cache_dir <- file.path(root, "cache", "modis_ndvi", sprintf("mod13a3_%d", year))
production_path <- file.path(root, "generated", "relief_climate_ndvi_v14_real.geojson")
evidence_dir <- file.path(root, "generated", "modis_validation")
dir.create(evidence_dir, recursive = TRUE, showWarnings = FALSE)
hdfs <- sort(list.files(cache_dir, pattern = "\\.hdf$", full.names = TRUE, ignore.case = TRUE))
if (length(hdfs) != 24L) {
  stop(sprintf("FAIL-CLOSED: expected 24 MOD13A3 HDF granules, found %d.", length(hdfs)), call. = FALSE)
}
month_key <- function(path) {
  hit <- regmatches(basename(path), regexpr("A[0-9]{7}", basename(path)))
  if (!length(hit) || !nzchar(hit)) stop("FAIL-CLOSED: MOD13A3 month key missing.", call. = FALSE)
  hit
}
tile_key <- function(path) {
  hit <- regmatches(basename(path), regexpr("h[0-9]{2}v[0-9]{2}", basename(path)))
  if (!length(hit) || !nzchar(hit)) stop("FAIL-CLOSED: MOD13A3 tile key missing.", call. = FALSE)
  hit
}
months <- unique(vapply(hdfs, month_key, character(1)))
tiles <- sort(unique(vapply(hdfs, tile_key, character(1))))
if (length(months) != 12L || !identical(tiles, c("h20v09", "h21v09"))) {
  stop(sprintf("FAIL-CLOSED: expected 12 months x h20v09/h21v09; got %d months and {%s}.",
               length(months), paste(tiles, collapse = ",")), call. = FALSE)
}
if (any(table(vapply(hdfs, month_key, character(1))) != 2L)) {
  stop("FAIL-CLOSED: every MOD13A3 month must contain exactly two covering tiles.", call. = FALSE)
}
open_raw_sds <- function(path, variable) {
  sds <- terra::describe(path, sds = TRUE)
  if (!is.data.frame(sds) || !all(c("name", "var") %in% names(sds))) {
    stop(sprintf("FAIL-CLOSED: cannot enumerate HDF subdatasets in %s.", basename(path)), call. = FALSE)
  }
  target <- which(gsub('^"|"$', "", as.character(sds$var)) == variable)
  if (length(target) != 1L) {
    stop(sprintf("FAIL-CLOSED: expected one '%s' SDS in %s; found %d.",
                 variable, basename(path), length(target)), call. = FALSE)
  }
  r <- tryCatch(terra::rast(as.character(sds$name[[target]]), raw = TRUE),
                error = function(error) NULL)
  if (is.null(r) || terra::nlyr(r) != 1L) {
    stop(sprintf("FAIL-CLOSED: cannot open raw '%s' SDS in %s.", variable, basename(path)), call. = FALSE)
  }
  r
}

independent_month <- function(paths) {
  transformed <- lapply(paths, function(path) {
    raw_ndvi <- open_raw_sds(path, "1 km monthly NDVI")
    raw_qa <- open_raw_sds(path, "1 km monthly pixel reliability")
    if (!terra::compareGeom(raw_ndvi, raw_qa, stopOnError = FALSE,
                            crs = TRUE, ext = TRUE, rowcol = TRUE, res = TRUE)) {
      stop("FAIL-CLOSED: raw MOD13A3 NDVI and QA geometry differ.", call. = FALSE)
    }
    # Documented MOD13A3 v061 contract: NDVI DN [-2000,10000], scale 0.0001;
    # pixel reliability 0 = Good Data. Filtering is applied before aggregation.
    valid_dn <- raw_ndvi >= -2000 & raw_ndvi <= 10000
    good_qa <- raw_qa == accepted_quality
    terra::ifel(valid_dn & good_qa, raw_ndvi * 0.0001, NA)
  })
  if (length(transformed) != 2L) stop("FAIL-CLOSED: monthly tile count changed.", call. = FALSE)
  terra::mosaic(transformed[[1]], transformed[[2]], fun = "mean")
}

monthly <- lapply(months, function(month) {
  paths <- hdfs[vapply(hdfs, month_key, character(1)) == month]
  independent_month(paths)
})
stack <- terra::rast(monthly)
if (terra::nlyr(stack) != 12L) stop("FAIL-CLOSED: independent annual stack is not 12 months.", call. = FALSE)
valid_month_fraction_native <- terra::app(stack, fun = function(x) sum(is.finite(x)) / 12)
annual_native <- terra::app(stack, fun = function(x) {
  if (!any(is.finite(x))) return(NA_real_)
  mean(x[is.finite(x)])
})
annual_native <- terra::ifel(valid_month_fraction_native >= min_valid_month_fraction,
                             annual_native, NA)
annual <- terra::project(annual_native, "EPSG:4326")
valid_month_fraction <- terra::project(valid_month_fraction_native, "EPSG:4326", method = "bilinear")
boundaries <- sf::st_read(file.path(root, "data", "relief_districts.geojson"), quiet = TRUE)
d <- boundaries[as.character(boundaries$district) == district_name, ]
if (nrow(d) != 1L) stop("FAIL-CLOSED: expected exactly one Nyarugenge polygon.", call. = FALSE)

terra_area_summary <- function(r, polygon) {
  polygon_r <- sf::st_transform(polygon, sf::st_crs(terra::crs(r, proj = TRUE)))
  x <- terra::extract(r, terra::vect(polygon_r), exact = TRUE, cells = TRUE, ID = FALSE)
  value_cols <- setdiff(names(x), c("cell", "fraction"))
  if (length(value_cols) != 1L || !all(c("cell", "fraction") %in% names(x))) {
    stop("FAIL-CLOSED: independent terra extraction schema changed.", call. = FALSE)
  }
  cell_area <- terra::cellSize(r, mask = FALSE, unit = "m", transform = TRUE)
  area_m2 <- terra::values(cell_area, mat = FALSE)[x$cell]
  values_x <- as.numeric(x[[value_cols[[1]]]])
  weights <- as.numeric(x$fraction) * as.numeric(area_m2)
  touched <- is.finite(weights) & weights > 0
  valid <- touched & is.finite(values_x)
  if (!any(valid)) stop("FAIL-CLOSED: independent terra summary has no finite cells.", call. = FALSE)
  list(
    mean = sum(values_x[valid] * weights[valid]) / sum(weights[valid]),
    valid_area_m2 = sum(weights[valid]),
    covered_area_m2 = sum(weights[touched]),
    valid_fraction = sum(weights[valid]) / sum(weights[touched])
  )
}
independent_ndvi <- terra_area_summary(annual, d)
independent_month_fraction <- terra_area_summary(valid_month_fraction, d)

if (!file.exists(production_path)) {
  stop(sprintf("FAIL-CLOSED: production MODIS output missing: %s", production_path), call. = FALSE)
}
production <- sf::st_read(production_path, quiet = TRUE)
p <- production[as.character(production$district) == district_name, ]
if (nrow(p) != 1L) stop("FAIL-CLOSED: production output lacks one Nyarugenge record.", call. = FALSE)

mean_difference <- as.numeric(p$mean_ndvi[[1]]) - independent_ndvi$mean
area_fraction_difference <- as.numeric(p$valid_ndvi_area_fraction[[1]]) - independent_ndvi$valid_fraction
month_fraction_difference <- as.numeric(p$mean_valid_month_fraction[[1]]) - independent_month_fraction$mean
if (!identical(round(independent_ndvi$mean, 2), as.numeric(p$mean_ndvi[[1]]))) {
  stop(sprintf("FAIL-CLOSED: production NDVI %.2f != independently rounded %.2f.",
               p$mean_ndvi[[1]], round(independent_ndvi$mean, 2)), call. = FALSE)
}
if (abs(area_fraction_difference) > 5.1e-5) {
  stop(sprintf("FAIL-CLOSED: valid-area fraction difference %.8f exceeds rounding tolerance.",
               area_fraction_difference), call. = FALSE)
}
if (abs(month_fraction_difference) > 5.1e-5) {
  stop(sprintf("FAIL-CLOSED: mean valid-month fraction difference %.8f exceeds rounding tolerance.",
               month_fraction_difference), call. = FALSE)
}
sample_ndvi <- open_raw_sds(hdfs[[1]], "1 km monthly NDVI")
sample_qa <- open_raw_sds(hdfs[[1]], "1 km monthly pixel reliability")
raw_values <- terra::values(sample_ndvi, mat = FALSE)
qa_values <- terra::values(sample_qa, mat = FALSE)
sample_candidates <- which(is.finite(raw_values) & raw_values >= -2000 & raw_values <= 10000 & qa_values == 0L)
if (!length(sample_candidates)) {
  stop("FAIL-CLOSED: no QA=0 valid-DN sample found in first source granule.", call. = FALSE)
}
sample_cell <- sample_candidates[[1]]
sample_raw_dn <- as.numeric(raw_values[[sample_cell]])
sample_qa_rank <- as.integer(qa_values[[sample_cell]])
sample_scaled_ndvi <- sample_raw_dn * 0.0001
if (!is.finite(sample_scaled_ndvi) || sample_scaled_ndvi < -0.2 || sample_scaled_ndvi > 1) {
  stop("FAIL-CLOSED: selected MOD13A3 scaled sample is outside documented NDVI range.", call. = FALSE)
}

sha256_file <- function(path) {
  sha256sum <- Sys.which("sha256sum")
  if (nzchar(sha256sum)) {
    out <- system2(sha256sum, shQuote(path), stdout = TRUE, stderr = TRUE)
    status <- attr(out, "status")
    if (is.null(status) || identical(status, 0L)) {
      hash <- strsplit(trimws(out[[1]]), "[[:space:]]+")[[1]][[1]]
      if (grepl("^[0-9a-fA-F]{64}$", hash)) return(tolower(hash))
    }
  }
  shasum <- Sys.which("shasum")
  if (nzchar(shasum)) {
    out <- system2(shasum, c("-a", "256", shQuote(path)), stdout = TRUE, stderr = TRUE)
    status <- attr(out, "status")
    if (is.null(status) || identical(status, 0L)) {
      hash <- strsplit(trimws(out[[1]]), "[[:space:]]+")[[1]][[1]]
      if (grepl("^[0-9a-fA-F]{64}$", hash)) return(tolower(hash))
    }
  }
  certutil <- Sys.which("certutil")
  if (nzchar(certutil)) {
    out <- system2(certutil, c("-hashfile", shQuote(path), "SHA256"), stdout = TRUE, stderr = TRUE)
    candidates <- gsub("[[:space:]]", "", out)
    candidates <- candidates[grepl("^[0-9a-fA-F]{64}$", candidates)]
    if (length(candidates) == 1L) return(tolower(candidates[[1]]))
  }
  stop(sprintf("FAIL-CLOSED: no working SHA-256 utility found for %s.", basename(path)), call. = FALSE)
}

source_info <- data.frame(
  file = unname(basename(hdfs)),
  bytes = unname(as.numeric(file.info(hdfs)$size)),
  sha256 = unname(vapply(hdfs, sha256_file, character(1))),
  month = unname(vapply(hdfs, month_key, character(1))),
  tile = unname(vapply(hdfs, tile_key, character(1))),
  stringsAsFactors = FALSE,
  row.names = seq_along(hdfs)
)
source_manifest <- paste(source_info$file, source_info$bytes, source_info$sha256, sep = "|", collapse = "\n")
manifest_path <- tempfile(fileext = ".txt")
writeBin(charToRaw(enc2utf8(source_manifest)), manifest_path)
source_set_sha256 <- sha256_file(manifest_path)
unlink(manifest_path)
summary <- list(
  schema_version = "1.0",
  status = "passed",
  case = "Nyarugenge MOD13A3 v061 2023 real-data numerical cross-check",
  district = district_name,
  year = year,
  product = "MODIS/Terra MOD13A3 v061",
  product_doi = "10.5067/MODIS/MOD13A3.061",
  granule_count = length(hdfs),
  months = length(months),
  tiles = tiles,
  source_granules = source_info,
  source_set_sha256 = source_set_sha256,
  source_acquisition = "python/fetch_modis_ndvi.py via NASA earthaccess; credentials remain external to the repository",
  ndvi_subdataset = "1 km monthly NDVI",
  qa_subdataset = "1 km monthly pixel reliability",
  raw_valid_dn_range = c(-2000L, 10000L),
  scale_factor = 0.0001,
  accepted_pixel_reliability = accepted_quality,
  min_valid_month_fraction = min_valid_month_fraction,
  sample = list(source_granule = basename(hdfs[[1]]), cell = sample_cell,
                raw_ndvi_dn = sample_raw_dn, pixel_reliability = sample_qa_rank,
                scaled_ndvi = sample_scaled_ndvi),
  production_reported_mean_ndvi = as.numeric(p$mean_ndvi[[1]]),
  independent_terra_area_weighted_mean_ndvi = independent_ndvi$mean,
  production_minus_independent_mean = mean_difference,
  production_valid_ndvi_area_fraction = as.numeric(p$valid_ndvi_area_fraction[[1]]),
  independent_valid_ndvi_area_fraction = independent_ndvi$valid_fraction,
  production_minus_independent_valid_area_fraction = area_fraction_difference,
  production_mean_valid_month_fraction = as.numeric(p$mean_valid_month_fraction[[1]]),
  independent_mean_valid_month_fraction = independent_month_fraction$mean,
  production_minus_independent_month_fraction = month_fraction_difference,
  acceptance_gates = list(
    mean_must_match_after_rounding_to_2_decimals = TRUE,
    max_coverage_difference = 5.1e-5
  ),
  validator = "R/validate_modis_ndvi_nyarugenge_real.R",
  production_builder = "R/build_relief_climate_ndvi_real.R",
  limitation = paste(
    "Computational cross-validation of one district and one year using source HDF granules;",
    "not validation of MOD13A3 observational accuracy or ecological interpretation."
  )
)
json_path <- file.path(evidence_dir, "nyarugenge_mod13a3_2023_validation_summary.json")
jsonlite::write_json(summary, json_path, pretty = TRUE, auto_unbox = TRUE, digits = 12)
cat(sprintf("[PASS] MOD13A3 raw sample: DN %.0f, QA %d, scaled NDVI %.4f\n",
            sample_raw_dn, sample_qa_rank, sample_scaled_ndvi))
cat(sprintf("[PASS] Nyarugenge annual NDVI: production %.2f; independent %.8f; delta %.8f\n",
            p$mean_ndvi[[1]], independent_ndvi$mean, mean_difference))
cat(sprintf("[PASS] valid NDVI area fraction: production %.4f; independent %.8f\n",
            p$valid_ndvi_area_fraction[[1]], independent_ndvi$valid_fraction))
cat(sprintf("[PASS] mean valid-month fraction: production %.4f; independent %.8f\n",
            p$mean_valid_month_fraction[[1]], independent_month_fraction$mean))
cat(sprintf("[WRITE] %s\n", normalizePath(json_path, winslash = "/", mustWork = TRUE)))
