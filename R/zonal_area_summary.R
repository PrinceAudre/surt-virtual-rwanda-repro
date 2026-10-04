#!/usr/bin/env Rscript
# Shared zonal-summary primitives for SuRT-GeoHarmonizer v1.4.0.
#
# The public contract separates three quantities that were previously conflated:
# 1. how much of a polygon intersects the raster footprint;
# 2. how much of the raster-covered polygon has finite values; and
# 3. the surface-area-weighted value summary over those finite values.
#
# terra::cellSize(..., transform = TRUE) supplies square-metre surface-area
# weights for both longitude/latitude and projected rasters. exactextractr then
# multiplies those cell areas by polygon-cell coverage fractions.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

surt_clamp_fraction <- function(x) {
  pmin(1, pmax(0, as.numeric(x)))
}

surt_raster_footprint <- function(raster) {
  raster_crs <- sf::st_crs(terra::crs(raster, proj = TRUE))
  if (is.na(raster_crs)) stop("Raster CRS is required for footprint coverage.")

  bbox_values <- c(
    xmin = terra::xmin(raster),
    ymin = terra::ymin(raster),
    xmax = terra::xmax(raster),
    ymax = terra::ymax(raster)
  )
  if (length(bbox_values) != 4L || any(!is.finite(bbox_values))) {
    stop("Raster extent contains non-finite coordinates.")
  }

  # Some global geographic GeoTIFFs encode an extent a few floating-point units
  # beyond +/-180 or +/-90. Normalize only tiny coordinate spill relative to the
  # raster resolution; larger excursions remain untouched.
  if (isTRUE(sf::st_is_longlat(raster_crs))) {
    raster_res <- abs(terra::res(raster))
    lon_tol <- max(1e-8, raster_res[[1]] * 1e-3)
    lat_tol <- max(1e-8, raster_res[[2]] * 1e-3)
    lon_span <- bbox_values[["xmax"]] - bbox_values[["xmin"]]

    if (is.finite(lon_span) && abs(lon_span - 360) <= 2 * lon_tol) {
      bbox_values[["xmin"]] <- -180
      bbox_values[["xmax"]] <- 180
    } else {
      if (bbox_values[["xmin"]] < -180 && bbox_values[["xmin"]] >= -180 - lon_tol)
        bbox_values[["xmin"]] <- -180
      if (bbox_values[["xmax"]] > 180 && bbox_values[["xmax"]] <= 180 + lon_tol)
        bbox_values[["xmax"]] <- 180
    }
    if (bbox_values[["ymin"]] < -90 && bbox_values[["ymin"]] >= -90 - lat_tol)
      bbox_values[["ymin"]] <- -90
    if (bbox_values[["ymax"]] > 90 && bbox_values[["ymax"]] <= 90 + lat_tol)
      bbox_values[["ymax"]] <- 90
  }

  sf::st_as_sfc(sf::st_bbox(bbox_values, crs = raster_crs))
}

surt_equal_area_crs <- function() sf::st_crs(6933)

surt_equal_area_geometry <- function(geometry) {
  if (is.na(sf::st_crs(geometry))) stop("Geometry CRS is required for area calculation.")
  suppressWarnings(sf::st_transform(geometry, surt_equal_area_crs()))
}

surt_surface_area_m2 <- function(geometry) {
  if (!length(geometry)) return(0)
  as.numeric(sum(sf::st_area(surt_equal_area_geometry(geometry))))
}

surt_raster_coverage_fraction <- function(raster, polygons) {
  raster_crs <- sf::st_crs(terra::crs(raster, proj = TRUE))
  if (is.na(raster_crs)) stop("Raster CRS is required for footprint coverage.")
  if (is.na(sf::st_crs(polygons))) stop("Polygon CRS is required for footprint coverage.")

  transformed <- sf::st_transform(polygons, raster_crs)
  footprint <- surt_raster_footprint(raster)

  # Raster footprints are rectangles. Use the vectorized topological predicate
  # first: polygons wholly covered by the footprint have an exact coverage ratio
  # of 1 and do not require an equal-area intersection. Any FALSE result falls
  # through to the conservative area-ratio path, so the fast path cannot turn a
  # genuinely partial polygon into a computed partial ratio.
  wholly_inside <- as.logical(sf::st_covered_by(
    sf::st_geometry(transformed),
    footprint,
    sparse = FALSE
  )[, 1])

  out <- rep(1, nrow(transformed))
  partial_idx <- which(!wholly_inside)
  if (!length(partial_idx)) return(out)

  # Raster-footprint coverage is an areal overlap ratio. Compute partial cases
  # in a global equal-area CRS. This also avoids an s2 artefact for longitude/
  # latitude rectangles whose constant-latitude edges have different segmenting.
  partial_equal_area <- surt_equal_area_geometry(transformed[partial_idx, , drop = FALSE])
  footprint_equal_area <- surt_equal_area_geometry(footprint)

  out[partial_idx] <- vapply(seq_along(partial_idx), function(j) {
    geom <- sf::st_geometry(partial_equal_area[j, , drop = FALSE])
    total_area <- as.numeric(sum(sf::st_area(geom)))
    if (!is.finite(total_area) || total_area <= 0) return(NA_real_)
    overlap <- suppressWarnings(sf::st_intersection(geom, footprint_equal_area))
    if (!length(overlap)) return(0)
    overlap_area <- as.numeric(sum(sf::st_area(overlap)))
    surt_clamp_fraction(overlap_area / total_area)
  }, numeric(1))

  out
}

surt_area_weighted_summary <- function(raster, polygons) {
  if (terra::nlyr(raster) != 1L) {
    stop("surt_area_weighted_summary requires exactly one raster layer.")
  }
  raster_crs <- sf::st_crs(terra::crs(raster, proj = TRUE))
  if (is.na(raster_crs)) stop("Raster CRS is required for zonal aggregation.")
  if (is.na(sf::st_crs(polygons))) stop("Polygon CRS is required for zonal aggregation.")

  transformed <- sf::st_transform(polygons, raster_crs)
  cell_area <- terra::cellSize(raster, mask = FALSE, unit = "m", transform = TRUE)

  extracted <- exactextractr::exact_extract(
    raster,
    transformed,
    weights = cell_area,
    fun = function(values, coverage_fraction, weights) {
      touched <- is.finite(coverage_fraction) & coverage_fraction > 0 &
        is.finite(weights) & weights > 0
      if (!any(touched)) {
        return(data.frame(value = NA_real_, valid_within_raster_fraction = 0))
      }

      values <- values[touched]
      area_weights <- coverage_fraction[touched] * weights[touched]
      total_area <- sum(area_weights)
      valid <- is.finite(values)
      valid_area <- sum(area_weights[valid])

      if (!is.finite(total_area) || total_area <= 0 ||
          !is.finite(valid_area) || valid_area <= 0) {
        return(data.frame(value = NA_real_, valid_within_raster_fraction = 0))
      }

      data.frame(
        value = sum(values[valid] * area_weights[valid]) / valid_area,
        valid_within_raster_fraction = valid_area / total_area
      )
    },
    progress = FALSE
  )

  if (!is.data.frame(extracted) || nrow(extracted) != nrow(transformed)) {
    stop("Area-weighted extraction returned an unexpected result shape.")
  }

  raster_fraction <- surt_raster_coverage_fraction(raster, transformed)
  extracted$raster_coverage_fraction <- surt_clamp_fraction(raster_fraction)
  extracted$valid_within_raster_fraction <- surt_clamp_fraction(extracted$valid_within_raster_fraction)
  extracted$valid_data_fraction <- surt_clamp_fraction(
    extracted$raster_coverage_fraction * extracted$valid_within_raster_fraction
  )

  extracted[, c(
    "value",
    "raster_coverage_fraction",
    "valid_within_raster_fraction",
    "valid_data_fraction"
  )]
}
