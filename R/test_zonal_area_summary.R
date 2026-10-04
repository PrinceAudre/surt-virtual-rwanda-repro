#!/usr/bin/env Rscript
# Reviewer-driven regression tests for area weighting and valid-data coverage.
# Includes the Array support-semantics collision experiment: identical zonal
# means can carry materially different footprint and finite-data support.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

file_arg <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
here <- dirname(normalizePath(file_arg, winslash = "/", mustWork = TRUE))
source(file.path(here, "zonal_area_summary.R"))

passed_checks <- 0L
stop_if_not <- function(label, condition) {
  if (!isTRUE(condition)) stop(sprintf("[FAIL] %s", label), call. = FALSE)
  passed_checks <<- passed_checks + 1L
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

# Array E1 support-semantics collision experiment.
# All four cases intentionally return the same value (10) while representing
# different support states. This demonstrates why the mean alone is not an
# adequate administrative-data handoff contract. The experiment does NOT claim
# that underlying libraries cannot calculate comparable diagnostics when asked.
make_constant_raster <- function(values) {
  r <- terra::rast(
    xmin = 0, xmax = 2000, ymin = 0, ymax = 1000,
    ncols = 2, nrows = 1, crs = "EPSG:3857"
  )
  terra::values(r) <- values
  r
}

collision_cases <- list(
  complete = surt_area_weighted_summary(
    make_constant_raster(c(10, 10)),
    sf::st_sf(unit_id = "COMPLETE", geometry = rect_polygon(0, 2000, 0, 1000, 3857))
  ),
  finite_gap = surt_area_weighted_summary(
    make_constant_raster(c(10, NA)),
    sf::st_sf(unit_id = "FINITE_GAP", geometry = rect_polygon(0, 2000, 0, 1000, 3857))
  ),
  footprint_gap = surt_area_weighted_summary(
    make_constant_raster(c(10, 10)),
    sf::st_sf(unit_id = "FOOTPRINT_GAP", geometry = rect_polygon(0, 4000, 0, 1000, 3857))
  ),
  combined_gap = surt_area_weighted_summary(
    make_constant_raster(c(10, NA)),
    sf::st_sf(unit_id = "COMBINED_GAP", geometry = rect_polygon(0, 4000, 0, 1000, 3857))
  )
)

collision <- do.call(rbind, lapply(names(collision_cases), function(case_name) {
  row <- collision_cases[[case_name]]
  data.frame(
    case = case_name,
    value = row$value,
    raster_coverage_fraction = row$raster_coverage_fraction,
    valid_within_raster_fraction = row$valid_within_raster_fraction,
    valid_data_fraction = row$valid_data_fraction,
    stringsAsFactors = FALSE
  )
}))
rownames(collision) <- NULL

stop_if_not("collision experiment keeps all zonal means identical",
            max(abs(collision$value - 10)) < 1e-12)
stop_if_not("complete case reports full support",
            abs(collision$raster_coverage_fraction[collision$case == "complete"] - 1) < 1e-9 &&
              abs(collision$valid_within_raster_fraction[collision$case == "complete"] - 1) < 1e-9 &&
              abs(collision$valid_data_fraction[collision$case == "complete"] - 1) < 1e-9)
stop_if_not("finite-gap case isolates within-footprint missingness",
            abs(collision$raster_coverage_fraction[collision$case == "finite_gap"] - 1) < 1e-9 &&
              abs(collision$valid_within_raster_fraction[collision$case == "finite_gap"] - 0.5) < 1e-9 &&
              abs(collision$valid_data_fraction[collision$case == "finite_gap"] - 0.5) < 1e-9)
stop_if_not("footprint-gap case isolates raster-extent missingness",
            abs(collision$raster_coverage_fraction[collision$case == "footprint_gap"] - 0.5) < 0.01 &&
              abs(collision$valid_within_raster_fraction[collision$case == "footprint_gap"] - 1) < 1e-9 &&
              abs(collision$valid_data_fraction[collision$case == "footprint_gap"] - 0.5) < 0.01)
stop_if_not("combined-gap case separates both support losses",
            abs(collision$raster_coverage_fraction[collision$case == "combined_gap"] - 0.5) < 0.01 &&
              abs(collision$valid_within_raster_fraction[collision$case == "combined_gap"] - 0.5) < 1e-9 &&
              abs(collision$valid_data_fraction[collision$case == "combined_gap"] - 0.25) < 0.01)
stop_if_not("collision experiment distinguishes support despite identical means",
            length(unique(round(collision$raster_coverage_fraction, 6))) > 1L &&
              length(unique(round(collision$valid_within_raster_fraction, 6))) > 1L &&
              length(unique(round(collision$valid_data_fraction, 6))) > 2L)

cat("\nSupport-semantics collision evidence:\n")
print(collision, row.names = FALSE, digits = 6)

# CHIRPS regression: the public annual GeoTIFF has a tiny floating-point spill
# beyond 180 degrees longitude. That must not wrap the footprint across the
# antimeridian and report zero coverage for an African polygon.
r_chirps_extent <- terra::rast(
  xmin = -180, xmax = 180.000005364418,
  ymin = -50.0000014901161, ymax = 50,
  ncols = 7200, nrows = 2000, crs = "EPSG:4326"
)
p_uganda_box <- sf::st_sf(
  unit_id = "UGA_BOX",
  geometry = rect_polygon(29.579466, 35.035990, -1.443322, 4.249885, 4326)
)
fp_chirps <- surt_raster_footprint(r_chirps_extent)
stop_if_not("near-global geographic footprint normalizes CHIRPS longitude spill",
            abs(sf::st_bbox(fp_chirps)[["xmin"]] + 180) < 1e-12 &&
              abs(sf::st_bbox(fp_chirps)[["xmax"]] - 180) < 1e-12)
stop_if_not("CHIRPS-like global footprint reports complete Uganda-box coverage",
            abs(surt_raster_coverage_fraction(r_chirps_extent, p_uganda_box) - 1) < 1e-9)

# Latitude-sensitive fixture: equal-degree cells at high latitude have less surface area.
# Use one simple valid polygon spanning all rows. Intermediate rows are NA, so only the
# two finite endpoint cells enter the weighted mean. Cell indices are obtained from
# coordinates directly: terra::crds() can omit NA cells and therefore cannot be used
# to discover cells before the finite fixture values have been assigned.
r_lat <- terra::rast(
  xmin = 0, xmax = 1, ymin = 0, ymax = 61,
  ncols = 1, nrows = 61, crs = "EPSG:4326"
)
terra::values(r_lat) <- NA_real_
low_cell <- terra::cellFromXY(r_lat, matrix(c(0.5, 0.5), ncol = 2))
high_cell <- terra::cellFromXY(r_lat, matrix(c(0.5, 60.5), ncol = 2))
if (length(low_cell) != 1L || length(high_cell) != 1L ||
    any(!is.finite(c(low_cell, high_cell)))) {
  stop("Latitude-weighting fixture could not identify endpoint raster cells.")
}
vals <- rep(NA_real_, terra::ncell(r_lat))
vals[low_cell] <- 0
vals[high_cell] <- 100
terra::values(r_lat) <- vals

p_lat <- sf::st_sf(
  unit_id = "LATITUDE",
  geometry = rect_polygon(0, 1, 0, 61, 4326)
)
s_lat <- surt_area_weighted_summary(r_lat, p_lat)

areas <- terra::values(
  terra::cellSize(r_lat, mask = FALSE, unit = "m", transform = TRUE),
  mat = FALSE
)
expected <- (0 * areas[low_cell] + 100 * areas[high_cell]) /
  (areas[low_cell] + areas[high_cell])

stop_if_not("latitude-sensitive area-weighted mean matches terra cell-area calculation",
            abs(s_lat$value - expected) < 1e-6)
stop_if_not("latitude-sensitive area weighting differs materially from equal-cell mean",
            s_lat$value < 40)

cat(sprintf("\n=== zonal area and coverage: %d passed, 0 failed ===\n", passed_checks))
