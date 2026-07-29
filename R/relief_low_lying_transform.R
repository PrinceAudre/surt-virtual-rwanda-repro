#!/usr/bin/env Rscript
# relief_low_lying_transform.R - transform and consistency helpers for a descriptive
# low-lying terrain layer derived from the CC0 global HAND product
# (ASF/HydroSAR, based on the Copernicus GLO-30 DEM). Sourced by the real
# builder and the account-free synthetic-fixture test.
#
# WHAT IT IS (and is NOT):
#  - Per district: the % of the district's AREA that is LOW-LYING near drainage - HAND <= a small threshold
#    (default 5 m above the nearest stream). This is a static terrain descriptor.
#  - It is NOT observed flooding, a flood-hazard model, a forecast, or a disease output.
# Raster-only so the hermetic test runs the real math on a synthetic HAND raster.
suppressWarnings(suppressMessages({ library(sf); library(exactextractr) }))

# Per-district LOW-LYING SHARE (%) = 100 x coverage-weighted fraction of the district whose HAND <=
# threshold_m. HAND is a physical height >= 0; the product uses NEGATIVE sentinels for no-data/ocean, so mask
# hand < 0 -> NA BEFORE the fraction (a no-data cell must be excluded). exact_extract's
# coverage-fraction weighting gives a polygon-cell coverage share in the input
# geographic CRS, not exact surface-area weighting. Fail closed on any NA district.
low_lying_share <- function(hand, d, threshold_m = 5) {
  hand[hand < 0] <- NA
  frac <- exactextractr::exact_extract(hand, d, fun = function(values, cov) {
    ok <- is.finite(values)
    if (!any(ok)) return(NA_real_)
    stats::weighted.mean(values[ok] <= threshold_m, cov[ok]) * 100
  }, progress = FALSE)
  if (any(is.na(frac))) stop("FAIL-CLOSED: a district got no HAND value (CRS / coverage / no-data problem).")
  round(frac, 1)
}

# Point-on-surface longitudes for the east/west direction check (inside-polygon x-coordinate per district).
low_lying_district_lon <- function(d) {
  points <- suppressWarnings(sf::st_point_on_surface(sf::st_geometry(d)))
  sf::st_coordinates(points)[, 1]
}

# Two-part per-district consistency gate (a bounded-value and broad-direction tripwire, not independent validation):
#  (a) SCALE: every district low-lying share is in [0, 100] %.
#  (b) DIRECTION: the EASTERN third (Akagera/Bugesera wetlands + eastern lowlands - flat, near drainage) must have a
#      higher mean low-lying share than the WESTERN third (steep Congo-Nile highland ridge) by
#      `margin` points. An inversion signals a CRS flip / threshold-sign bug. Tertile split by longitude, so it
#      asserts only the robust EAST>WEST direction, never an exact magnitude. margin = 3 pts sits below the expected
#      gap with headroom (the eastern wetlands dwarf the western ridge's low-HAND area) while tolerating uncertainty.
#      NOTE: if a real fetch fail-closes HERE, revisit this east>west assumption first - it fails VISIBLY on good
#      data (safe), rather than shipping a plausible-but-wrong layer.
low_lying_consistency_gate <- function(district, low_lying_share_pct, lon,
                                       band = c(0, 100), margin = 3) {
  bad <- which(low_lying_share_pct < band[1] | low_lying_share_pct > band[2])
  if (length(bad))
    stop(sprintf("FAIL-CLOSED: low-lying share outside the valid %d-%d %% range (threshold/coverage/units bug): %s",
                 band[1], band[2],
                 paste(sprintf("%s=%.1f", district[bad], low_lying_share_pct[bad]), collapse = ", ")))
  east <- low_lying_share_pct[lon >= stats::quantile(lon, 2 / 3)]
  west <- low_lying_share_pct[lon <= stats::quantile(lon, 1 / 3)]
  if (!length(east) || !length(west))
    stop("FAIL-CLOSED: low-lying-share gate could not split east/west districts by longitude.")
  if (!(mean(east) > mean(west) + margin))
    stop(sprintf("FAIL-CLOSED: consistency check violated - eastern districts (mean %.1f%%) do not have a clearly greater low-lying share than western districts (mean %.1f%%) by %d points. Likely a CRS/threshold-sign/aggregation bug.",
                 mean(east), mean(west), margin))
  # Return the east/west pole means (invisibly) so the builder can LOG them without recomputing the split.
  invisible(c(east = mean(east), west = mean(west)))
}
