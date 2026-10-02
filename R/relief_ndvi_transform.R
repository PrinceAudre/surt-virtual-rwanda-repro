#!/usr/bin/env Rscript
# HDF-free MOD13A3 NDVI transformation helpers.
#
# Version 1.4 makes quality handling explicit. The production reference builder
# uses MOD13A3 pixel reliability rank 0 (Good Data: use with confidence) by
# default. Rank 1 can be admitted deliberately, and `accepted_quality = NULL`
# is an explicit unfiltered mode. Fill/out-of-range NDVI is always masked.

suppressWarnings(suppressMessages({ library(terra) }))

# MOD13A3 v061 NDVI: int16, fill -3000, valid DN [-2000, 10000], scale 0.0001.
ndvi_scale_mask_mod13a3 <- function(r) {
  r[r < -2000 | r > 10000] <- NA
  r * 0.0001
}

ndvi_validate_quality_policy <- function(accepted_quality) {
  if (is.null(accepted_quality)) return(NULL)
  if (!length(accepted_quality) || any(is.na(accepted_quality)) ||
      any(accepted_quality != as.integer(accepted_quality)) ||
      any(!(accepted_quality %in% 0:3))) {
    stop("FAIL-CLOSED: MOD13A3 accepted quality ranks must be integers from 0 to 3, or NULL for explicit unfiltered mode.")
  }
  sort(unique(as.integer(accepted_quality)))
}

# Apply the MOD13A3 pixel-reliability policy before temporal aggregation.
# Rank meanings: 0 good, 1 marginal, 2 snow/ice, 3 cloudy; -1 is fill/no-data.
ndvi_apply_mod13a3_quality <- function(ndvi_raw, qa_raw = NULL,
                                       accepted_quality = 0L) {
  accepted_quality <- ndvi_validate_quality_policy(accepted_quality)
  scaled <- ndvi_scale_mask_mod13a3(ndvi_raw)
  if (is.null(accepted_quality)) return(scaled)
  if (is.null(qa_raw)) {
    stop("FAIL-CLOSED: MOD13A3 quality filtering requested but pixel-reliability raster is missing.")
  }
  if (!terra::compareGeom(ndvi_raw, qa_raw, stopOnError = FALSE,
                          crs = TRUE, ext = TRUE, rowcol = TRUE, res = TRUE)) {
    stop("FAIL-CLOSED: MOD13A3 NDVI and pixel-reliability rasters are not geometrically aligned.")
  }

  keep <- qa_raw == accepted_quality[[1]]
  if (length(accepted_quality) > 1L) {
    for (rank in accepted_quality[-1]) keep <- keep | (qa_raw == rank)
  }
  terra::ifel(keep, scaled, NA)
}

# Transform tile granules into an annual mean and temporal-completeness raster.
# Each granule is list(month=<key>, r=<raw NDVI>, qa=<raw pixel reliability>).
# Same-month tiles are mosaicked after QA masking. Annual means use available
# QA-accepted months only, but cells below `min_valid_month_fraction` are masked.
# The returned valid-month fraction is the fraction of monthly mosaics with a
# finite QA-accepted NDVI value before the minimum-completeness gate.
ndvi_annual_summary_4326 <- function(granules, crs_4326 = "EPSG:4326",
                                     accepted_quality = 0L,
                                     min_valid_month_fraction = 0.5) {
  if (!length(granules)) stop("FAIL-CLOSED: no NDVI granules to transform.")
  accepted_quality <- ndvi_validate_quality_policy(accepted_quality)
  if (!is.finite(min_valid_month_fraction) ||
      min_valid_month_fraction < 0 || min_valid_month_fraction > 1) {
    stop("FAIL-CLOSED: NDVI minimum valid-month fraction must be between 0 and 1.")
  }

  granules <- lapply(granules, function(g) {
    if (is.null(g$month) || is.null(g$r)) {
      stop("FAIL-CLOSED: each NDVI granule requires month and raster fields.")
    }
    g$r <- ndvi_apply_mod13a3_quality(
      g$r,
      if (is.null(g$qa)) NULL else g$qa,
      accepted_quality = accepted_quality
    )
    g
  })
  months <- unique(vapply(granules, function(g) as.character(g$month), character(1)))
  monthly <- lapply(months, function(mo) {
    tiles <- lapply(
      Filter(function(g) identical(as.character(g$month), mo), granules),
      function(g) g$r
    )
    if (length(tiles) == 1L) tiles[[1]] else
      do.call(terra::mosaic, c(unname(tiles), list(fun = "mean")))
  })
  stack <- terra::rast(monthly)
  n_months <- length(monthly)
  valid_fraction <- terra::app(stack, fun = function(x) sum(is.finite(x)) / n_months)
  annual <- if (n_months == 1L) monthly[[1]] else
    terra::app(stack, fun = function(x) {
      if (!any(is.finite(x))) return(NA_real_)
      mean(x[is.finite(x)])
    })
  annual <- terra::ifel(valid_fraction >= min_valid_month_fraction, annual, NA)

  list(
    mean = terra::project(annual, crs_4326),
    valid_month_fraction = terra::project(valid_fraction, crs_4326, method = "bilinear"),
    accepted_quality = accepted_quality,
    min_valid_month_fraction = min_valid_month_fraction,
    month_count = n_months
  )
}

# Backward-compatible raster-only wrapper. Production code should use the full
# summary so QA coverage is retained. Explicit unfiltered mode remains possible.
ndvi_annual_mean_4326 <- function(granules, crs_4326 = "EPSG:4326",
                                  accepted_quality = NULL,
                                  min_valid_month_fraction = 0) {
  ndvi_annual_summary_4326(
    granules,
    crs_4326 = crs_4326,
    accepted_quality = accepted_quality,
    min_valid_month_fraction = min_valid_month_fraction
  )$mean
}

ndvi_assert_raster_scale <- function(r) {
  mm <- as.numeric(terra::minmax(r, compute = TRUE))
  if (!all(is.finite(mm)) || mm[1] < -0.25 || mm[2] > 1.05) {
    stop(sprintf(
      "FAIL-CLOSED: annual-mean NDVI raster range [%.3f, %.3f] is implausible; check scale, fill, QA, or units.",
      mm[1], mm[2]
    ))
  }
  invisible(TRUE)
}

ndvi_assert_complete_year <- function(month_keys, tile_keys, n_months = 12L) {
  months <- unique(month_keys)
  all_tiles <- sort(unique(tile_keys[!is.na(tile_keys) & nzchar(tile_keys)]))
  month_ok <- tapply(tile_keys, month_keys, function(t) all(all_tiles %in% t))
  if (length(all_tiles) < 2L || length(months) != n_months || !isTRUE(all(month_ok))) {
    stop(sprintf(
      paste0(
        "FAIL-CLOSED: incomplete MODIS cache - found %d month(s) and tile(s) {%s}; ",
        "a full annual mean needs %d months x each covering tile."
      ),
      length(months), paste(all_tiles, collapse = ", "), n_months
    ))
  }
  invisible(TRUE)
}

# Rwanda-specific broad consistency tripwire, not independent validation.
ndvi_consistency_gate <- function(district, mean_ndvi,
                                  west_forest = c("Nyamasheke", "Nyaruguru", "Rusizi"),
                                  east_savanna = c("Nyagatare", "Kirehe"),
                                  margin = 0.05) {
  bad <- which(mean_ndvi <= 0.15 | mean_ndvi >= 0.95)
  if (length(bad)) {
    stop(sprintf(
      "FAIL-CLOSED: NDVI outside the plausible [0.15, 0.95] band: %s",
      paste(sprintf("%s=%.2f", district[bad], mean_ndvi[bad]), collapse = ", ")
    ))
  }
  wf <- mean_ndvi[district %in% west_forest]
  es <- mean_ndvi[district %in% east_savanna]
  if (!length(wf) || !length(es)) {
    stop("FAIL-CLOSED: consistency-gate pole districts not found in the data.")
  }
  if (!(mean(wf) - mean(es) >= margin)) {
    stop(sprintf(
      paste0(
        "FAIL-CLOSED: western forest mean NDVI %.2f is not at least %.2f greater ",
        "than eastern savanna mean %.2f."
      ),
      mean(wf), margin, mean(es)
    ))
  }
  invisible(TRUE)
}
