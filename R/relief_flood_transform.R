#!/usr/bin/env Rscript
# relief_flood_transform.R - PURE transform + ground-truth helpers for a DESCRIPTIVE flood-SUSCEPTIBILITY layer
# (indicator #5, Phase 2 - cholera/AWD CONTEXT) derived from the CC0 global HAND (Height Above Nearest Drainage,
# ASF/HydroSAR from the Copernicus GLO-30 DEM). Sourced by BOTH build_relief_climate_flood.R AND the hermetic test
# in tools/semantic_layers/tests/test_maplibre_relief.R.
#
# WHAT IT IS (and is NOT):
#  - Per district: the % of the district's AREA that is LOW-LYING near drainage - HAND <= a small threshold
#    (default 5 m above the nearest stream). Low HAND = valley-floor / wetland / floodplain terrain that ponds and
#    inundates; this is the fluvial/pluvial INUNDATION susceptibility relevant to WASH / cholera-AWD (stagnant
#    contaminated water) - exactly the flood type HAND captures.
#  - It is NOT flash-flood or LANDSLIDE hazard. Those are steep-terrain, rain-driven processes (Rwanda's western/
#    northern highlands) that HAND does NOT represent - a HIGH-HAND steep district reads LOW here yet can face
#    serious flash-flood/landslide risk of a different kind. Stated in the layer's disclaimer so the map can never
#    imply "highlands = flood-safe".
#  - It is NOT a forecast and NOT a disease output: HAND is STATIC terrain (it does not change with weather); the
#    climate TRIGGER (extreme rainfall) is the separate rainfall / rainfall-anomaly layers. The flood -> cholera/AWD
#    linkage stays descriptive evidence context (climate_health_evidence.R), NEVER a computed per-district
#    disease-risk. DESCRIPTIVE only, non-operational; operational_use_allowed = FALSE.
# Raster-only / HDF-free so the hermetic test runs the real math on a synthetic HAND raster over real geometry.
suppressWarnings(suppressMessages({ library(sf); library(exactextractr) }))

# Per-district FLOOD-PRONE AREA FRACTION (%) = 100 x coverage-weighted fraction of the district whose HAND <=
# threshold_m. HAND is a physical height >= 0; the product uses NEGATIVE sentinels for no-data/ocean, so mask
# hand < 0 -> NA BEFORE the fraction (a no-data cell must be EXCLUDED, never counted as flood-prone). exact_extract's
# coverage-fraction weighting gives a genuine AREA fraction. Fail-closed on any NA district. Returns %, rounded 0.1.
flood_prone_fraction <- function(hand, d, threshold_m = 5) {
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
flood_district_lon <- function(d) {
  sf::st_coordinates(sf::st_point_on_surface(sf::st_geometry(d)))[, 1]
}

# Two-part per-district GROUND-TRUTH gate (data correctness, not just structure), fail-closed:
#  (a) SCALE: every district flood-prone fraction in [0, 100] % - a value that escapes [0,100] means the binary
#      threshold / coverage-weighting / units were computed wrong (the flood analogue of the CHIRPS m-vs-mm band).
#  (b) DIRECTION: the EASTERN third (Akagera/Bugesera wetlands + eastern lowlands - flat, near drainage) must have a
#      higher mean flood-prone fraction than the WESTERN third (steep Congo-Nile highland ridge, which sheds water
#      fast -> little low-HAND area) by `margin` points. Rwanda's inundation-prone terrain is the flat east/valleys,
#      NOT the steep west - an inversion signals a CRS flip / threshold-sign bug. Tertile split by longitude, so it
#      asserts only the robust EAST>WEST direction, never an exact magnitude. margin = 3 pts sits below the expected
#      gap with headroom (the eastern wetlands dwarf the western ridge's low-HAND area) while tolerating uncertainty.
#      NOTE: if a real fetch fail-closes HERE, revisit this east>west assumption first - it fails VISIBLY on good
#      data (safe), rather than shipping a plausible-but-wrong layer.
flood_ground_truth_gate <- function(district, flood_prone_pct, lon, band = c(0, 100), margin = 3) {
  bad <- which(flood_prone_pct < band[1] | flood_prone_pct > band[2])
  if (length(bad))
    stop(sprintf("FAIL-CLOSED: flood-prone fraction outside the valid %d-%d %% range (threshold/coverage/units bug): %s",
                 band[1], band[2],
                 paste(sprintf("%s=%.1f", district[bad], flood_prone_pct[bad]), collapse = ", ")))
  east <- flood_prone_pct[lon >= stats::quantile(lon, 2 / 3)]
  west <- flood_prone_pct[lon <= stats::quantile(lon, 1 / 3)]
  if (!length(east) || !length(west))
    stop("FAIL-CLOSED: flood gate could not split east/west districts by longitude.")
  if (!(mean(east) > mean(west) + margin))
    stop(sprintf("FAIL-CLOSED: ground-truth violated - eastern lowland/wetland districts (mean %.1f%%) are NOT clearly more inundation-prone than western highlands (mean %.1f%%) by %d pts. Likely a CRS/threshold-sign/aggregation bug.",
                 mean(east), mean(west), margin))
  # Return the east/west pole means (invisibly) so the builder can LOG them without recomputing the split.
  invisible(c(east = mean(east), west = mean(west)))
}
