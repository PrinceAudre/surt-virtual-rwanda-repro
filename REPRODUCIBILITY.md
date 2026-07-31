# Reproducibility

## Candidate and archive boundary

The current branch is an unreleased Earth Science Informatics journal candidate. It extends the published version 1.1.1 base archive, DOI `10.5281/zenodo.21677162`, with additional validators, figures, evidence summaries, and submission records. A new immutable GitHub tag and Zenodo version DOI are required before submission.

The commands below describe the candidate branch. They must not be attributed to version 1.1.1 unless the cited file is present in that archive.

## Environment restoration

`renv.lock` records the R dependency graph. Restore it from the repository root:

```text
Rscript -e "renv::restore(prompt = FALSE)"
```

The published base archive was prepared with R 4.6.0. `environment.txt` records its execution environment. Clean GitHub-hosted runners restore the lockfile before verification.

## Account-free verification

Run:

```text
python python/run_all_checks.py
```

The command executes 41 explicit outcomes in six groups:

1. nine provenance-labelling assertions in `R/demo_value_class.R`;
2. nine controlled environmental-transformation assertions in `R/test_fixture_pipeline.R`;
3. six geometry-agnostic portability assertions in `R/test_portability_fixture.R`;
4. seven deliberate transformation failure-injection assertions in `R/test_failure_modes.R`;
5. five valid GeoJSON release-layer contract checks in `python/validate_release_contract.py`; and
6. five deliberate release-corruption rejections in the same Python validator.

The runner also verifies every file currently listed in `CHECKSUMS.sha256` and writes:

- `generated/fixture_pipeline_output.geojson`;
- `generated/release_contract_summary.json`; and
- `generated/verification_summary.json`.

The synthetic fixtures require no private repository, provider account, network call, or unpublished data. They test specified transformation behaviour, interface independence, failure handling, and release-contract enforcement. They do not validate provider-product accuracy, the scientific meaning of the HAND threshold, or suitability for a downstream model.

### Direct component commands

```text
Rscript R/demo_value_class.R
Rscript R/test_fixture_pipeline.R
Rscript R/test_portability_fixture.R
Rscript R/test_failure_modes.R
python python/validate_release_contract.py
```

`python/validate_release_contract.py --skip-failure-tests` validates the committed release files without injecting corrupted copies.

## Public CHIRPS numerical validation

Run:

```text
Rscript R/validate_chirps_rainfall.R 2023
```

Optional positional arguments are:

1. year;
2. CHIRPS cache directory; and
3. output directory.

The default source is the public CHIRPS v2.0 annual GeoTIFF for 2023. The workflow:

1. downloads or reuses the annual raster;
2. masks negative no-data values;
3. recomputes district means with `exactextractr`, matching the release method;
4. cross-checks the same source raster and geometry with `terra::extract(..., exact = TRUE)`;
5. recalculates means with cell-area weights; and
6. writes district-level CSV and machine-readable JSON evidence.

The GitHub workflow `.github/workflows/public-data-validation.yml` also records the downloaded raster's SHA-256 digest and uploads the evidence as an artifact.

Current clean-CI results for the tested source raster, year, and Rwanda geometry are:

- 30 of 30 archived district values reproduced exactly after rounding to whole millimetres;
- maximum absolute `terra` versus `exactextractr` difference: 0.000136 mm;
- root mean square cross-engine difference: 0.000064 mm;
- maximum absolute cell-area-weighting difference: 0.005127 mm; and
- root mean square cell-area-weighting difference: 0.002385 mm.

This is computational reproduction of the CHIRPS layer, not validation of CHIRPS observational accuracy. Equivalent independent numerical validation has not been completed for ERA5-Land, MODIS, or HAND.

## Rebuilding the real-data layers

The builders use repository-relative defaults and accept explicit output, geometry, and cache paths:

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

Outputs default to `generated/`, and source downloads default to `cache/`. Both locations are excluded from Git. The committed district geometry is the default aggregation frame.

Access requirements:

- **CHIRPS:** public network download; no account.
- **HAND:** public network download; no account.
- **ERA5-Land:** free Copernicus Climate Data Store account, accepted product terms, and provider-standard `.cdsapirc` configuration.
- **MODIS:** free NASA Earthdata account and provider-standard authentication managed by `earthaccess`.

No credential is stored in the repository. Real-data rebuilds are provider- and network-dependent and may fail if external services, terms, products, or clients change.

## Manuscript figures

Generate all manuscript artwork and its numerical summary from the committed GeoJSON files:

```text
Rscript R/make_manuscript_figures.R
```

Outputs are written to `paper/figures/generated/` and include:

- caption-free SVG and EPS architecture line art;
- a 600 dpi four-panel TIFF map;
- individual SVG and EPS map panels;
- a 600 dpi TIFF and EPS standardized-profile chart; and
- `environmental_layer_summary.csv`.

The generated directory is excluded from version control. GitHub Actions retains the exact figure and machine-readable evidence bundle for inspection. `paper/figures/ALT_TEXT.md` records alternative text and accessibility checks for the final Word file.

## Integrity scope

`CHECKSUMS.sha256` is currently an explicit listed-file contract. It is not a complete manifest for every file in the evolving candidate branch. The final candidate release must regenerate a complete frozen manifest after all source, manuscript, figure, metadata, and submission files are finalized and before the Git tag and Zenodo deposit are created.

A successful checksum verification establishes byte-level integrity of listed files. It does not establish scientific validity.

## Reproducibility limits

- The fully account-free pathway covers fixtures, failure injection, release-contract checks, listed-file integrity, and public CHIRPS validation.
- ERA5-Land and MODIS rebuilds require provider accounts.
- The portability fixture establishes function-level identifier and geometry independence, not end-to-end deployment in another country.
- Annual administrative summaries suppress seasonality, extremes, and within-unit heterogeneity.
- MODIS quality flags are not applied in the current implementation.
- HAND at or below 5 m is a terrain descriptor, not observed flooding or validated hazard.
- Only CHIRPS currently has an independent public-data computational cross-check.
