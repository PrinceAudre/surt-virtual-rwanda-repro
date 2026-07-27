#!/usr/bin/env Rscript
# relief_ndvi_transform.R - PURE, HDF-FREE transform + ground-truth helpers for the REAL MODIS NDVI layer
# (indicator #2b). Sourced by BOTH build_relief_climate_ndvi_real.R AND the synthetic-sinusoidal test in
# tools/semantic_layers/tests/test_maplibre_relief.R.
#
# WHY THIS FILE EXISTS: the real builder's core data path (mask fill -> scale -> mosaic the two sinusoidal tiles
# -> reproject SIN->EPSG:4326 -> annual mean -> per-district) must be EXECUTED and asserted, not shipped blind -
# the two-part gate catches gross errors (unscaled DN, fill, gross inversion) but NOT the bugs most likely here
# (wrong mosaic order, misaligned reproject, dropped tile seam, wrong-axis month average). Keeping the pipeline
# HDF-free lets the test run it end-to-end on a synthetic MODIS-SIN fixture WITHOUT NASA credentials. The ONLY
# part that cannot be verified without a real granule - selecting the "1 km monthly NDVI" HDF-EOS subdataset -
# is deliberately kept OUT of this file (it lives as a thin, labelled seam in the builder).
suppressWarnings(suppressMessages({ library(terra) }))

# MODIS MOD13A3 v061 "1 km monthly NDVI": stored int16, scale 0.0001, fill -3000, valid range [-2000, 10000].
# Physical NDVI = DN * 0.0001 (valid physical [-0.2, 1.0]). Mask fill + any out-of-valid BEFORE scaling so a
# fill pixel (-3000) can never contaminate a mean as -0.3.
ndvi_scale_mask_mod13a3 <- function(r) {
  r[r < -2000 | r > 10000] <- NA
  r * 0.0001
}

# granules: a list of list(month = <chr key>, r = <SpatRaster, RAW int16 in the MODIS sinusoidal CRS>). Tiles of
# the SAME month share the same `month` key. Steps: scale/mask each tile -> mosaic same-month tiles (in native
# SIN) -> stack the monthly mosaics -> annual mean per pixel -> reproject to EPSG:4326 (one reprojection, after
# the mean). Returns the annual-mean NDVI raster in EPSG:4326.
ndvi_annual_mean_4326 <- function(granules, crs_4326 = "EPSG:4326") {
  if (!length(granules)) stop("FAIL-CLOSED: no NDVI granules to transform.")
  granules <- lapply(granules, function(g) { g$r <- ndvi_scale_mask_mod13a3(g$r); g })
  months <- unique(vapply(granules, function(g) as.character(g$month), character(1)))
  monthly <- lapply(months, function(mo) {
    tiles <- lapply(Filter(function(g) identical(as.character(g$month), mo), granules), function(g) g$r)
    if (length(tiles) == 1L) tiles[[1]] else do.call(terra::mosaic, c(unname(tiles), list(fun = "mean")))
  })
  annual <- if (length(monthly) == 1L) monthly[[1]] else terra::app(terra::rast(monthly), mean, na.rm = TRUE)
  terra::project(annual, crs_4326)
}

# Raster-level SCALE tripwire (findings dossier D): a correctly scaled+masked annual-mean NDVI raster sits in
# ~[-0.25, 1.05]. Unscaled DN (~ -2000..10000) or unmasked fill blows this immediately. Fail-closed.
ndvi_assert_raster_scale <- function(r) {
  # compute = TRUE forces min/max from the ACTUAL cells (CR #40): terra::minmax() otherwise reads stored range
  # metadata, which for a derived/lazy raster (app/project output from a real granule) can be unset (Inf/-Inf) -
  # so the gate would false-fail on good data instead of validating the values ndvi_annual_mean_4326 produced.
  mm <- as.numeric(terra::minmax(r, compute = TRUE))
  if (!all(is.finite(mm)) || mm[1] < -0.25 || mm[2] > 1.05)
    stop(sprintf("FAIL-CLOSED: annual-mean NDVI raster range [%.3f, %.3f] is implausible - the 0.0001 scale was likely never applied, or fill/units are wrong.", mm[1], mm[2]))
  invisible(TRUE)
}

# COMPLETENESS guard (Codex #40 P1): a NON-EMPTY MODIS cache is not necessarily a COMPLETE year - an interrupted
# earthaccess.download or a one-month run leaves a partial cache. The builder skips the fetch when any .hdf is
# present, so without this a partial-year / single-tile subset would be averaged and MISLABELLED the annual mean
# (a 6-month or west-only mean can still pass the scale + gradient gates). Require all `n_months` distinct monthly
# keys AND every covering tile present for EACH month (Rwanda straddles 30 deg E -> >=2 sinusoidal tiles). This is
# the MODIS analog of the ERA5 12-monthly-layer guard. Fail-closed (delete the cache dir + re-fetch) otherwise.
ndvi_assert_complete_year <- function(month_keys, tile_keys, n_months = 12L) {
  months    <- unique(month_keys)
  all_tiles <- sort(unique(tile_keys[!is.na(tile_keys) & nzchar(tile_keys)]))
  month_ok  <- tapply(tile_keys, month_keys, function(t) all(all_tiles %in% t))
  if (length(all_tiles) < 2L || length(months) != n_months || !isTRUE(all(month_ok)))
    stop(sprintf("FAIL-CLOSED: incomplete MODIS cache - found %d month(s) and tile(s) {%s}; a full annual mean needs %d months x each covering tile (>=2; Rwanda straddles 30 deg E). The download was likely interrupted - delete the cache dir and re-fetch. (The illustrative-fixture NDVI layer is unaffected.)",
                 length(months), paste(all_tiles, collapse = ", "), n_months))
  invisible(TRUE)
}

# Two-part per-district GROUND-TRUTH gate (data correctness, not just structure):
#  (a) BAND: every district annual-mean NDVI in a plausible band; HARD FAIL outside [0.15, 0.95] (Rwanda is
#      vegetated everywhere; eastern savanna annual mean ~0.4-0.6, western forest ~0.7-0.85).
#  (b) DIRECTION: western montane-forest poles (Nyungwe: Nyamasheke/Nyaruguru/Rusizi) must be >= `margin` GREENER
#      than eastern savanna poles (Akagera: Nyagatare/Kirehe). Strong forest-vs-savanna poles (NOT blunt regional
#      averages) - gate on absolute LEVEL, so the eastern-greening trend + central-plateau/Kigali confounders
#      cannot false-fail it. Fail-closed if either pole set is missing. margin = 0.05 sits COMFORTABLY BELOW the
#      real observed ~0.10 gradient (live 2023 MOD13A3: W-forest 0.69 vs E-savanna 0.59) - enough to catch an
#      inversion / gross error (gap <= 0) with headroom for the known year-to-year eastern-greening narrowing,
#      WITHOUT asserting this year's exact gradient magnitude (a threshold must sit below the signal, not on it).
ndvi_ground_truth_gate <- function(district, mean_ndvi,
                                   west_forest = c("Nyamasheke", "Nyaruguru", "Rusizi"),
                                   east_savanna = c("Nyagatare", "Kirehe"),
                                   margin = 0.05) {
  bad <- which(mean_ndvi <= 0.15 | mean_ndvi >= 0.95)
  if (length(bad))
    stop(sprintf("FAIL-CLOSED: NDVI outside the plausible [0.15, 0.95] band (scale/fill/aggregation bug): %s",
                 paste(sprintf("%s=%.2f", district[bad], mean_ndvi[bad]), collapse = ", ")))
  wf <- mean_ndvi[district %in% west_forest]
  es <- mean_ndvi[district %in% east_savanna]
  if (!length(wf) || !length(es))
    stop("FAIL-CLOSED: ground-truth pole districts (west forest / east savanna) not found in the data - cannot verify the gradient.")
  if (!(mean(wf) - mean(es) >= margin))
    stop(sprintf("FAIL-CLOSED: ground-truth violated - western montane-forest districts (mean NDVI %.2f) are NOT >= %.2f greener than eastern savanna districts (mean NDVI %.2f). Likely a mosaic/reproject/units bug.",
                 mean(wf), margin, mean(es)))
  invisible(TRUE)
}
