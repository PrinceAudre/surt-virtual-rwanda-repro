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

hand_clamp_fraction <- function(x) {
  pmin(1, pmax(0, as.numeric(x)))
}

hand_polygon_area_m2 <- function(polygons) {
  vapply(seq_len(nrow(polygons)), function(i) {
    geom <- sf::st_geometry(polygons[i, , drop = FALSE])
    as.numeric(sum(sf::st_area(sf::st_transform(geom, 4326))))
  }, numeric(1))
}

# Return auditable HAND area quantities for each polygon.
#
# `low_lying_share_pct` = 100 * threshold_area_m2 / valid_hand_area_m2.
# Negative HAND sentinels are masked before aggregation. Cell contributions are
# weighted by both polygon-cell overlap fraction and square-metre cell area.
# `valid_hand_area_fraction` reports valid HAND area divided by total polygon
# area, so users can distinguish a finite threshold share from complete coverage.
low_lying_summary <- function(hand, d, threshold_m = 5) {
  if (!is.finite(threshold_m) || threshold_m < 0) {
    stop("FAIL-CLOSED: HAND threshold must be a finite non-negative value.")
  }
  if (terra::nlyr(hand) != 1L) {
    stop("FAIL-CLOSED: HAND summary requires exactly one raster layer.")
  }
  if (!nzchar(terra::crs(hand, proj = TRUE))) {
    stop("FAIL-CLOSED: HAND raster CRS is missing.")
  }
  if (is.na(sf::st_crs(d))) {
    stop("FAIL-CLOSED: HAND boundary CRS is missing.")
  }

  hand <- terra::ifel(hand < 0, NA, hand)
  transformed <- sf::st_transform(d, terra::crs(hand, proj = TRUE))
  polygon_area <- hand_polygon_area_m2(transformed)
  if (any(!is.finite(polygon_area)) || any(polygon_area <= 0)) {
    stop("FAIL-CLOSED: one or more HAND polygons have non-positive area.")
  }

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
          raster_covered_area_m2 = 0
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
          raster_covered_area_m2 = raster_covered_area
        ))
      }

      threshold_area <- sum(area_weights[valid & values <= threshold_m])
      data.frame(
        low_lying_share_pct = 100 * threshold_area / valid_area,
        threshold_area_m2 = threshold_area,
        valid_hand_area_m2 = valid_area,
        raster_covered_area_m2 = raster_covered_area
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
    extracted$raster_covered_area_m2 / polygon_area
  )
  extracted$valid_hand_area_fraction <- hand_clamp_fraction(
    extracted$valid_hand_area_m2 / polygon_area
  )
  extracted$low_lying_share_pct <- as.numeric(extracted$low_lying_share_pct)

  extracted[, c(
    "low_lying_share_pct",
    "threshold_area_m2",
    "valid_hand_area_m2",
    "raster_coverage_fraction",
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
