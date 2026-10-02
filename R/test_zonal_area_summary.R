#!/usr/bin/env Rscript
# Reviewer-driven regression tests for area weighting and valid-data coverage.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

file_arg <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
here <- dirname(normalizePath(file_arg, winslash = "/", mustWork = TRUE))
source(file.path(here, "zonal_area_summary.R"))

stop_if_not <- function(label, condition) {
  if (!isTRUE(condition)) stop(sprintf("[FAIL] %s", label), call. = FALSE)
  cat(sprintf("[PASS] %s\n", label))
}

rect_polygon <- function(xmin, xmax, ymin, ymax, crs) {
  sf::st_sfc(sf::st_polygon(list(matrix(c(
    xmin, ymin,
    xmax, ymin,
    xmax, ymax,
    xmin, ymax,
    xmin, ymin
  ), ncol = 2, byrow = TRUE))), crs = crs)
}

# Partial primary-raster NA coverage: a finite mean must be accompanied by 0.5 valid coverage.
r_partial <- terra::rast(
  xmin = 0, xmax = 2000, ymin = 0, ymax = 1000,
  ncols = 2, nrows = 1, crs = "EPSG:3857"
)
terra::values(r_partial) <- c(10, NA)
p_partial <- sf::st_sf(
  unit_id = "PARTIAL",
  geometry = rect_polygon(0, 2000, 0, 1000, 3857)
)
s_partial <- surt_area_weighted_summary(r_partial, p_partial)

stop_if_not("partial coverage retains finite area-weighted mean",
            abs(s_partial$value - 10) < 1e-12)
stop_if_not("partial coverage reports complete raster footprint coverage",
            abs(s_partial$raster_coverage_fraction - 1) < 1e-9)
stop_if_not("partial coverage reports 0.5 valid fraction within raster",
            abs(s_partial$valid_within_raster_fraction - 0.5) < 1e-9)
stop_if_not("partial coverage reports 0.5 overall valid-data fraction",
            abs(s_partial$valid_data_fraction - 0.5) < 1e-9)

# Polygon extends beyond raster extent: footprint coverage must be visible rather than silently omitted.
r_extent <- terra::rast(
  xmin = 0, xmax = 2000, ymin = 0, ymax = 1000,
  ncols = 2, nrows = 1, crs = "EPSG:3857"
)
terra::values(r_extent) <- c(10, 20)
p_extent <- sf::st_sf(
  unit_id = "EXTENT",
  geometry = rect_polygon(0, 3000, 0, 1000, 3857)
)
s_extent <- surt_area_weighted_summary(r_extent, p_extent)

stop_if_not("extent-limited polygon mean uses available finite raster cells",
            abs(s_extent$value - 15) < 1e-12)
stop_if_not("extent-limited polygon reports about two-thirds raster coverage",
            abs(s_extent$raster_coverage_fraction - (2 / 3)) < 0.01)
stop_if_not("extent-limited polygon has complete valid coverage within raster footprint",
            abs(s_extent$valid_within_raster_fraction - 1) < 1e-9)
stop_if_not("extent-limited polygon overall valid coverage matches footprint coverage",
            abs(s_extent$valid_data_fraction - s_extent$raster_coverage_fraction) < 1e-9)

# Latitude-sensitive fixture: equal-degree cells at high latitude have less surface area.
r_lat <- terra::rast(
  xmin = 0, xmax = 1, ymin = 0, ymax = 61,
  ncols = 1, nrows = 61, crs = "EPSG:4326"
)
terra::values(r_lat) <- NA_real_
xy <- terra::crds(r_lat, df = TRUE)
low_cell <- which(abs(xy$y - 0.5) < 1e-9)
high_cell <- which(abs(xy$y - 60.5) < 1e-9)
vals <- rep(NA_real_, terra::ncell(r_lat))
vals[low_cell] <- 0
vals[high_cell] <- 100
terra::values(r_lat) <- vals

low_poly <- rect_polygon(0, 1, 0, 1, 4326)[[1]]
high_poly <- rect_polygon(0, 1, 60, 61, 4326)[[1]]
mp <- sf::st_sfc(sf::st_multipolygon(list(low_poly, high_poly)), crs = 4326)
p_lat <- sf::st_sf(unit_id = "LATITUDE", geometry = mp)
s_lat <- surt_area_weighted_summary(r_lat, p_lat)

areas <- terra::values(terra::cellSize(r_lat, unit = "m"), mat = FALSE)
expected <- (0 * areas[low_cell] + 100 * areas[high_cell]) /
  (areas[low_cell] + areas[high_cell])

stop_if_not("latitude-sensitive area-weighted mean matches terra cell-area calculation",
            abs(s_lat$value - expected) < 1e-6)
stop_if_not("latitude-sensitive area weighting differs materially from equal-cell mean",
            s_lat$value < 40)

cat("\n=== zonal area and coverage: 10 passed, 0 failed ===\n")
