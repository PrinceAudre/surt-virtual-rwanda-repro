#!/usr/bin/env python3
# fetch_modis_ndvi.py - download MODIS/Terra MOD13A3 v061 monthly 1 km NDVI over Rwanda via the OFFICIAL NASA
# earthaccess client, for the climate-health NDVI layer (indicator #2b). Earthdata credentials are read by
# earthaccess from the netrc file it manages (machine urs.earthdata.nasa.gov) and are NEVER stored in this repo.
#
# OWNER ONE-TIME SETUP (Windows; the earthaccess analog of ERA5's cdsapi/.cdsapirc):
#   1. Create a free NASA Earthdata Login: https://urs.earthdata.nasa.gov
#   2. pip3 install earthaccess
#   3. Write the credential file ONCE (avoids the Windows _netrc/.netrc filename ambiguity - earthaccess writes
#      whatever name it later reads):  python -c "import earthaccess; earthaccess.login(strategy='interactive', persist=True)"
# Then the R builder (build_relief_climate_ndvi_real.R) runs this and aggregates to districts. Fail-closed: a
# missing client / missing creds / empty search stops with instructions and writes nothing (the illustrative
# fixture layer is unaffected).
#
# LICENSE: MOD13A3 is NASA CC0 (no product use-restriction marker) - redistributable. Cite Didan (2021),
# DOI 10.5067/MODIS/MOD13A3.061.
# USAGE: python fetch_modis_ndvi.py [year] [out_dir]
import sys, os

YEAR = sys.argv[1] if len(sys.argv) > 1 else "2023"
OUT_DIR = sys.argv[2] if len(sys.argv) > 2 else os.path.join(
    "02_data", "cache", "climate", "modis_ndvi", "mod13a3_%s" % YEAR)
os.makedirs(OUT_DIR, exist_ok=True)

try:
    import earthaccess
except ImportError:
    sys.exit("FAIL-CLOSED: the 'earthaccess' client is not installed. Run: pip3 install earthaccess "
             "(see https://github.com/nsidc/earthaccess).")

try:
    # Non-interactive ONLY (Codex #40 P2): a bare earthaccess.login() defaults to strategy="all", which falls
    # through to an INTERACTIVE prompt - in this unattended run (spawned by the R builder via system2) that would
    # BLOCK on stdin instead of failing closed. Force netrc, then env vars (EARTHDATA_USERNAME/PASSWORD); never interactive.
    try:
        earthaccess.login(strategy="netrc")           # reads machine urs.earthdata.nasa.gov from the managed netrc
    except Exception:
        earthaccess.login(strategy="environment")     # EARTHDATA_USERNAME / EARTHDATA_PASSWORD fallback (no-file)
except Exception as e:  # noqa: BLE001 - surface any auth/config problem as a clear fail-closed message
    sys.exit("FAIL-CLOSED: could not authenticate to NASA Earthdata (no valid netrc or EARTHDATA_USERNAME/"
             "EARTHDATA_PASSWORD env vars). Set up credentials ONCE with "
             "python -c \"import earthaccess; earthaccess.login(strategy='interactive', persist=True)\" "
             "(free account at https://urs.earthdata.nasa.gov). Underlying error: %s" % e)

# MOD13A3 v061 monthly 1 km NDVI over the Rwanda bounding box for the whole year. Rwanda straddles 30 deg E, so a
# bbox search returns the covering sinusoidal tiles (expect TWO: h20v09 west + h21v09 east) x 12 months. NDVI is
# stored int16 (scale 0.0001, fill -3000); the R builder scales/masks, and its ground-truth gate fail-closes if
# that is ever wrong.
results = earthaccess.search_data(
    short_name="MOD13A3",
    version="061",
    bounding_box=(28.8, -2.9, 30.95, -1.0),   # (W, S, E, N) Rwanda
    temporal=("%s-01-01" % YEAR, "%s-12-31" % YEAR),
)
if not results:
    sys.exit("FAIL-CLOSED: MOD13A3 v061 search returned 0 granules for %s over Rwanda - check the year/bbox/collection." % YEAR)

files = earthaccess.download(results, OUT_DIR)
print("downloaded %d MOD13A3 granule(s) for %s to %s" % (len(files), YEAR, OUT_DIR))
