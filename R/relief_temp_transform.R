#!/usr/bin/env Rscript
# relief_temp_transform.R - temperature transform and consistency helpers.
# Sourced by the real builder and the account-free synthetic-fixture test.
#
# WHY THIS FILE EXISTS: exactly like the CHIRPS rainfall layer, the temperature layer's per-district mean + the
# two-part BAND + WEST<EAST (highlands cooler than lowlands) consistency gate were inline in the builder and only
# ever ran on the real ERA5-Land download - so the gate that catches the classic KELVIN->CELSIUS bug (an
# uncorrected ~290 K blows the 10-30 C band) never ran in CI. Extracting it (byte-for-byte the same thresholds)
# lets the hermetic test EXECUTE it on a synthetic east-warm / west-cool raster over the REAL district geometry,
# no download. The Kelvin-to-Celsius conversion and 12-month completeness guard stay in the builder.
# Descriptive only; not a forecast, surveillance output, or operational recommendation.
suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))

# Area-weighted per-district mean temperature. The input raster is ALREADY in degrees Celsius - the builder does
# the Kelvin->C conversion (ERA5-Land is stored in K) before calling. Fail-closed on ANY NA district (a
# CRS / coverage / variable-name bug), then round to 0.1 C. Returns the per-district mean aligned to `d`.
temp_district_means <- function(r, d) {
  v <- exactextractr::exact_extract(r, d, "mean", progress = FALSE)
  if (any(is.na(v))) stop("FAIL-CLOSED: a district got no temperature value (CRS / coverage / variable-name problem).")
  round(v, 1)
}

# District split longitudes for the broad direction check.
temp_district_lon <- function(d) {
  points <- suppressWarnings(sf::st_point_on_surface(sf::st_geometry(d)))
  sf::st_coordinates(points)[, 1]
}

# Two-part per-district consistency gate (a bounded-value and broad-direction tripwire, not independent validation):
#  (a) BAND: every district mean temp in a sane Rwanda band [10, 30] C. Catches the classic ERA5 KELVIN->CELSIUS
#      bug (an uncorrected ~290 K, or a wrong-variable read) immediately.
#  (b) DIRECTION: the western/highland THIRD (Congo-Nile ridge) must be COOLER than the eastern THIRD (Akagera
#      lowlands) by `margin` C - Rwanda temperature is elevation-driven, so an inversion signals a units/CRS bug.
#      Tertile split by centroid longitude - asserts only the robust WEST<EAST direction, not an exact gradient.
#      margin = 1 C sits below the real gradient with headroom.
temp_consistency_gate <- function(district, temp_c, lon, band = c(10, 30), margin = 1) {
  bad <- which(temp_c < band[1] | temp_c > band[2])
  if (length(bad))
    stop(sprintf("FAIL-CLOSED: temperature outside the sane %d-%d C band for Rwanda (likely a Kelvin->Celsius bug): %s",
                 band[1], band[2],
                 paste(sprintf("%s=%.1f", district[bad], temp_c[bad]), collapse = ", ")))
  west <- temp_c[lon <= stats::quantile(lon, 1 / 3)]
  east <- temp_c[lon >= stats::quantile(lon, 2 / 3)]
  if (!length(west) || !length(east))
    stop("FAIL-CLOSED: consistency gate could not split west/east districts by longitude.")
  if (!(mean(west) < mean(east) - margin))
    stop(sprintf("FAIL-CLOSED: consistency check violated - western/highland districts (mean %.1f C) are not clearly cooler than eastern lowlands (mean %.1f C) by %d C. Likely a units/aggregation/CRS/inversion bug.",
                 mean(west), mean(east), margin))
  # Return the west/east pole means (invisibly) so the builder can LOG them without recomputing the split
  # (the split now lives only here - Codex #66 P1: the builder's log referenced west/east after they left scope).
  invisible(c(west = mean(west), east = mean(east)))
}
