#!/usr/bin/env Rscript
# build_relief_climate_ndvi_real.R - REAL per-district mean-NDVI choropleth from MODIS/Terra MOD13A3 v061 (NASA
# LP DAAC), indicator #2b of the climate-health feature. REPLACES the illustrative fixture (build_relief_climate_
# ndvi.R) through the SAME output geojson - the fixture's seam. Offline governed-prepare; NOT sourced by app.R.
# DESCRIPTIVE vegetation greenness - not a forecast, not surveillance, not operational; operational_use_allowed = FALSE.
#
# DATA: MOD13A3 v061 "1 km monthly NDVI" (NASA LP DAAC). LICENSE: CC0 (NASA "CC0 unless the product carries a
# use-restriction marker"; none observed - verified 2026-07-08, findings dossier B). Cite Didan (2021)
# DOI 10.5067/MODIS/MOD13A3.061. 1 km resolves Rwanda's districts. Fetched via the OFFICIAL earthaccess client
# (fetch_modis_ndvi.py), which reads the netrc earthaccess manages - Earthdata credentials are NEVER in this repo.
#
# OWNER ONE-TIME SETUP (Windows) before this can fetch real data (see fetch_modis_ndvi.py header): free NASA
# Earthdata account (urs.earthdata.nasa.gov), `pip3 install earthaccess`, then run once
# `python -c "import earthaccess; earthaccess.login(strategy='interactive', persist=True)"`. FAIL-CLOSED with these
# instructions until that is in place - and it writes NOTHING, so the illustrative fixture layer stays intact.
#
# TRANSFORM: the mask/scale/mosaic/reproject/annual-mean pipeline + the two-part ground-truth gate live in the
# HDF-FREE helper relief_ndvi_transform.R, which is EXECUTED + ASSERTED on a synthetic MODIS-sinusoidal fixture
# in the hermetic tests (mask fill, scaled max <=1, western forest >= 0.05 greener than eastern savanna, negative
# controls fail-closed). The ONE part that cannot be verified without a real granule - selecting the "1 km monthly
# NDVI" HDF-EOS subdataset - is isolated below as read_mod13a3_ndvi_sds() and flagged FIRST-REAL-FETCH SEAM: on the
# first real run, confirm it opens the NDVI SDS (the gate fail-closes VISIBLY on bad data - safe, not silent-wrong).
#
# GOVERNANCE: allow-list ONLY {district, mean_ndvi, provenance}. GEOMETRY: reuses relief_districts.geojson.
# OUTPUT (git-ignored): www/relief_climate_ndvi.geojson
# USAGE: Rscript tools/semantic_layers/experimental_maplibre_relief/build_relief_climate_ndvi_real.R [year] [out]
suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))
HERE <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
source(file.path(HERE, "relief_ndvi_transform.R"))   # ndvi_scale_mask_mod13a3 / ndvi_annual_mean_4326 / ndvi_assert_raster_scale / ndvi_ground_truth_gate
args <- commandArgs(trailingOnly = TRUE)
YEAR <- if (length(args) >= 1 && nzchar(args[1])) as.integer(args[1]) else 2023L
GEOM <- file.path("05_dashboard", "www", "relief_districts.geojson")
OUT  <- if (length(args) >= 2 && nzchar(args[2])) args[2] else file.path("05_dashboard", "www", "relief_climate_ndvi.geojson")
PY   <- file.path(HERE, "fetch_modis_ndvi.py")
CACHE <- file.path("02_data", "cache", "climate", "modis_ndvi", sprintf("mod13a3_%d", YEAR))
SETUP <- paste("create a free NASA Earthdata Login (https://urs.earthdata.nasa.gov), `pip3 install earthaccess`, then run once",
               "`python -c \"import earthaccess; earthaccess.login(strategy='interactive', persist=True)\"`.",
               "Credentials stay in the earthaccess-managed netrc - never in this repo.")

if (!file.exists(GEOM)) stop(sprintf("FAIL-CLOSED: district geometry %s not found - build the population layer first.", GEOM))

# --- Fetch ONCE into the git-ignored cache via the official earthaccess client (fail-closed with setup steps). ---
hdfs <- list.files(CACHE, pattern = "\\.hdf$", full.names = TRUE, ignore.case = TRUE)
if (length(hdfs) == 0L) {
  py <- Sys.which("python"); if (!nzchar(py)) py <- Sys.which("python3")
  if (!nzchar(py)) stop(sprintf("FAIL-CLOSED: Python not found - to fetch REAL MODIS NDVI: %s Then re-run. (The illustrative-fixture NDVI layer is unaffected.)", SETUP))
  cat(sprintf("fetching MOD13A3 v061 monthly NDVI %d via earthaccess ...\n", YEAR))
  code <- tryCatch(system2(py, c(shQuote(PY), YEAR, shQuote(CACHE))), error = function(e) 1L)
  hdfs <- list.files(CACHE, pattern = "\\.hdf$", full.names = TRUE, ignore.case = TRUE)
  if (!identical(code, 0L) || length(hdfs) == 0L)
    stop(sprintf("FAIL-CLOSED: the MODIS fetch did not produce HDF granules in %s. Most likely the earthaccess client / Earthdata creds are not set up yet: %s Then re-run. (The illustrative-fixture NDVI layer is unaffected.)", CACHE, SETUP))
}

# --- FIRST-REAL-FETCH SEAM (the only part not exercised by the synthetic-SIN test): open the "1 km monthly NDVI"
# HDF-EOS subdataset. Tries GDAL subdataset discovery, then the documented MOD13A3 HDF-EOS2 path; fail-closed. ---
read_mod13a3_ndvi_sds <- function(hdf) {
  # raw = TRUE is REQUIRED (verified on the first real granule): MOD13A3 stores scale=10000 with the MODIS
  # "divide-by" convention, but terra/GDAL reads that attribute and MULTIPLIES (CF convention) -> values blow up
  # ~1e8 and every vegetated pixel is wrongly masked as > 10000. Reading raw returns the true int16 DN
  # (-2000..10000, fill -3000); relief_ndvi_transform.R then applies the documented x0.0001 itself.
  # Read order: the DETERMINISTIC MOD13A3 HDF-EOS connection string FIRST (version-independent), then a
  # TYPE-GUARDED describe() discovery fallback. terra::describe(sds=TRUE) returns a data.frame ($name) on newer
  # terra but a plain CHARACTER VECTOR on others (Codex #41) - `$name` on a character vector errors, so branch on
  # the type rather than assuming a data.frame.
  cand <- sprintf('HDF4_EOS:EOS_GRID:"%s":MOD_Grid_monthly_1km_VI:"1 km monthly NDVI"', hdf)
  r <- tryCatch(terra::rast(cand, raw = TRUE), error = function(e) NULL)
  if (!is.null(r)) return(r)
  sds <- tryCatch(terra::describe(hdf, sds = TRUE), error = function(e) NULL)
  nm  <- if (is.data.frame(sds)) sds$name else if (is.character(sds)) sds else character(0)
  hit <- grep("1 km monthly NDVI", nm); if (!length(hit)) hit <- grep("NDVI", nm)
  if (length(hit)) {
    s <- sub("^SUBDATASET_[0-9]+_NAME=", "", nm[hit[1]])   # a character-vector entry may carry this gdalinfo prefix
    r <- tryCatch(terra::rast(s, raw = TRUE), error = function(e) NULL)
    if (!is.null(r)) return(r)
  }
  stop(sprintf("FAIL-CLOSED [first-real-fetch seam]: could not open the '1 km monthly NDVI' subdataset of %s - verify the HDF-EOS subdataset name on the first real granule.", basename(hdf)))
}
# Month + tile keys from the MOD13A3 filename (MOD13A3.A<year><doy>.h<HH>v<VV>.061...): monthly product -> one
# date per month; same-month tiles (h20v09 + h21v09) share the month key and are mosaicked together by the transform.
month_key <- function(f) { m <- regmatches(basename(f), regexpr("A[0-9]{7}", basename(f))); if (length(m)) m else basename(f) }
tile_key  <- function(f) { m <- regmatches(basename(f), regexpr("h[0-9]{2}v[0-9]{2}", basename(f))); if (length(m)) m else NA_character_ }

# COMPLETENESS guard BEFORE transforming (Codex #40 P1): the fetch is SKIPPED whenever the cache holds any .hdf,
# so an interrupted download / one-month run could otherwise be averaged and mislabelled the annual mean. Require
# all 12 monthly keys x each covering tile; fail-closed on a partial cache. (MODIS analog of ERA5's 12-layer guard.)
ndvi_assert_complete_year(vapply(hdfs, month_key, character(1)), vapply(hdfs, tile_key, character(1)))

granules <- lapply(hdfs, function(f) list(month = month_key(f), r = read_mod13a3_ndvi_sds(f)))
r4326 <- ndvi_annual_mean_4326(granules)     # scale/mask -> mosaic -> annual mean -> EPSG:4326 (verified transform)
ndvi_assert_raster_scale(r4326)              # raster-level scale/units tripwire (fail-closed)

d <- sf::st_read(GEOM, quiet = TRUE)
if (!("district" %in% names(d))) stop("FAIL-CLOSED: district geometry lacks a 'district' property.")
d$district <- as.character(d$district)
d$mean_ndvi <- round(exactextractr::exact_extract(r4326, d, "mean", progress = FALSE), 2)
if (any(is.na(d$mean_ndvi))) stop("FAIL-CLOSED: a district got no NDVI value (CRS / coverage / subdataset problem).")

# --- GROUND-TRUTH GATE (two-part: band/scale tripwire + west-forest >= 0.05 greener than east-savanna). ---
ndvi_ground_truth_gate(d$district, d$mean_ndvi)

d$provenance <- sprintf("MODIS MOD13A3 v061 (NASA LP DAAC, CC0), annual-mean NDVI %d", YEAR)
keep <- d[, c("district", "mean_ndvi", "provenance")]
v <- terra::vect(keep)
if (file.exists(OUT)) file.remove(OUT)
terra::writeVector(v, OUT, filetype = "GeoJSON")
wf <- keep$mean_ndvi[keep$district %in% c("Nyamasheke", "Nyaruguru", "Rusizi")]
es <- keep$mean_ndvi[keep$district %in% c("Nyagatare", "Kirehe")]
cat(sprintf("REAL climate-NDVI choropleth: %d districts | %.2f-%.2f NDVI | W-forest mean %.2f >= E-savanna mean %.2f + 0.05 (ground-truth OK) | MOD13A3 %d -> %s\n",
            nrow(keep), min(keep$mean_ndvi), max(keep$mean_ndvi), mean(wf), mean(es), YEAR, OUT))
