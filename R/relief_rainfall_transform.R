#!/usr/bin/env Rscript
# Rainfall transformation and consistency helpers for SuRT-GeoHarmonizer.
# Sourced by the real CHIRPS builder and account-free controlled tests.
# Descriptive only: not a forecast, surveillance output, or recommendation.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

# Load the shared v1.4 zonal contract when this helper is sourced directly.
if (!exists("surt_area_weighted_summary", mode = "function")) {
  .rain_file <- tryCatch(
    normalizePath(sys.frame(1)$ofile, winslash = "/", mustWork = TRUE),
    error = function(error) ""
  )
  if (!nzchar(.rain_file)) {
    .file_arg <- grep("^--file=", commandArgs(), value = TRUE)
    .rain_file <- if (length(.file_arg))
      normalizePath(sub("^--file=", "", .file_arg[[1]]), winslash = "/", mustWork = FALSE) else
      normalizePath(file.path("R", "relief_rainfall_transform.R"), winslash = "/", mustWork = FALSE)
  }
  source(file.path(dirname(.rain_file), "zonal_area_summary.R"))
  rm(.rain_file)
  if (exists(".file_arg")) rm(.file_arg)
}

# CHIRPS uses negative no-data/fill values. Mask them before aggregation, then
# compute a true surface-area-weighted polygon mean. The returned coverage fields
# distinguish raster-footprint coverage, finite coverage within the footprint,
# and overall valid-data coverage of each polygon.
rainfall_district_summary <- function(r, d) {
  r <- terra::ifel(r < 0, NA, r)
  summary <- surt_area_weighted_summary(r, d)
  if (any(!is.finite(summary$value))) {
    stop("FAIL-CLOSED: a district got no rainfall value (CRS / coverage / no-data problem).")
  }
  if (any(!is.finite(summary$valid_data_fraction))) {
    stop("FAIL-CLOSED: a district got an undefined rainfall valid-data fraction.")
  }
  summary$value <- round(summary$value)
  summary
}

# Compatibility wrapper for callers that only require the mean vector.
rainfall_district_means <- function(r, d) {
  rainfall_district_summary(r, d)$value
}

# Point-on-surface longitudes for the broad direction check.
rainfall_district_lon <- function(d) {
  points <- suppressWarnings(sf::st_point_on_surface(sf::st_geometry(d)))
  sf::st_coordinates(points)[, 1]
}

# Rwanda-specific bounded-value and west>east consistency tripwire. This is a
# transformation sanity check, not independent validation of CHIRPS.
rainfall_consistency_gate <- function(district, rainfall_mm, lon,
                                      band = c(300, 3000), margin = 50) {
  bad <- which(rainfall_mm < band[1] | rainfall_mm > band[2])
  if (length(bad)) {
    stop(sprintf(
      "FAIL-CLOSED: rainfall outside the sane %d-%d mm band for Rwanda: %s",
      band[1], band[2],
      paste(sprintf("%s=%d", district[bad], rainfall_mm[bad]), collapse = ", ")
    ))
  }
  west <- rainfall_mm[lon <= stats::quantile(lon, 1 / 3)]
  east <- rainfall_mm[lon >= stats::quantile(lon, 2 / 3)]
  if (!length(west) || !length(east)) {
    stop("FAIL-CLOSED: consistency gate could not split west/east districts by longitude.")
  }
  if (!(mean(west) > mean(east) + margin)) {
    stop(sprintf(
      paste0(
        "FAIL-CLOSED: western districts (mean %.0f mm) are not clearly wetter ",
        "than eastern districts (mean %.0f mm) by %d mm."
      ),
      mean(west), mean(east), margin
    ))
  }
  invisible(c(west = mean(west), east = mean(east)))
}
