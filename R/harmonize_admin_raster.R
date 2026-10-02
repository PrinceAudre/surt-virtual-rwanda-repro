#!/usr/bin/env Rscript
# SuRT-GeoHarmonizer generic administrative-unit raster interface.
#
# This sourceable module and command-line entry point converts one raster layer
# and one polygon boundary file into a provenance-labelled GeoJSON table. It is
# deliberately provider-agnostic. Provider-specific fetchers and scientific
# interpretation remain separate from this release-level harmonization step.
#
# Version 1.4 aggregation contract:
# - na_below / na_above are applied to RAW source raster values;
# - scale and offset are applied after raw-value masking;
# - finite cells are summarized with polygon-overlap x geodesic cell-area weights;
# - raster-footprint, within-raster finite-data, and overall valid-data coverage
#   fractions are reported separately for every administrative polygon.
#
# Example:
# Rscript R/harmonize_admin_raster.R \
#   --raster input.tif --boundaries units.geojson --id-field admin_id \
#   --value-name annual_rainfall_mm --output output.geojson \
#   --provenance "CHIRPS v2.0 annual 2023; public domain/CC0" \
#   --na-below 0 --round-digits 0 --min-value 0 --max-value 20000 \
#   --min-valid-fraction 0.95

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

surt_harmonizer_file <- tryCatch(
  normalizePath(sys.frame(1)$ofile, winslash = "/", mustWork = TRUE),
  error = function(error) ""
)
if (!nzchar(surt_harmonizer_file)) {
  file_arg <- grep("^--file=", commandArgs(), value = TRUE)
  if (length(file_arg)) {
    surt_harmonizer_file <- normalizePath(
      sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = FALSE
    )
  }
}
if (!nzchar(surt_harmonizer_file)) {
  surt_harmonizer_file <- normalizePath(
    file.path("R", "harmonize_admin_raster.R"), winslash = "/", mustWork = FALSE
  )
}
source(file.path(dirname(surt_harmonizer_file), "zonal_area_summary.R"))
rm(surt_harmonizer_file)

fail <- function(message) stop(sprintf("FAIL-CLOSED: %s", message), call. = FALSE)

as_optional_numeric <- function(value) {
  if (is.null(value) || !nzchar(value)) return(NA_real_)
  parsed <- suppressWarnings(as.numeric(value))
  if (length(parsed) != 1L || !is.finite(parsed))
    fail(sprintf("expected a finite numeric value, received '%s'", value))
  parsed
}

as_optional_integer <- function(value) {
  if (is.null(value) || !nzchar(value)) return(NA_integer_)
  if (!grepl("^[+-]?[0-9]+$", value))
    fail(sprintf("expected an integer value, received '%s'", value))
  parsed <- suppressWarnings(as.integer(value))
  if (length(parsed) != 1L || is.na(parsed))
    fail(sprintf("expected an integer value, received '%s'", value))
  parsed
}

parse_named_args <- function(args) {
  if (!length(args)) return(list())
  parsed <- list()
  index <- 1L
  while (index <= length(args)) {
    token <- args[[index]]
    if (!startsWith(token, "--")) fail(sprintf("unexpected argument '%s'", token))
    if (identical(token, "--help")) {
      parsed$help <- "true"
      index <- index + 1L
      next
    }
    if (index == length(args) || startsWith(args[[index + 1L]], "--"))
      fail(sprintf("missing value after '%s'", token))
    key <- gsub("-", "_", sub("^--", "", token))
    if (!is.null(parsed[[key]])) fail(sprintf("duplicate option '%s'", token))
    parsed[[key]] <- args[[index + 1L]]
    index <- index + 2L
  }
  parsed
}

usage <- function() {
  cat(paste0(
    "SuRT-GeoHarmonizer generic raster-to-administrative-unit interface\n\n",
    "Required options:\n",
    "  --raster PATH          Single- or multi-layer raster readable by terra\n",
    "  --boundaries PATH      Polygon vector file readable by sf\n",
    "  --id-field NAME        Unique non-empty non-geometry identifier column\n",
    "  --value-name NAME      Output measurement property name\n",
    "  --output PATH          Destination GeoJSON\n",
    "  --provenance TEXT      Human-readable source, method, period and terms\n\n",
    "Optional controls:\n",
    "  --layer INDEX_OR_NAME  Raster layer; default 1\n",
    "  --scale NUMBER         Multiplicative scale; default 1\n",
    "  --offset NUMBER        Additive offset; default 0\n",
    "  --na-below NUMBER      Mask RAW source values below this threshold\n",
    "  --na-above NUMBER      Mask RAW source values above this threshold\n",
    "  --round-digits INTEGER Round extracted values; omit for no rounding\n",
    "  --min-value NUMBER     Fail when any output is below this bound\n",
    "  --max-value NUMBER     Fail when any output is above this bound\n",
    "  --min-valid-fraction F Fail when overall valid-data fraction is < F;\n",
    "                         F must be between 0 and 1; default 0 (report only)\n"
  ))
}

harmonize_admin_raster <- function(
    raster_path,
    boundary_path,
    id_field,
    value_name,
    output_path,
    provenance,
    layer = 1L,
    scale = 1,
    offset = 0,
    na_below = NA_real_,
    na_above = NA_real_,
    round_digits = NA_integer_,
    min_value = NA_real_,
    max_value = NA_real_,
    min_valid_fraction = 0) {

  for (item in c(raster_path, boundary_path, id_field, value_name, output_path, provenance)) {
    if (is.null(item) || !nzchar(item)) fail("required arguments must be non-empty")
  }
  if (!file.exists(raster_path)) fail(sprintf("raster not found: %s", raster_path))
  if (!file.exists(boundary_path)) fail(sprintf("boundary file not found: %s", boundary_path))
  if (!grepl("^[A-Za-z][A-Za-z0-9_]*$", value_name))
    fail("value-name must begin with a letter and contain only letters, digits and underscores")
  reserved_names <- c(
    "unit_id", "provenance", "geometry", "raster_coverage_fraction",
    "valid_within_raster_fraction", "valid_data_fraction"
  )
  if (value_name %in% reserved_names)
    fail(sprintf("value-name '%s' is reserved by the output contract", value_name))
  if (!is.finite(scale) || !is.finite(offset)) fail("scale and offset must be finite")
  if (length(min_valid_fraction) != 1L || !is.finite(min_valid_fraction) ||
      min_valid_fraction < 0 || min_valid_fraction > 1)
    fail("min-valid-fraction must be a finite number between 0 and 1")
  if (!is.na(round_digits) &&
      (length(round_digits) != 1L || !is.finite(round_digits) ||
       round_digits != as.integer(round_digits)))
    fail("round-digits must be an integer")

  raster <- terra::rast(raster_path)
  if (is.character(layer) && grepl("^[0-9]+$", layer)) {
    layer <- as.integer(layer)
  } else if (is.numeric(layer)) {
    if (length(layer) != 1L || !is.finite(layer) || layer != as.integer(layer))
      fail("raster layer index must be an integer")
    layer <- as.integer(layer)
  }
  if (is.numeric(layer)) {
    if (layer < 1L || layer > terra::nlyr(raster)) fail("requested raster layer index is out of range")
    raster <- raster[[layer]]
  } else {
    if (length(layer) != 1L || !(layer %in% names(raster)))
      fail(sprintf("raster layer '%s' was not found", paste(layer, collapse = ",")))
    raster <- raster[[layer]]
  }
  if (!nzchar(terra::crs(raster, proj = TRUE))) fail("raster CRS is missing")

  # These masks intentionally operate in the source raster's raw units so they
  # can remove source-specific fill codes before scaling or unit conversion.
  if (is.finite(na_below)) raster[raster < na_below] <- NA
  if (is.finite(na_above)) raster[raster > na_above] <- NA
  raster <- raster * scale + offset

  boundaries <- sf::st_read(boundary_path, quiet = TRUE, stringsAsFactors = FALSE)
  if (!nrow(boundaries)) fail("boundary file contains no features")
  if (!(id_field %in% names(boundaries))) fail(sprintf("boundary file lacks id-field '%s'", id_field))
  geometry_column <- attr(boundaries, "sf_column")
  if (identical(id_field, geometry_column)) fail("id-field must name a non-geometry attribute column")
  if (is.na(sf::st_crs(boundaries))) fail("boundary CRS is missing")
  if (any(sf::st_geometry_type(boundaries) %in% c(
    "POINT", "MULTIPOINT", "LINESTRING", "MULTILINESTRING", "GEOMETRYCOLLECTION"
  ))) fail("all boundary features must be polygons or multipolygons")
  if (any(!sf::st_is_valid(boundaries))) fail("boundary geometry contains invalid features")

  ids <- trimws(as.character(boundaries[[id_field]]))
  if (any(is.na(ids)) || any(!nzchar(ids))) fail("administrative identifiers must be non-empty")
  if (anyDuplicated(ids)) fail("administrative identifiers must be unique")

  zonal <- surt_area_weighted_summary(raster, boundaries)
  values <- zonal$value
  if (length(values) != nrow(boundaries) || any(!is.finite(values)))
    fail("one or more administrative units received no finite raster value")
  if (any(!is.finite(zonal$valid_data_fraction)))
    fail("one or more administrative units received an undefined valid-data fraction")
  below_coverage <- which(zonal$valid_data_fraction + 1e-12 < min_valid_fraction)
  if (length(below_coverage)) {
    fail(sprintf(
      "valid-data fraction below minimum %.6g for: %s",
      min_valid_fraction,
      paste(sprintf("%s=%.6f", ids[below_coverage], zonal$valid_data_fraction[below_coverage]),
            collapse = ", ")
    ))
  }

  if (!is.na(round_digits)) values <- round(values, round_digits)
  if (is.finite(min_value) && any(values < min_value))
    fail(sprintf("one or more extracted values are below the minimum %s", min_value))
  if (is.finite(max_value) && any(values > max_value))
    fail(sprintf("one or more extracted values are above the maximum %s", max_value))

  output <- sf::st_transform(boundaries, 4326)
  output <- output[, id_field, drop = FALSE]
  names(output)[names(output) == id_field] <- "unit_id"
  output[[value_name]] <- as.numeric(values)
  output$raster_coverage_fraction <- as.numeric(zonal$raster_coverage_fraction)
  output$valid_within_raster_fraction <- as.numeric(zonal$valid_within_raster_fraction)
  output$valid_data_fraction <- as.numeric(zonal$valid_data_fraction)
  output$provenance <- provenance
  output <- output[, c(
    "unit_id", value_name, "raster_coverage_fraction",
    "valid_within_raster_fraction", "valid_data_fraction", "provenance"
  )]

  dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
  if (file.exists(output_path)) file.remove(output_path)
  sf::st_write(output, output_path, driver = "GeoJSON", quiet = TRUE)
  if (!file.exists(output_path) || file.size(output_path) == 0)
    fail("GeoJSON output was not written")

  cat(sprintf(
    paste0(
      "SuRT-GeoHarmonizer: %d units | %s %.6g to %.6g | ",
      "valid-data fraction %.4f to %.4f | %s\n"
    ),
    nrow(output), value_name, min(values), max(values),
    min(zonal$valid_data_fraction), max(zonal$valid_data_fraction), output_path
  ))
  invisible(output)
}

main <- function() {
  args <- parse_named_args(commandArgs(trailingOnly = TRUE))
  if (identical(args$help, "true")) {
    usage()
    return(invisible(NULL))
  }
  required <- c("raster", "boundaries", "id_field", "value_name", "output", "provenance")
  missing <- required[vapply(required, function(key) is.null(args[[key]]) || !nzchar(args[[key]]), logical(1))]
  if (length(missing)) {
    usage()
    fail(sprintf("missing required options: %s", paste(missing, collapse = ", ")))
  }

  layer <- if (is.null(args$layer)) 1L else args$layer
  harmonize_admin_raster(
    raster_path = args$raster,
    boundary_path = args$boundaries,
    id_field = args$id_field,
    value_name = args$value_name,
    output_path = args$output,
    provenance = args$provenance,
    layer = layer,
    scale = if (is.null(args$scale)) 1 else as_optional_numeric(args$scale),
    offset = if (is.null(args$offset)) 0 else as_optional_numeric(args$offset),
    na_below = as_optional_numeric(args$na_below),
    na_above = as_optional_numeric(args$na_above),
    round_digits = as_optional_integer(args$round_digits),
    min_value = as_optional_numeric(args$min_value),
    max_value = as_optional_numeric(args$max_value),
    min_valid_fraction = if (is.null(args$min_valid_fraction)) 0 else
      as_optional_numeric(args$min_valid_fraction)
  )
}

if (sys.nframe() == 0L) main()
