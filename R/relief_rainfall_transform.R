#!/usr/bin/env Rscript
# relief_rainfall_transform.R - rainfall transform and consistency helpers.
# Sourced by the real builder and the account-free synthetic-fixture test.
#
# WHY THIS FILE EXISTS: the real builder's core data path (no-data mask -> area-weighted per-district mean ->
# a two-part BAND + WEST>EAST consistency gate) was previously inline in the builder and therefore only ever
# exercised by the real ~57MB CHIRPS download - so the gate that guards a units (m vs mm) / aggregation / CRS /
# inversion bug NEVER ran in CI. Extracting it (byte-for-byte the same thresholds) lets the hermetic test EXECUTE
# it end-to-end on a SYNTHETIC CHIRPS-like raster (a west-wet / east-dry gradient) over the REAL district
# geometry, WITHOUT the download - the exact rigor the NDVI layer already has (relief_ndvi_transform.R). The one
# part that needs the real raster (the CHIRPS GeoTIFF fetch) stays a thin, labelled seam in the builder.
# Descriptive only; not a forecast, surveillance output, or operational recommendation.
suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))

# Coverage-fraction-weighted per-district mean rainfall. CHIRPS uses -9999 as the no-data sentinel; mask it (r < 0 -> NA)
# BEFORE aggregating so a no-data cell can never drag a district mean down. CHIRPS 0.05deg -> ~28 cells/district,
# so exact_extract uses polygon-cell coverage fractions. This is not true surface-area weighting in geographic
# coordinates. Fail closed on any NA district
# (a CRS / coverage / no-data bug), then round to whole mm. Returns the numeric per-district mean aligned to `d`.
rainfall_district_means <- function(r, d) {
  r[r < 0] <- NA
  v <- exactextractr::exact_extract(r, d, "mean", progress = FALSE)
  if (any(is.na(v))) stop("FAIL-CLOSED: a district got no rainfall value (CRS / coverage / no-data problem).")
  round(v)
}

# District split longitudes for the broad direction check: point-on-surface (guaranteed inside the polygon,
# unlike a centroid which can fall outside a concave district) x-coordinate per district.
rainfall_district_lon <- function(d) {
  points <- suppressWarnings(sf::st_point_on_surface(sf::st_geometry(d)))
  sf::st_coordinates(points)[, 1]
}

# Two-part per-district consistency gate (a bounded-value and broad-direction tripwire, not independent validation):
#  (a) BAND: every district annual rainfall in a sane Rwanda band [300, 3000] mm. Catches a units (m<->mm),
#      aggregation, or CRS bug that a structural check would miss.
#  (b) DIRECTION: the western/highland THIRD (wetter Congo-Nile ridge) must be > the eastern THIRD (drier
#      Akagera) by `margin` mm. A tertile split by centroid longitude - so it asserts only the robust WEST>EAST
#      direction, never an exact gradient magnitude (a threshold must sit below the signal, not on it). margin =
#      50 mm sits comfortably below the real observed gradient with headroom, enough to catch an inversion /
#      gross error while tolerating year-to-year variation.
rainfall_consistency_gate <- function(district, rainfall_mm, lon, band = c(300, 3000), margin = 50) {
  bad <- which(rainfall_mm < band[1] | rainfall_mm > band[2])
  if (length(bad))
    stop(sprintf("FAIL-CLOSED: rainfall outside the sane %d-%d mm band for Rwanda (units/aggregation/CRS bug): %s",
                 band[1], band[2],
                 paste(sprintf("%s=%d", district[bad], rainfall_mm[bad]), collapse = ", ")))
  west <- rainfall_mm[lon <= stats::quantile(lon, 1 / 3)]
  east <- rainfall_mm[lon >= stats::quantile(lon, 2 / 3)]
  if (!length(west) || !length(east))
    stop("FAIL-CLOSED: consistency gate could not split west/east districts by longitude.")
  if (!(mean(west) > mean(east) + margin))
    stop(sprintf("FAIL-CLOSED: consistency check violated - western districts (mean %.0f mm) are not clearly wetter than eastern (mean %.0f mm) by %d mm. Likely a units/aggregation/CRS/inversion bug.",
                 mean(west), mean(east), margin))
  # Return the west/east pole means (invisibly) so the builder can LOG them without recomputing the split
  # (the split now lives only here - Codex #66 P1: the builder's log referenced west/east after they left scope).
  invisible(c(west = mean(west), east = mean(east)))
}
