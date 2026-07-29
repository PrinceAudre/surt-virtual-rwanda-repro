# Reproducibility

## Account-free verification

From the repository root, run:

```text
python python/run_all_checks.py
```

This command:

1. runs the nine-assertion provenance-labelling demonstration;
2. runs a hermetic, synthetic-fixture test through the released rainfall,
   temperature, NDVI, and HAND zonal-summary transforms;
3. writes `generated/fixture_pipeline_output.geojson`; and
4. verifies every file listed in `CHECKSUMS.sha256`.

The fixture test requires no private repository, network call, or data-provider
account. It tests the transformation and fail-closed consistency-gate code.
The fixture values are synthetic test inputs and are not research results.

## Rebuilding the released 2023 layers

The real builders use repository-relative paths and accept explicit output,
geometry, and cache paths. The CHIRPS and HAND builders require network access.
The ERA5-Land and MODIS builders additionally require the author's own free
Copernicus CDS and NASA Earthdata credentials, respectively. No credentials
are stored in the repository.

Examples:

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

Outputs default to `generated/`, and downloaded source files default to
`cache/`; both directories are excluded from Git. The committed district
geometry is the default aggregation frame.

## Environment

`renv.lock` records the R dependency graph. Restore it with:

```text
Rscript -e "renv::restore(prompt = FALSE)"
```

`environment.txt` records the environment used for the archived release.
Continuous integration runs the account-free checks on a clean GitHub-hosted
runner.
