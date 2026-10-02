#!/usr/bin/env Rscript
# relief_low_lying_transform.R - HAND-derived descriptive terrain helpers.
#
# The metric is deliberately narrow: the percentage of VALID HAND-covered area
# at or below a selected HAND threshold. No-data is unknown and is excluded from
# the threshold-share denominator, while valid HAND area coverage is reported
# separately. The result is a static terrain descriptor, not observed flooding,
# flood probability, a hazard model, a forecast, or a disease output.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

# Reuse the shared v1.4 footprint/coverage contract. This avoids mixing one
# geometry-area engine for polygon denominators with a different cell-area engine
# for valid raster support.
if (!exists("surt_raster_coverage_fraction", mode = "function")) {
  .hand_file <- tryCatch(
    normalizePath(sys.frame(1)$ofile, winslash = "/", mustWork = TRUE),
    error = function(error) ""
  )
  if (!nzchar(.hand_file)) {
    .file_arg <- grep("^--file=", commandArgs(), value = TRUE)
    .hand_file <- if (length(.file_arg))
      normalizePath(sub("^--file=", "", .file_arg[[1]]), winslash = "/", mustWork = FALSE) else
      normalizePath(file.path("R", "relief_low_lying_transform.R"), winslash = "/", mustWork = FALSE)
  }
  source(file.path(dirname(.hand_file), "zonal_area_summary.R"))
  rm(.hand_file)
  if (exists(".file_arg")) rm(.file_arg)
}

hand_clamp_fraction <- function(x) {
  pmin(1, pmax(0, as.numeric(x)))
}

# Return auditable HAND area quantities for each polygon.
#
# `low_lying_share_pct` = 100 * threshold_area_m2 / valid_hand_area_m2.
# Negative HAND sentinels are masked before aggregation. Cell contributions are
# weighted by both polygon-cell overlap fraction and square-metre cell area.
# Coverage follows the same three-part contract as the generic harmonizer:
# raster footprint coverage, valid HAND fraction within that footprint, and
# overall valid-data fraction of the polygon. `valid_hand_area_fraction` is kept
# as a semantic alias of `valid_data_fraction` for backward compatibility.
low_lying_summary <- function(hand, d, threshold_m = 5) {
  if (!is.finite(threshold_m) || threshold_m < 0) {
    stop("FAIL-CLOSED: HAND threshold must be a finite non-negative value.")
  }
  if (terra::nlyr(hand) != 1L) {
    stop("FAIL-CLOSED: HAND summary requires exactly one raster layer.")
  }
  raster_crs <- sf::st_crs(terra::crs(hand, proj = TRUE))
  if (is.na(raster_crs)) {
    stop("FAIL-CLOSED: HAND raster CRS is missing.")
  }
  if (is.na(sf::st_crs(d))) {
    stop("FAIL-CLOSED: HAND boundary CRS is missing.")
  }

  hand <- terra::ifel(hand < 0, NA, hand)
  transformed <- sf::st_transform(d, raster_crs)
  cell_area <- terra::cellSize(hand, mask = FALSE, unit = "m", transform = TRUE)
  extracted <- exactextractr::exact_extract(
    hand,
    transformed,
    weights = cell_area,
    fun = function(values, coverage_fraction, weights) {
      touched <- is.finite(coverage_fraction) & coverage_fraction > 0 &
        is.finite(weights) & weights > 0
      if (!any(touched)) {
        return(data.frame(
          low_lying_share_pct = NA_real_,
          threshold_area_m2 = 0,
          valid_hand_area_m2 = 0,
          raster_covered_area_m2 = 0,
          valid_within_raster_fraction = 0
        ))
      }

      values <- values[touched]
      area_weights <- coverage_fraction[touched] * weights[touched]
      raster_covered_area <- sum(area_weights)
      valid <- is.finite(values)
      valid_area <- sum(area_weights[valid])
      if (!is.finite(valid_area) || valid_area <= 0) {
        return(data.frame(
          low_lying_share_pct = NA_real_,
          threshold_area_m2 = 0,
          valid_hand_area_m2 = 0,
          raster_covered_area_m2 = raster_covered_area,
          valid_within_raster_fraction = 0
        ))
      }

      threshold_area <- sum(area_weights[valid & values <= threshold_m])
      data.frame(
        low_lying_share_pct = 100 * threshold_area / valid_area,
        threshold_area_m2 = threshold_area,
        valid_hand_area_m2 = valid_area,
        raster_covered_area_m2 = raster_covered_area,
        valid_within_raster_fraction = valid_area / raster_covered_area
      )
    },
    progress = FALSE
  )

  if (!is.data.frame(extracted) || nrow(extracted) != nrow(d)) {
    stop("FAIL-CLOSED: HAND extraction returned an unexpected result shape.")
  }
  if (any(!is.finite(extracted$low_lying_share_pct))) {
    stop("FAIL-CLOSED: a polygon got no valid HAND value (CRS / coverage / no-data problem).")
  }

  extracted$raster_coverage_fraction <- hand_clamp_fraction(
    surt_raster_coverage_fraction(hand, transformed)
  )
  extracted$valid_within_raster_fraction <- hand_clamp_fraction(
    extracted$valid_within_raster_fraction
  )
  extracted$valid_data_fraction <- hand_clamp_fraction(
    extracted$raster_coverage_fraction * extracted$valid_within_raster_fraction
  )
  extracted$valid_hand_area_fraction <- extracted$valid_data_fraction
  extracted$low_lying_share_pct <- as.numeric(extracted$low_lying_share_pct)

  extracted[, c(
    "low_lying_share_pct",
    "threshold_area_m2",
    "valid_hand_area_m2",
    "raster_coverage_fraction",
    "valid_within_raster_fraction",
    "valid_data_fraction",
    "valid_hand_area_fraction"
  )]
}

# Compatibility wrapper for callers that only need the threshold-share vector.
# New production code should retain the coverage columns from low_lying_summary().
low_lying_share <- function(hand, d, threshold_m = 5) {
  round(low_lying_summary(hand, d, threshold_m)$low_lying_share_pct, 1)
}

# Point-on-surface longitudes for the east/west direction check.
low_lying_district_lon <- function(d) {
  points <- suppressWarnings(sf::st_point_on_surface(sf::st_geometry(d)))
  sf::st_coordinates(points)[, 1]
}

# Broad consistency tripwire, not independent numerical validation.
low_lying_consistency_gate <- function(district, low_lying_share_pct, lon,
                                       band = c(0, 100), margin = 3) {
  bad <- which(low_lying_share_pct < band[1] | low_lying_share_pct > band[2])
  if (length(bad)) {
    stop(sprintf(
      "FAIL-CLOSED: low-lying share outside the valid %d-%d %% range: %s",
      band[1], band[2],
      paste(sprintf("%s=%.1f", district[bad], low_lying_share_pct[bad]), collapse = ", ")
    ))
  }
  east <- low_lying_share_pct[lon >= stats::quantile(lon, 2 / 3)]
  west <- low_lying_share_pct[lon <= stats::quantile(lon, 1 / 3)]
  if (!length(east) || !length(west)) {
    stop("FAIL-CLOSED: low-lying-share gate could not split east/west districts by longitude.")
  }
  if (!(mean(east) > mean(west) + margin)) {
    stop(sprintf(
      paste0(
        "FAIL-CLOSED: consistency check violated - eastern districts (mean %.1f%%) ",
        "do not exceed western districts (mean %.1f%%) by %d points."
      ),
      mean(east), mean(west), margin
    ))
  }
  invisible(c(east = mean(east), west = mean(west)))
}
