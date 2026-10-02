#!/usr/bin/env Rscript
# Temperature transformation and consistency helpers for SuRT-GeoHarmonizer.
# Sourced by the real ERA5-Land builder and account-free controlled tests.

suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))

if (!exists("surt_area_weighted_summary", mode = "function")) {
  .temp_file <- tryCatch(
    normalizePath(sys.frame(1)$ofile, winslash = "/", mustWork = TRUE),
    error = function(error) ""
  )
  if (!nzchar(.temp_file)) {
    .file_arg <- grep("^--file=", commandArgs(), value = TRUE)
    .temp_file <- if (length(.file_arg))
      normalizePath(sub("^--file=", "", .file_arg[[1]]), winslash = "/", mustWork = FALSE) else
      normalizePath(file.path("R", "relief_temp_transform.R"), winslash = "/", mustWork = FALSE)
  }
  source(file.path(dirname(.temp_file), "zonal_area_summary.R"))
  rm(.temp_file)
  if (exists(".file_arg")) rm(.file_arg)
}

temp_is_leap_year <- function(year) {
  year <- as.integer(year)
  if (length(year) != 1L || is.na(year)) stop("FAIL-CLOSED: year must be one integer.")
  (year %% 4L == 0L) && ((year %% 100L != 0L) || (year %% 400L == 0L))
}

temp_month_days <- function(year) {
  feb <- if (temp_is_leap_year(year)) 29L else 28L
  c(31L, feb, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)
}

# ERA5-Land monthly averaged instantaneous variables are monthly means derived
# from the hourly values represented by each calendar month. For the annual
# statistic used here, monthly means are weighted by calendar days.
temp_calendar_day_weighted_mean <- function(monthly, year) {
  if (terra::nlyr(monthly) != 12L) {
    stop(sprintf(
      "FAIL-CLOSED: expected 12 ERA5-Land monthly means, received %d layer(s).",
      terra::nlyr(monthly)
    ))
  }
  weights <- temp_month_days(year)
  total_days <- sum(weights)
  terra::app(monthly, fun = function(x) {
    if (any(!is.finite(x))) return(NA_real_)
    sum(x * weights) / total_days
  })
}

temp_kelvin_to_celsius <- function(r) {
  r - 273.15
}

# Surface-area-weighted district summary after temporal aggregation and Kelvin
# conversion. Coverage is retained so a plausible mean cannot conceal partial
# spatial support.
temp_district_summary <- function(r, d) {
  summary <- surt_area_weighted_summary(r, d)
  if (any(!is.finite(summary$value))) {
    stop("FAIL-CLOSED: a district got no temperature value (CRS / coverage / no-data problem).")
  }
  if (any(!is.finite(summary$valid_data_fraction))) {
    stop("FAIL-CLOSED: a district got an undefined temperature valid-data fraction.")
  }
  summary$value <- round(summary$value, 1)
  summary
}

# Compatibility wrapper for callers that only require the value vector.
temp_district_means <- function(r, d) {
  temp_district_summary(r, d)$value
}

temp_district_lon <- function(d) {
  points <- suppressWarnings(sf::st_point_on_surface(sf::st_geometry(d)))
  sf::st_coordinates(points)[, 1]
}

# Rwanda-specific broad consistency tripwire, not independent validation.
temp_consistency_gate <- function(district, temp_c, lon, band = c(10, 30), margin = 1) {
  bad <- which(temp_c < band[1] | temp_c > band[2])
  if (length(bad)) {
    stop(sprintf(
      "FAIL-CLOSED: temperature outside the sane %d-%d C band for Rwanda: %s",
      band[1], band[2],
      paste(sprintf("%s=%.1f", district[bad], temp_c[bad]), collapse = ", ")
    ))
  }
  west <- temp_c[lon <= stats::quantile(lon, 1 / 3)]
  east <- temp_c[lon >= stats::quantile(lon, 2 / 3)]
  if (!length(east) || !length(west)) {
    stop("FAIL-CLOSED: consistency gate could not split west/east districts by longitude.")
  }
  if (!(mean(west) < mean(east) - margin)) {
    stop(sprintf(
      paste0(
        "FAIL-CLOSED: western/highland districts (mean %.1f C) are not cooler ",
        "than eastern lowlands (mean %.1f C) by %d C."
      ),
      mean(west), mean(east), margin
    ))
  }
  invisible(c(west = mean(west), east = mean(east)))
}
