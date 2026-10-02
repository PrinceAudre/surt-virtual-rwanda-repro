#!/usr/bin/env Rscript
# Shared zonal-summary primitives for SuRT-GeoHarmonizer v1.4.0.
#
# The public contract separates three quantities that were previously conflated:
# 1. how much of a polygon intersects the raster footprint;
# 2. how much of the raster-covered polygon has finite values; and
# 3. the area-weighted value summary over those finite values.
#
# exactextractr's `weights = "area"` supplies raster-cell area weights. The
# custom summary multiplies those weights by polygon-cell coverage fractions.
# For longitude/latitude rasters exactextractr calculates cell areas in square
# metres using its documented spherical approximation. For projected rasters,
# cell areas are Cartesian in the raster CRS.

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
  e <- terra::ext(raster)
  sf::st_as_sfc(sf::st_bbox(
    c(xmin = e$xmin, ymin = e$ymin, xmax = e$xmax, ymax = e$ymax),
    crs = raster_crs
  ))
}

surt_geodesic_area <- function(geometry) {
  if (!length(geometry)) return(0)
  as.numeric(sum(sf::st_area(sf::st_transform(geometry, 4326))))
}

surt_raster_coverage_fraction <- function(raster, polygons) {
  raster_crs <- sf::st_crs(terra::crs(raster, proj = TRUE))
  if (is.na(raster_crs)) stop("Raster CRS is required for footprint coverage.")
  if (is.na(sf::st_crs(polygons))) stop("Polygon CRS is required for footprint coverage.")

  transformed <- sf::st_transform(polygons, raster_crs)
  footprint <- surt_raster_footprint(raster)

  vapply(seq_len(nrow(transformed)), function(i) {
    geom <- sf::st_geometry(transformed[i, , drop = FALSE])
    total_area <- surt_geodesic_area(geom)
    if (!is.finite(total_area) || total_area <= 0) return(NA_real_)
    overlap <- suppressWarnings(sf::st_intersection(geom, footprint))
    if (!length(overlap)) return(0)
    surt_clamp_fraction(surt_geodesic_area(overlap) / total_area)
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
  extracted <- exactextractr::exact_extract(
    raster,
    transformed,
    weights = "area",
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
