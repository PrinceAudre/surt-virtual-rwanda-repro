# SuRT-Virtual Rwanda: reproducibility artifact

Reproducibility artifact for the paper *A reproducible, provenance-transparent framework for descriptive climate-linked disease-risk evidence integration across a national district grid: design and proof-of-concept for Rwanda's 30 districts*.

It contains the climate-integration pipeline and the provenance / value-class discipline described in that paper, together with the real, openly-licensed climate layers for Rwanda's 30 districts.

## What this is, and what it is not

This is a **reduced, honestly-scoped** artifact. It is **not** the whole SuRT-Virtual Rwanda application.

- It **is**: the real climate and earth-observation data pipeline (rainfall, temperature, vegetation greenness, and terrain flood-susceptibility, aggregated to Rwanda's 30 districts); the generic provenance / value-class functions that enforce the honesty discipline; and the resulting real climate layers as data.
- It is **not**: the full application. The application's real methodology register, its interactive dashboard, and its operational-adjacent layer (for example decision-support queues, forecast and supply / workforce views) are deliberately **not included**. They remain a private, non-operational research prototype.
- The disease-side signals in the application are **synthetic and illustrative**, so this artifact ships **no disease data at all**. It ships only the **real climate data** and the code. The value-class functions are demonstrated against a small, clearly-labelled illustrative example register (`R/example_register.R`), which is **not** the application's register.

**Non-operational.** Nothing here is validated for, or intended for, clinical, operational, or resource-allocation use (`operational_use_allowed = FALSE`). The climate data are real and openly licensed; they are provided for descriptive research and reproducibility only.

## Contents

- `R/` climate pipeline (`build_relief_climate_*.R` + `relief_*_transform.R` + `relief_geojson_common.R` + `build_relief_districts.R`), the provenance / value-class module (`provenance_value_class.R`), the display markers (`honesty_markers.R`), an illustrative example register (`example_register.R`), and a runnable demo with checks (`demo_value_class.R`).
- `python/` the two official-client fetchers for ERA5-Land (Copernicus CDS) and MODIS NDVI (NASA Earthdata). No credentials are stored here; each reads the user's own account credentials from the standard local files.
- `data/` the real climate layers for Rwanda's 30 districts as GeoJSON (rainfall, temperature, NDVI, flood-susceptibility), plus the district base layer. See `DATA_DICTIONARY.md` and `NOTICE.md`.

## Reproducing the climate layers

Requirements: R (packages `terra`, `sf`, `exactextractr`, and `jsonlite`), and Python 3 with the `cdsapi` and `earthaccess` clients for the two fetchers.

1. The district base layer (`data/relief_districts.geojson`) is built from the World Bank "Rwanda Admin Boundaries and Villages" shapefile (CC BY 4.0); see `build_relief_districts.R`.
2. Each climate builder fetches its source once into a local cache, aggregates it to the 30 district polygons, and writes a GeoJSON carrying a `provenance` string. The scripts are reproduced verbatim from the application and use the application's directory layout, so run them from a working directory that has `05_dashboard/www/relief_districts.geojson`, or adjust the paths at the top of each script.
   - Rainfall: `build_relief_climate_rainfall.R` (CHIRPS v2.0; no credentials needed).
   - Temperature: `build_relief_climate_temperature.R` + `python/fetch_era5land_temperature.py` (needs a free Copernicus CDS account).
   - NDVI: `build_relief_climate_ndvi_real.R` + `python/fetch_modis_ndvi.py` (needs a free NASA Earthdata account).
   - Flood-susceptibility: `build_relief_climate_flood.R` (HAND; no credentials needed).

The pre-built layers in `data/` are the outputs of exactly these scripts for 2023.

## The provenance / value-class discipline

`R/provenance_value_class.R` holds the generic functions (reproduced from the application) that implement the discipline the paper describes: a methodology register in which each displayed output declares an evidence class (`sound` = a real, documented method on real or public data; `illustrative` = any output computed on synthetic or placeholder data) and a method class, validated for shape, with a **fail-closed** rule that an output is treated as illustrative unless the register explicitly declares it `sound`.

Run the demo and checks:

    Rscript R/demo_value_class.R

## Licenses

- **Code**: MIT (see `LICENSE`).
- **Data**: per-source, in `data/`. District boundaries are World Bank CC BY 4.0; CHIRPS is public domain / CC0; ERA5-Land is CC-BY; MODIS is CC0; the district population figure in the base layer is a modelled prototype estimate from WorldPop under ODbL. Full per-file attributions and required citations are in **`NOTICE.md`**.

## Verification and environment

All files carry SHA-256 checksums in `CHECKSUMS.sha256` (verify with `sha256sum -c CHECKSUMS.sha256` on Linux/macOS, or `Get-FileHash <file> -Algorithm SHA256` in PowerShell). The exact R and package versions used to produce the released layers and run the demonstration are recorded in `environment.txt` (R 4.6.0 with terra, sf, exactextractr, jsonlite). A full dependency lockfile and a continuous-integration run on a clean machine are planned but not yet included.

## How to cite

Please cite the paper (Tuyishime Audre Prince, independent researcher; ORCID 0009-0002-0799-3140) and this archived artifact (DOI to be added on deposit).

See also: `NOTICE.md` (attributions and data licenses), `DATA_DICTIONARY.md` (data fields), and `SECURITY_REVIEW.md` (what was reviewed and what was deliberately excluded).
