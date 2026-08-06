# Reproducibility

## Release boundary

The active SoftwareX candidate is SuRT-GeoHarmonizer version `1.3.0` on branch `codex/softwarex-submission-v1.3.0`.

The historical release `v1.2.0`, DOI `10.5281/zenodo.21744708`, remains immutable. Version `1.3.0` must receive its own Git tag and Zenodo version DOI after the exact candidate commit passes all checks. The concept DOI for all releases is `10.5281/zenodo.21671788`.

## Environment restoration

`renv.lock` records the R dependency graph. Restore it from the repository root:

```text
Rscript -e "renv::restore(prompt = FALSE)"
```

The validated Linux workflow uses R 4.6.0 with geospatial system libraries for GDAL, GEOS, PROJ, and UDUNITS. Python 3 orchestrates validation and provider clients.

Optional real-data provider clients are pinned in `requirements-providers.txt`:

```text
python -m pip install -r requirements-providers.txt
```

The account-free pathway does not require those packages.

## Complete account-free verification

Run:

```text
python python/run_all_checks.py
```

The command executes 48 explicit behavioural and contract outcomes:

1. nine provenance-labelling assertions in `R/demo_value_class.R`;
2. nine controlled environmental-transformation assertions in `R/test_fixture_pipeline.R`;
3. six geometry-agnostic transformation assertions in `R/test_portability_fixture.R`;
4. seven generic administrative-harmonizer assertions in `R/test_generic_harmonizer.R`;
5. seven deliberate transformation failure assertions in `R/test_failure_modes.R`;
6. five valid GeoJSON release checks in `python/validate_release_contract.py`; and
7. five deliberate release-corruption rejections in the same Python validator.

The runner also:

- validates SoftwareX candidate metadata;
- audits the SoftwareX manuscript;
- verifies the complete tracked-file manifest;
- writes `generated/verification_summary.json`;
- writes `generated/generic_admin_example.geojson`;
- writes the existing controlled fixture outputs.

The fixtures require no private repository, provider account, network request, or unpublished data.

## Generic administrative-unit interface

Display the command-line help:

```text
Rscript R/harmonize_admin_raster.R --help
```

Minimal invocation:

```text
Rscript R/harmonize_admin_raster.R \
  --raster input.tif \
  --boundaries units.geojson \
  --id-field admin_code \
  --value-name environmental_mean \
  --output generated/environmental_mean.geojson \
  --provenance "Source, product, period, method and applicable terms"
```

Optional arguments support:

- raster layer selection;
- scale and offset conversion;
- lower and upper no-data masking;
- output rounding;
- fail-closed minimum and maximum bounds.

The interface transforms extraction geometry to the raster CRS, calculates coverage-fraction-weighted polygon means, requires a finite value for every unit, normalizes output geometry to EPSG:4326, and writes only `unit_id`, the requested measurement property, `provenance`, and geometry.

Run the self-contained arbitrary-region example:

```text
Rscript R/test_generic_harmonizer.R
```

It creates projected polygons and a raster in a temporary directory and writes a deterministic GeoJSON example under `generated/`.

## Direct component commands

```text
Rscript R/demo_value_class.R
Rscript R/test_fixture_pipeline.R
Rscript R/test_portability_fixture.R
Rscript R/test_generic_harmonizer.R
Rscript R/test_failure_modes.R
python python/validate_release_contract.py
python python/validate_candidate_metadata.py
python python/audit_manuscript.py
```

`python/validate_release_contract.py --skip-failure-tests` validates the committed reference layers without injecting corrupted copies.

## Public CHIRPS numerical validation

Run:

```text
Rscript R/validate_chirps_rainfall.R 2023
```

Optional positional arguments are:

1. year;
2. CHIRPS cache directory; and
3. output directory.

The workflow:

1. downloads or reuses the public CHIRPS v2.0 annual raster;
2. masks negative no-data values;
3. recomputes district means with `exactextractr`;
4. cross-checks the same source and geometry with `terra::extract(..., exact = TRUE)`;
5. recalculates means with cell-area weights; and
6. writes district-level CSV and JSON evidence.

Current results for the tested 2023 source and Rwanda geometry are:

- 30 of 30 archived values reproduced exactly after rounding;
- maximum `terra` versus `exactextractr` difference: 0.000136 mm;
- root mean square cross-engine difference: 0.000064 mm;
- maximum cell-area-weighting difference: 0.005127 mm;
- root mean square weighting difference: 0.002385 mm.

This is computational reproduction of the CHIRPS layer, not validation of CHIRPS observational accuracy. Equivalent independent numerical validation has not been completed for ERA5-Land, MODIS, or HAND.

## Rwanda reference builders

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

Access requirements:

- CHIRPS: public network download, no account;
- HAND: public network download, no account;
- ERA5-Land: Copernicus Climate Data Store account, accepted terms, and `.cdsapirc`;
- MODIS: NASA Earthdata account and non-interactive `earthaccess` credentials.

No credential is stored in the repository. Provider services and products can change independently of this release.

## Manuscript figures

Generate the existing architecture, map, and profile figures from committed GeoJSON files:

```text
Rscript R/make_manuscript_figures.R
```

Outputs are written to `paper/figures/generated/` and are excluded from version control. GitHub Actions retain the exact evidence bundle. `paper/figures/ALT_TEXT.md` records accessibility text.

## Integrity and final release

During development, `CHECKSUMS.sha256` must match the complete tracked candidate tree. Validate it with:

```text
python python/build_checksum_manifest.py --all-tracked --check
```

After every other file is frozen, regenerate it:

```text
python python/build_checksum_manifest.py --all-tracked --write
```

The final release sequence is:

1. run all checks on the exact candidate commit;
2. regenerate the all-tracked manifest;
3. rerun all checks;
4. merge the reviewed candidate without additional file changes;
5. tag the exact commit `v1.3.0`;
6. create the corresponding GitHub release;
7. archive that tag as a new Zenodo version;
8. insert the new version DOI into the README, `CITATION.cff`, manuscript, and release validator;
9. regenerate the manifest and rerun exact-head validation;
10. submit the exact archived source to SoftwareX.

A checksum establishes byte-level integrity. It does not establish scientific validity.

## Reproducibility limits

- The account-free pathway validates specified transformations, interfaces, failure handling, schemas, and integrity.
- The generic example demonstrates an end-to-end arbitrary polygon/raster pathway but is synthetic, not a second-country scientific validation.
- ERA5-Land and MODIS rebuilds require provider accounts.
- Annual administrative summaries suppress seasonality, extremes, and within-unit heterogeneity.
- MODIS quality and reliability flags are not applied in the current reference implementation.
- HAND at or below 5 m is a terrain descriptor, not observed flooding or a validated hazard.
- Only CHIRPS currently has an independent public-data numerical cross-check.
