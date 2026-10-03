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

  # Use terra's public coordinate accessors rather than `$` fields on SpatExtent.
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
  # beyond +/-180 or +/-90. CHIRPS v2.0 annual 2023, for example, reports
  # xmax=180.000005364418. Passing that spill directly through PROJ wraps the
  # eastern edge across the antimeridian and can collapse the footprint overlap
  # to zero. Normalize only near-global longitude spans, and clamp only tiny
  # coordinate spill relative to the raster resolution; larger excursions remain
  # untouched so legitimate nonstandard longitude domains are not silently hidden.
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

# Raster-footprint coverage is an areal overlap ratio. Compute both polygon and
# footprint in a global equal-area CRS before intersection. This avoids a subtle
# s2 artefact for longitude/latitude rectangles: the same constant-latitude edge
# represented as one long geodesic segment versus several shorter segments can
# otherwise yield a fraction slightly below 1 even when the polygon is exactly
# inside the raster extent.
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
  transformed_equal_area <- surt_equal_area_geometry(transformed)
  footprint_equal_area <- surt_equal_area_geometry(footprint)

  vapply(seq_len(nrow(transformed_equal_area)), function(i) {
    geom <- sf::st_geometry(transformed_equal_area[i, , drop = FALSE])
    total_area <- as.numeric(sum(sf::st_area(geom)))
    if (!is.finite(total_area) || total_area <= 0) return(NA_real_)
    overlap <- suppressWarnings(sf::st_intersection(geom, footprint_equal_area))
    if (!length(overlap)) return(0)
    overlap_area <- as.numeric(sum(sf::st_area(overlap)))
    surt_clamp_fraction(overlap_area / total_area)
  }, numeric(1))
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
        return(data.frame(
          value = NA_real_,
          valid_within_raster_fraction = 0
        ))
      }

      values <- values[touched]
      area_weights <- coverage_fraction[touched] * weights[touched]
      total_area <- sum(area_weights)
      valid <- is.finite(values)
      valid_area <- sum(area_weights[valid])

      if (!is.finite(total_area) || total_area <= 0 ||
          !is.finite(valid_area) || valid_area <= 0) {
        return(data.frame(
          value = NA_real_,
          valid_within_raster_fraction = 0
        ))
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
  extracted$valid_within_raster_fraction <- surt_clamp_fraction(
    extracted$valid_within_raster_fraction
  )
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
