# Reproducibility

## Development and release boundary

The active peer-review remediation target is SuRT-GeoHarmonizer version `1.4.0` on branch `review/softwarex-resubmission-v1.4.0`.

The published release `v1.3.0`, DOI `10.5281/zenodo.21840177`, remains immutable. The earlier release `v1.2.0`, DOI `10.5281/zenodo.21744708`, also remains immutable. The concept DOI for the release family is `10.5281/zenodo.21671788`.

No v1.4.0 tag or version DOI is valid until all reviewer-remediation release gates are satisfied on the exact release commit.

## Environment restoration

`renv.lock` records the R dependency graph. Restore it from the repository root:

```text
Rscript -e "renv::restore(prompt = FALSE)"
```

The current hosted account-free workflow uses R 4.6.0 on Ubuntu Linux with GDAL, GEOS, PROJ, UDUNITS, CMake, and related geospatial system dependencies. Python 3.12 orchestrates validation and provider clients.

Optional real-data provider clients are pinned in `requirements-providers.txt`:

```text
python -m pip install -r requirements-providers.txt
```

The account-free verification pathway does not require provider accounts, credentials, or those optional provider packages.

## Account-free development verification

Run:

```text
python python/run_all_checks.py
```

The runner reports test outcomes dynamically. It deliberately does not depend on a manually maintained total that can become stale when reviewer-driven tests are added.

The default account-free development suite includes:

1. provenance classification checks;
2. the hermetic environmental fixture pipeline;
3. geometry and CRS portability fixtures;
4. the full generic harmonizer interface contract;
5. surface-area-weighted zonal and partial-coverage regressions;
6. ERA5-Land annual-statistic tests, including leap-year handling;
7. MOD13A3 quality-policy and temporal-completeness tests;
8. HAND denominator and valid-area-coverage tests;
9. deliberate transformation failure injection;
10. valid and deliberately corrupted release-contract checks; and
11. SoftwareX remediation metadata validation.

The runner writes `generated/verification_summary.json`, the generic example, and controlled fixture outputs. Controlled fixtures require no private repository, provider account, network request, or unpublished data.

During active development, `CHECKSUMS.sha256` is rebuilt and checked by `.github/workflows/softwarex-manifest-refresh.yml` after each human source commit. The development runner intentionally does not require the pre-refresh human commit to contain its own future manifest update. This avoids a deterministic CI race between scientific verification and the automated manifest commit.

For a frozen release candidate, or after the dedicated manifest-refresh workflow has made the manifest current, run the strict mode:

```text
python python/run_all_checks.py --verify-manifest
```

Strict mode adds complete tracked-file manifest consistency and verification of every listed SHA-256 digest. The GitHub Actions reproducibility workflow exposes the same strict mode through its manual `verify_manifest` input.

The manuscript audit remains a separate explicit gate while the v1.4 manuscript is under reviewer-driven revision:

```text
python python/audit_manuscript.py
```

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

A stricter coverage gate can be added, for example:

```text
  --min-valid-fraction 0.95
```

Optional arguments support:

- raster layer selection by index or name;
- scale and offset conversion;
- lower and upper no-data masking in raw/source units;
- output rounding;
- fail-closed minimum and maximum output bounds;
- a fail-closed minimum overall valid-data fraction.

The interface transforms extraction geometry to the raster CRS and calculates a finite-cell surface-area-weighted mean. Each cell contribution is weighted by polygon-cell overlap fraction multiplied by cell surface area in square metres. Raw-value no-data masks are applied before scale and offset.

For every polygon it reports:

- `raster_coverage_fraction`;
- `valid_within_raster_fraction`;
- `valid_data_fraction`.

The output is normalized to EPSG:4326 and contains `unit_id`, the requested measurement property, the three coverage properties, `provenance`, and geometry. `--min-valid-fraction` is evaluated against `valid_data_fraction`.

Run the self-contained arbitrary-region contract suite:

```text
Rscript R/test_generic_harmonizer.R
```

See `DATA_DICTIONARY.md` for exact output semantics.

## Direct account-free component commands

```text
Rscript R/demo_value_class.R
Rscript R/test_fixture_pipeline.R
Rscript R/test_portability_fixture.R
Rscript R/test_generic_harmonizer.R
Rscript R/test_zonal_area_summary.R
Rscript R/test_temperature_annual_mean.R
Rscript R/test_ndvi_qa.R
Rscript R/test_hand_summary.R
Rscript R/test_failure_modes.R
python python/validate_release_contract.py
python python/validate_resubmission_metadata.py
python python/audit_manuscript.py
python python/build_checksum_manifest.py --all-tracked --check
```

`python/validate_release_contract.py --skip-failure-tests` validates committed reference layers without injecting corrupted copies.

## Scientific transformation contracts added for v1.4

### Spatial weighting and coverage

`R/zonal_area_summary.R` separates raster-footprint coverage, finite coverage within the raster footprint, overall valid-data coverage, and the finite-cell area-weighted mean. The regression suite includes partial no-data support, partial raster-footprint support, and a latitude-sensitive fixture showing why equal-degree cells cannot be treated as equal-area cells.

### ERA5-Land annual temperature

`R/relief_temp_transform.R` computes the annual statistic as a calendar-day-weighted mean of the 12 monthly means, then converts Kelvin to Celsius. `R/test_temperature_annual_mean.R` verifies non-leap-year and leap-year weights, month count, and conversion behaviour.

### MODIS MOD13A3 v061 NDVI

`R/relief_ndvi_transform.R` applies the documented scale and an explicit pixel-reliability policy. The v1.4 production builder accepts rank `0` by default and requires at least 50% monthly valid support for each annual raster cell. `R/test_ndvi_qa.R` verifies accepted and rejected quality ranks, the explicit unfiltered mode, temporal completeness, and fail-closed QA requirements.

### HAND terrain share

`R/relief_low_lying_transform.R` defines the low-lying share as the percentage of **valid HAND-covered area** at or below the selected threshold. Negative sentinels are no-data. Numerator and denominator use polygon overlap multiplied by cell surface area, and coverage is reported separately. `R/test_hand_summary.R` verifies mixed valid/no-data cases and exact denominator behaviour.

## Rwanda real-data builders

Development outputs default to `generated/` so revised v1.4 scientific results can be checked before any published v1.3 reference file is replaced.

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

Access requirements:

- CHIRPS: public network download, no account;
- HAND: public network download, no account;
- ERA5-Land: Copernicus Climate Data Store account, accepted terms, and local CDS API credentials;
- MODIS: NASA Earthdata account and externally configured `earthaccess` credentials.

No credential is stored in the repository. Provider services and products can change independently of this software.

## Published CHIRPS validation baseline

Run the existing public-data validator with:

```text
Rscript R/validate_chirps_rainfall.R 2023
```

The published v1.3 evidence for the tested 2023 source and Rwanda geometry reported:

- 30 of 30 archived values reproduced exactly after rounding;
- maximum `terra` versus `exactextractr` difference: 0.000136 mm;
- root mean square cross-engine difference: 0.000064 mm;
- maximum cell-area-weighting difference: 0.005127 mm;
- root mean square weighting difference: 0.002385 mm.

This is computational reproduction of the CHIRPS layer, not validation of CHIRPS observational accuracy. It also does not substitute for independent v1.4 numerical checks of the revised ERA5-Land, MODIS, and HAND methods. Those checks remain release gates.

## Published v1.3 reference files versus v1.4 development outputs

Committed source-derived files under `data/` remain published v1.3 artifacts unless a v1.4 remediation step explicitly replaces them after regeneration and review. They must not be described as v1.4 results merely because the transformation code has been revised.

The default v1.4 builder outputs under `generated/` are development artifacts. Before release, approved source-derived outputs must be regenerated, numerically checked, independently reviewed, moved into the exact release scope, and covered by the tracked-file checksum manifest.

## Manuscript figures

Generate the current architecture, map, and profile figures from the committed GeoJSON files with:

```text
Rscript R/make_manuscript_figures.R
```

Outputs are written to `paper/figures/generated/` and are excluded from version control. GitHub Actions can retain the generated evidence bundle. `paper/figures/ALT_TEXT.md` records accessibility text.

A v1.4 manuscript figure should not be treated as final until the architecture, configuration/adapters, workflow management, and independent second-context case are complete and the figure source has been regenerated from the approved release state.

## Integrity during development

`CHECKSUMS.sha256` covers the complete tracked development tree. Human source commits and the checksum refresh are deliberately separate commits on the active remediation branch. The dedicated manifest workflow rebuilds the manifest, verifies the generated file, and commits it when changed.

To verify a current manifest explicitly:

```text
python python/build_checksum_manifest.py --all-tracked --check
```

Or run the complete strict account-free gate on a frozen candidate:

```text
python python/run_all_checks.py --verify-manifest
```

A passing checksum establishes byte-level integrity only. It does not establish scientific validity.

## v1.4 release sequence

After every reviewer concern and release gate has executable or documentary evidence:

1. freeze the approved source, data, documentation, manuscript, and evidence files;
2. reserve a new version-specific Zenodo DOI for v1.4.0 without publishing it;
3. insert the reserved v1.4.0 DOI into release-facing metadata and manuscript files;
4. regenerate the complete tracked-file checksum manifest;
5. run `python python/run_all_checks.py --verify-manifest` on that exact DOI-bearing commit;
6. run and review all required real-data numerical validations and the independent second-context workflow;
7. confirm supported operating-system CI is green and document any unsupported platform blocker;
8. complete independent code and manuscript review;
9. tag the exact approved commit `v1.4.0`;
10. create the matching GitHub release without altering tagged files;
11. archive that exact release content in the reserved Zenodo version and publish it;
12. confirm the DOI resolves to the exact v1.4.0 release;
13. render and inspect the final DOI-bearing journal package;
14. submit only after the response-to-reviewers ledger is complete.

## Reproducibility limits

- The account-free pathway verifies specified transformations, interfaces, failure handling, schemas, and integrity controls. Controlled fixtures are not independent real-data validation.
- The current arbitrary-region generic example is synthetic and does not substitute for the required real second-country portability case.
- ERA5-Land and MODIS rebuilds require provider accounts.
- Independent v1.4 numerical validation is still required for ERA5-Land, MODIS, and HAND.
- Annual administrative summaries suppress seasonality, extremes, and within-unit heterogeneity.
- MODIS QA filtering reduces spatial and temporal support; reported coverage is therefore part of the result, not an optional cosmetic field.
- HAND at or below 5 m is a static terrain descriptor, not observed flooding, flood probability, a validated hazard model, a forecast, or operational advice.
- Current hosted account-free verification is Ubuntu-based. Broader operating-system CI remains a v1.4 release gate.
