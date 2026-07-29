#!/usr/bin/env Rscript
# Build district mean temperature from ERA5-Land monthly means as an explicit
# offline preparation step. This is a descriptive layer, not a forecast,
# surveillance output, or operational output.
#
# DATA: ERA5-Land monthly-mean 2m air temperature (Copernicus C3S/ECMWF).
# LICENSE: Copernicus Products licence; attribution is required.
# ~0.1deg (~9-11 km) -> resolves Rwanda's districts (unlike NASA POWER's 0.5deg). Fetched via the OFFICIAL cdsapi
# client (fetch_era5land_temperature.py), which reads %USERPROFILE%\.cdsapirc - the key is NEVER in this repo.
#
# OWNER ONE-TIME SETUP (Windows) before this can fetch real data (see fetch_era5land_temperature.py header +
# the ECMWF "How to install and use CDS API on Windows" guide): register at cds.climate.copernicus.eu (+ accept
# the ERA5-Land licence), `pip3 install cdsapi`, create %USERPROFILE%\.cdsapirc from
# https://cds.climate.copernicus.eu/how-to-api . FAIL-CLOSED with these instructions until that is in place -
# and it writes NOTHING, so the illustrative fixture layer stays intact until a real run succeeds.
#
# CONSISTENCY GATE (fail closed): every district temperature is in a sane 10-30 C band and western/highland districts
# COOLER than eastern lowlands - catches the classic ERA5 Kelvin->Celsius bug (uncorrected ~290 K would blow the
# band) and any aggregation/CRS error. GOVERNANCE: allow-list ONLY {district, mean_temp_c, provenance}.
# USAGE: Rscript R/build_relief_climate_temperature.R [year] [out] [district_geojson] [cache_dir]
suppressWarnings(suppressMessages({ library(terra); library(sf); library(exactextractr) }))
args <- commandArgs(trailingOnly = TRUE)
YEAR <- if (length(args) >= 1 && nzchar(args[1])) as.integer(args[1]) else 2023L
HERE <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]),
                             winslash = "/", mustWork = TRUE))
ROOT <- normalizePath(file.path(HERE, ".."), winslash = "/", mustWork = TRUE)
OUT  <- if (length(args) >= 2 && nzchar(args[2])) args[2] else file.path(ROOT, "generated", "relief_climate_temp.geojson")
GEOM <- if (length(args) >= 3 && nzchar(args[3])) args[3] else file.path(ROOT, "data", "relief_districts.geojson")
CACHE_DIR <- if (length(args) >= 4 && nzchar(args[4])) args[4] else file.path(ROOT, "cache", "era5land")
# Shared transform and consistency helpers (temp_district_means / temp_district_lon / temp_consistency_gate) -
# sourced by BOTH this real builder AND the hermetic test, so the gate the real build runs (incl. the classic
# Kelvin->Celsius tripwire) is the exact gate CI exercises on a synthetic raster (no real download to cover it).
source(file.path(HERE, "relief_temp_transform.R"))
PY   <- file.path(ROOT, "python", "fetch_era5land_temperature.py")
NC   <- file.path(CACHE_DIR, sprintf("era5land_t2m_%d.nc", YEAR))
SETUP <- paste("register at https://cds.climate.copernicus.eu (accept the ERA5-Land licence), `pip3 install cdsapi`,",
               "and create %USERPROFILE%\\.cdsapirc from https://cds.climate.copernicus.eu/how-to-api (see the ECMWF",
               "CDS-API-on-Windows guide). The key stays in .cdsapirc - never in this repo.")

if (!file.exists(GEOM)) stop(sprintf("FAIL-CLOSED: district geometry not found: %s", GEOM))

# --- Fetch ONCE into the git-ignored cache via the official cdsapi client (fail-closed with setup steps). ---
if (!file.exists(NC)) {
  py <- Sys.which("python"); if (!nzchar(py)) py <- Sys.which("python3")
  if (!nzchar(py)) stop(sprintf("FAIL-CLOSED: Python not found - to fetch REAL ERA5-Land temperature: %s Then re-run. (The illustrative-fixture temperature layer is unaffected.)", SETUP))
  cat(sprintf("fetching ERA5-Land 2m_temperature %d via cdsapi (reads %%USERPROFILE%%\\.cdsapirc) ...\n", YEAR))
  code <- tryCatch(system2(py, c(shQuote(PY), YEAR, shQuote(NC))), error = function(e) 1L)
  if (!identical(code, 0L) || !file.exists(NC))
    stop(sprintf("FAIL-CLOSED: the ERA5-Land fetch did not produce %s. Most likely the CDS client/key is not set up yet: %s Then re-run. (The illustrative-fixture temperature layer is unaffected.)", NC, SETUP))
}

# ERA5-Land monthly means (12 layers) in KELVIN -> annual mean -> degrees C.
r <- terra::rast(NC)
# Fail-closed if the fetch was partial/corrupt: the fetcher requests all 12 months, so a complete file has
# exactly 12 layers. Without this, a truncated download (e.g. 6 months) would be silently averaged and then
# labelled the annual mean - a "beautiful but wrong" value the 10-30 C band + gradient gate could still pass.
if (terra::nlyr(r) != 12L)
  stop(sprintf("FAIL-CLOSED: %s has %d layer(s), expected 12 monthly means - the ERA5-Land fetch was incomplete/corrupt. Delete the cache file and re-run. (The illustrative-fixture temperature layer is unaffected.)",
               NC, terra::nlyr(r)))
r <- terra::app(r, mean, na.rm = TRUE) - 273.15

d <- sf::st_read(GEOM, quiet = TRUE)
if (!("district" %in% names(d))) stop("FAIL-CLOSED: district geometry lacks a 'district' property.")
d$district <- as.character(d$district)
# Per-district mean plus the bounded-value and WEST<EAST (highlands cooler) consistency gate now live in
# relief_temp_transform.R (sourced above), so the exact logic here is what the hermetic test executes. (The
# Kelvin->Celsius conversion + the 12-monthly-layer completeness guard above stay here - ERA5-specific.)
d$mean_temp_c <- temp_district_means(r, d)
.gt <- temp_consistency_gate(d$district, d$mean_temp_c, temp_district_lon(d))  # returns c(west, east) pole means

d$provenance <- sprintf("ERA5-Land 2m_temperature (Copernicus CDS; Copernicus Products licence), monthly-mean %d", YEAR)
keep <- d[, c("district", "mean_temp_c", "provenance")]
v <- terra::vect(keep)
dir.create(dirname(OUT), recursive = TRUE, showWarnings = FALSE)
if (file.exists(OUT)) file.remove(OUT)
terra::writeVector(v, OUT, filetype = "GeoJSON")
cat(sprintf("REAL climate-temp choropleth: %d districts | %.1f-%.1f C | highlands mean %.1f < lowlands mean %.1f (consistency gate OK) | ERA5-Land %d -> %s\n",
            nrow(keep), min(keep$mean_temp_c), max(keep$mean_temp_c), .gt["west"], .gt["east"], YEAR, OUT))
