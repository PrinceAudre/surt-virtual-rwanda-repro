#!/usr/bin/env python3
# fetch_era5land_temperature.py - download ERA5-Land monthly-mean 2m_temperature for Rwanda via the OFFICIAL
# Copernicus CDS API (cdsapi) client for the district temperature layer. The API key is read from
# %USERPROFILE%\.cdsapirc by cdsapi.Client() and is NEVER stored in this repo.
#
# OWNER ONE-TIME SETUP (Windows; see ECMWF "How to install and use CDS API on Windows"):
#   1. Register / log in at https://cds.climate.copernicus.eu and accept the ERA5-Land licence.
#   2. pip3 install cdsapi
#   3. Create %USERPROFILE%\.cdsapirc with the 2-line url+key from https://cds.climate.copernicus.eu/how-to-api
# Then the R builder (build_relief_climate_temperature.R) runs this and aggregates to districts. Fail-closed:
# a missing client/key stops with instructions and writes nothing.
#
# USAGE: python fetch_era5land_temperature.py [year] [out.nc]
import sys
from pathlib import Path

YEAR = sys.argv[1] if len(sys.argv) > 1 else "2023"
ROOT = Path(__file__).resolve().parents[1]
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "cache" / "era5land" / ("era5land_t2m_%s.nc" % YEAR)
OUT.parent.mkdir(parents=True, exist_ok=True)

try:
    import cdsapi
except ImportError:
    sys.exit("FAIL-CLOSED: the 'cdsapi' client is not installed. Run: pip3 install cdsapi "
             "(see https://cds.climate.copernicus.eu/how-to-api).")

try:
    client = cdsapi.Client()  # reads %USERPROFILE%\.cdsapirc (url + personal access token)
except Exception as e:  # noqa: BLE001 - surface any key/config problem as a clear fail-closed message
    sys.exit("FAIL-CLOSED: could not initialise the CDS client - is %%USERPROFILE%%\\.cdsapirc set up with "
             "your url+key from https://cds.climate.copernicus.eu/how-to-api ? Underlying error: %s" % e)

# ERA5-Land monthly-averaged 2m air temperature over the Rwanda bounding box. NOTE: ERA5 2m_temperature is in
# KELVIN - the R builder converts to degrees C, and its consistency gate (10-30 C + highlands cooler) will
# fail-closed if that conversion is ever wrong.
client.retrieve(
    "reanalysis-era5-land-monthly-means",
    {
        "product_type": "monthly_averaged_reanalysis",
        "variable": "2m_temperature",
        "year": str(YEAR),
        "month": ["%02d" % m for m in range(1, 13)],
        "time": "00:00",
        "area": [-1.0, 28.8, -2.9, 30.95],  # N, W, S, E (Rwanda)
        "data_format": "netcdf",
        "download_format": "unarchived",  # ask for a raw .nc; the modern CDS otherwise wraps the netCDF in a .zip
    },
    str(OUT),
)

# Defensive: the modern CDS can still deliver a ZIP (netCDF wrapped inside). terra cannot open that, so if OUT is
# actually a zip, extract the single netCDF to OUT. Fail-closed if the zip is empty or split into multiple files
# (the builder expects ONE 12-month netCDF; a multi-file split would need a merge step).
import zipfile
if zipfile.is_zipfile(OUT):
    zpath = Path(str(OUT) + ".zip")
    OUT.replace(zpath)
    with zipfile.ZipFile(zpath) as z:
        ncs = [n for n in z.namelist() if n.lower().endswith(".nc")]
        if not ncs:
            sys.exit("FAIL-CLOSED: the CDS download was a zip with no .nc inside: %s" % z.namelist())
        if len(ncs) > 1:
            sys.exit("FAIL-CLOSED: the CDS zip has %d .nc files %s - the builder expects a single 12-month netCDF; a merge step is needed." % (len(ncs), ncs))
        with z.open(ncs[0]) as src, OUT.open("wb") as dst:
            dst.write(src.read())
    zpath.unlink()
print("wrote %s" % OUT)
