#!/usr/bin/env Rscript
# Build district NDVI from MODIS/Terra MOD13A3 v061.
# Descriptive environmental layer only: not a forecast, surveillance output,
# or operational recommendation.
#
# Quality policy for v1.4: MOD13A3 pixel reliability rank 0 only (Good Data:
# use with confidence). Annual cells require at least 50% of monthly mosaics to
# contain QA-accepted NDVI. District output reports both finite annual-NDVI area
# coverage and mean monthly QA completeness. This policy is explicit in code and
# can be changed deliberately in the HDF-free transform helper.
#
# DATA DOI: 10.5067/MODIS/MOD13A3.061. NDVI scale 0.0001.
# USAGE: Rscript R/build_relief_climate_ndvi_real.R [year] [out] [district_geojson] [cache_dir]

suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))
HERE <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]),
                             winslash = "/", mustWork = TRUE))
ROOT <- normalizePath(file.path(HERE, ".."), winslash = "/", mustWork = TRUE)
source(file.path(HERE, "relief_ndvi_transform.R"))
source(file.path(HERE, "zonal_area_summary.R"))
args <- commandArgs(trailingOnly = TRUE)
YEAR <- if (length(args) >= 1 && nzchar(args[1])) as.integer(args[1]) else 2023L
OUT <- if (length(args) >= 2 && nzchar(args[2])) args[2] else file.path(ROOT, "generated", "relief_climate_ndvi.geojson")
GEOM <- if (length(args) >= 3 && nzchar(args[3])) args[3] else file.path(ROOT, "data", "relief_districts.geojson")
PY <- file.path(ROOT, "python", "fetch_modis_ndvi.py")
CACHE_ROOT <- if (length(args) >= 4 && nzchar(args[4])) args[4] else file.path(ROOT, "cache", "modis_ndvi")
CACHE <- file.path(CACHE_ROOT, sprintf("mod13a3_%d", YEAR))
ACCEPTED_QUALITY <- 0L
MIN_VALID_MONTH_FRACTION <- 0.5
SETUP <- paste(
  "create a NASA Earthdata Login, install earthaccess, and complete its external credential setup.",
  "Credentials remain outside this repository."
)

if (!file.exists(GEOM)) stop(sprintf("FAIL-CLOSED: district geometry not found: %s", GEOM))

hdfs <- list.files(CACHE, pattern = "\\.hdf$", full.names = TRUE, ignore.case = TRUE)
if (length(hdfs) == 0L) {
  py <- Sys.which("python"); if (!nzchar(py)) py <- Sys.which("python3")
  if (!nzchar(py)) stop(sprintf("FAIL-CLOSED: Python not found. To fetch MOD13A3: %s", SETUP))
  cat(sprintf("fetching MOD13A3 v061 %d via earthaccess ...\n", YEAR))
  code <- tryCatch(system2(py, c(shQuote(PY), YEAR, shQuote(CACHE))), error = function(e) 1L)
  hdfs <- list.files(CACHE, pattern = "\\.hdf$", full.names = TRUE, ignore.case = TRUE)
  if (!identical(code, 0L) || length(hdfs) == 0L) {
    stop(sprintf("FAIL-CLOSED: MODIS fetch did not produce HDF granules in %s. %s", CACHE, SETUP))
  }
}

# First-real-fetch seam: open a named MOD13A3 HDF-EOS SDS raw, preserving
# documented integer codes rather than allowing GDAL scale metadata to alter DN.
read_mod13a3_sds <- function(hdf, label, fallback_pattern = label) {
  cand <- sprintf('HDF4_EOS:EOS_GRID:"%s":MOD_Grid_monthly_1km_VI:"%s"', hdf, label)
  r <- tryCatch(terra::rast(cand, raw = TRUE), error = function(e) NULL)
  if (!is.null(r)) return(r)

  sds <- tryCatch(terra::describe(hdf, sds = TRUE), error = function(e) NULL)
  nm <- if (is.data.frame(sds)) sds$name else if (is.character(sds)) sds else character(0)
  hit <- grep(label, nm, fixed = TRUE)
  if (!length(hit)) hit <- grep(fallback_pattern, nm, ignore.case = TRUE)
  if (length(hit)) {
    s <- sub("^SUBDATASET_[0-9]+_NAME=", "", nm[hit[[1]]])
    r <- tryCatch(terra::rast(s, raw = TRUE), error = function(e) NULL)
    if (!is.null(r)) return(r)
  }
  stop(sprintf(
    "FAIL-CLOSED [first-real-fetch seam]: could not open MOD13A3 SDS '%s' in %s.",
    label, basename(hdf)
  ))
}

month_key <- function(f) {
  m <- regmatches(basename(f), regexpr("A[0-9]{7}", basename(f)))
  if (length(m)) m else basename(f)
}
tile_key <- function(f) {
  m <- regmatches(basename(f), regexpr("h[0-9]{2}v[0-9]{2}", basename(f)))
  if (length(m)) m else NA_character_
}

ndvi_assert_complete_year(
  vapply(hdfs, month_key, character(1)),
  vapply(hdfs, tile_key, character(1))
)

granules <- lapply(hdfs, function(f) list(
  month = month_key(f),
  r = read_mod13a3_sds(f, "1 km monthly NDVI", "NDVI"),
  qa = read_mod13a3_sds(f, "1 km monthly pixel reliability", "pixel reliability")
))
ndvi_summary <- ndvi_annual_summary_4326(
  granules,
  accepted_quality = ACCEPTED_QUALITY,
  min_valid_month_fraction = MIN_VALID_MONTH_FRACTION
)
r4326 <- ndvi_summary$mean
ndvi_assert_raster_scale(r4326)

d <- sf::st_read(GEOM, quiet = TRUE)
if (!("district" %in% names(d))) stop("FAIL-CLOSED: district geometry lacks a 'district' property.")
d$district <- as.character(d$district)

ndvi_area <- surt_area_weighted_summary(r4326, d)
month_coverage <- surt_area_weighted_summary(ndvi_summary$valid_month_fraction, d)
if (any(!is.finite(ndvi_area$value))) {
  stop("FAIL-CLOSED: a district got no QA-accepted annual NDVI value.")
}
d$mean_ndvi <- round(ndvi_area$value, 2)
d$valid_ndvi_area_fraction <- round(ndvi_area$valid_data_fraction, 4)
d$mean_valid_month_fraction <- round(month_coverage$value, 4)
ndvi_consistency_gate(d$district, d$mean_ndvi)

d$provenance <- sprintf(
  paste0(
    "MODIS MOD13A3 v061 (NASA LP DAAC), annual-mean NDVI %d; pixel reliability rank 0 only; ",
    "minimum valid-month fraction %.2f; surface-area-weighted district mean"
  ),
  YEAR, MIN_VALID_MONTH_FRACTION
)
keep <- d[, c(
  "district", "mean_ndvi", "valid_ndvi_area_fraction",
  "mean_valid_month_fraction", "provenance"
)]
v <- terra::vect(keep)
dir.create(dirname(OUT), recursive = TRUE, showWarnings = FALSE)
if (file.exists(OUT)) file.remove(OUT)
terra::writeVector(v, OUT, filetype = "GeoJSON")

wf <- keep$mean_ndvi[keep$district %in% c("Nyamasheke", "Nyaruguru", "Rusizi")]
es <- keep$mean_ndvi[keep$district %in% c("Nyagatare", "Kirehe")]
cat(sprintf(
  paste0(
    "REAL climate-NDVI: %d districts | %.2f-%.2f NDVI | QA-good annual area coverage %.3f-%.3f | ",
    "mean valid-month fraction %.3f-%.3f | west forest %.2f vs east savanna %.2f | MOD13A3 %d -> %s\n"
  ),
  nrow(keep), min(keep$mean_ndvi), max(keep$mean_ndvi),
  min(keep$valid_ndvi_area_fraction), max(keep$valid_ndvi_area_fraction),
  min(keep$mean_valid_month_fraction), max(keep$mean_valid_month_fraction),
  mean(wf), mean(es), YEAR, OUT
))
