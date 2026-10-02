#!/usr/bin/env Rscript
# Temperature transformation and consistency helpers for SuRT-GeoHarmonizer.
# Sourced by the real ERA5-Land builder and account-free controlled tests.

suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))

temp_is_leap_year <- function(year) {
  year <- as.integer(year)
  if (length(year) != 1L || is.na(year)) stop("FAIL-CLOSED: year must be one integer.")
  (year %% 4L == 0L) && ((year %% 100L != 0L) || (year %% 400L == 0L))
}

temp_month_days <- function(year) {
  feb <- if (temp_is_leap_year(year)) 29L else 28L
  c(31L, feb, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)
}

# ERA5-Land `monthly averaged` instantaneous variables are monthly means created
# from the hourly values in each calendar month. Therefore an annual mean over
# all days is the 12 monthly means weighted by calendar days in each month.
# Missing monthly values are not silently re-normalized: NA in any month remains
# NA at that cell so incomplete temporal coverage cannot masquerade as annual.
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

# Per-district spatial mean after temporal aggregation and Kelvin conversion.
# This helper currently preserves the reference-layer extraction behavior; the
# v1.4 spatial-area audit separately verifies the generic public interface.
temp_district_means <- function(r, d) {
  v <- exactextractr::exact_extract(r, d, "mean", progress = FALSE)
  if (any(is.na(v))) {
    stop("FAIL-CLOSED: a district got no temperature value (CRS / coverage / variable-name problem).")
  }
  round(v, 1)
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
