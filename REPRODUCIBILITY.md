# Reproducibility

## Development and release boundary

The active Array transfer hardening target is SuRT-GeoHarmonizer version `1.4.0` on branch `review/softwarex-resubmission-v1.4.0`. The branch name is retained for continuity with the externally reviewed SoftwareX remediation history.

The published release `v1.3.0`, DOI `10.5281/zenodo.21840177`, remains immutable. The earlier release `v1.2.0`, DOI `10.5281/zenodo.21744708`, also remains immutable. The concept DOI for the release family is `10.5281/zenodo.21671788`.

No v1.4.0 tag or version DOI is valid until all reviewer-remediation release gates are satisfied on the exact release commit.

## Environment restoration

`renv.lock` records the R dependency graph. Restore it from the repository root:

```text
Rscript -e "renv::restore(prompt = FALSE)"
```

The full hosted account-free workflow uses R 4.6.0 on Ubuntu Linux with GDAL, GEOS, PROJ, UDUNITS, CMake, and related geospatial system dependencies. Python 3.12 runs validation and orchestration. Snakemake executes the declarative workflow evidence DAG. A separate core smoke matrix also passes on Ubuntu 24.04, Windows 2025, and macOS 14; this matrix verifies the core dependency-light contract and does not imply that every credentialed provider acquisition path has been exercised on every operating system.

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
3. projected geometry and CRS portability fixtures;
4. a real Uganda-boundary portability gate using a deterministic synthetic raster;
5. the full generic harmonizer interface contract;
6. the declarative configuration and provider-adapter contract;
7. surface-area-weighted zonal and partial-coverage regressions;
8. ERA5-Land annual-statistic tests, including leap-year handling;
9. MOD13A3 quality-policy and temporal-completeness tests;
10. HAND denominator and valid-area-coverage tests;
11. deliberate transformation failure injection;
12. valid and deliberately corrupted release-contract checks; and
13. Array transfer metadata validation.

The runner writes `generated/verification_summary.json`, the generic example, the Uganda portability output, and controlled fixture outputs. Controlled fixtures require no private repository, provider account, network request, or unpublished data.

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

## Declarative configuration and workflow orchestration

The v1.4 development branch contains a machine-readable harmonization-job contract at `config/harmonization-job.schema.json`. Schema version `1.0` defines provider adapter selection, boundary path and identifier field, variable and layer selection, raw-value transformation controls, the `surface_area_weighted_mean` aggregation method, QA settings, output constraints, and provenance text. Unknown keys fail closed.

Validate the bundled example without running the harmonizer:

```text
python python/run_configured_harmonization.py \
  --config config/demo-harmonization.json \
  --validate-only
```

Run the configured job once its prepared input exists:

```text
python python/run_configured_harmonization.py \
  --config config/demo-harmonization.json
```

`python/provider_adapters.py` defines the provider boundary. The built-in `local_raster` adapter accepts an already prepared local raster and rejects undeclared provider-specific QA. External adapters can be loaded through a `module:factory` plugin interface. This extension boundary does not imply that production acquisition and QA adapters for every external provider are implemented or scientifically validated.

The bundled account-free orchestration demo is:

```text
snakemake --cores 1
```

The `Snakefile` executes a deterministic DAG that:

1. prepares a controlled multilayer raster and polygon fixture;
2. validates the declarative config and adapter contract;
3. transforms the provider-side fixture to a prepared raster;
4. invokes the configured generic harmonizer;
5. validates the resulting GeoJSON; and
6. records machine-readable workflow evidence under `generated/workflow_demo/`.

This DAG verifies orchestration and interfaces. Its controlled raster is synthetic and is not independent real-data validation.

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

## Real second-country boundary portability gate

Run:

```text
Rscript R/test_second_country_portability.R
```

The test reads `fixtures/uganda_natural_earth_110m.geojson`, a source-derived Uganda national polygon from Natural Earth 1:110m Admin 0 Countries, and combines it with a deterministic synthetic raster created at runtime. It runs that pair through `harmonize_admin_raster()` and checks identifier preservation, valid WGS84 geometry, complete synthetic-raster support, bounded output, source-geometry preservation, and provenance wording.

This is stronger than a purely synthetic arbitrary-polygon fixture because the administrative geometry is a real non-Rwanda country boundary. It remains a software portability test, not scientific validation of an environmental product for Uganda.

Natural Earth attribution and interpretation limits are documented in `NOTICE.md`.

## Source-derived Uganda CHIRPS portability case

Run:

```text
python python/run_configured_harmonization.py --config config/uganda-chirps-2023.json
Rscript R/validate_uganda_chirps_case.R 2023
```

The configured job uses the public CHIRPS v2.0 annual 2023 raster, the Natural Earth Uganda boundary, the same `local_raster` adapter, and the generic administrative harmonizer. The validator independently recomputes the national surface-area-weighted mean with `terra` exact polygon-cell fractions and cell areas. Clean Ubuntu CI produced 1,238.073160 mm from the configured workflow and 1,238.073144 mm independently, an absolute difference of 0.000016 mm; all three reported coverage fractions were 1.0.

This closes the source-derived second-country environmental-case gap for one account-free product and national geometry. It establishes reproducible use of the same generic configured workflow outside Rwanda; it does not validate CHIRPS observational accuracy or establish scientific validity for every provider, geography, or downstream interpretation.

## Direct account-free component commands

```text
Rscript R/demo_value_class.R
Rscript R/test_fixture_pipeline.R
Rscript R/test_portability_fixture.R
Rscript R/test_second_country_portability.R
Rscript R/test_generic_harmonizer.R
Rscript R/test_zonal_area_summary.R
Rscript R/test_temperature_annual_mean.R
Rscript R/test_ndvi_qa.R
Rscript R/test_hand_summary.R
Rscript R/test_failure_modes.R
python python/test_config_contract.py
python python/validate_release_contract.py
python python/validate_resubmission_metadata.py
python python/audit_manuscript.py
python python/build_checksum_manifest.py --all-tracked --check
snakemake --cores 1
```

`python/validate_release_contract.py --skip-failure-tests` validates committed reference layers without injecting corrupted copies.

## Scientific transformation contracts added for v1.4

### Spatial weighting and coverage

`R/zonal_area_summary.R` separates raster-footprint coverage, finite coverage within the raster footprint, overall valid-data coverage, and the finite-cell area-weighted mean. The regression suite includes partial no-data support, partial raster-footprint support, and a latitude-sensitive fixture showing why equal-degree cells cannot be treated as equal-area cells.

### ERA5-Land annual temperature

`R/relief_temp_transform.R` computes the annual statistic as a calendar-day-weighted mean of the 12 monthly means, then converts kelvin to degrees Celsius. `R/test_temperature_annual_mean.R` verifies non-leap-year and leap-year weights, month count, and conversion behaviour.

### MODIS MOD13A3 v061 NDVI

`R/relief_ndvi_transform.R` applies the documented scale and an explicit pixel-reliability policy. The v1.4 production builder accepts rank `0` by default and requires at least 50% monthly valid support for each annual raster cell. `R/test_ndvi_qa.R` verifies accepted and rejected quality ranks, the explicit unfiltered mode, temporal completeness, and fail-closed QA requirements.

### HAND terrain share

`R/relief_low_lying_transform.R` defines the low-lying share as the percentage of **valid HAND-covered area** at or below the selected threshold. Negative sentinels are no-data. Numerator and denominator use polygon overlap multiplied by cell surface area, and coverage is reported separately. `R/test_hand_summary.R` verifies mixed valid and no-data cases and exact denominator behaviour.

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

## Scoped v1.4 real-data numerical cross-checks

The reviewer-remediation branch retains case-specific real-data validation summaries under `evidence/`. These checks compare the production transformation and zonal path with an independently implemented calculation for the same source bytes and case. They establish computational agreement for the stated case only; they do not validate observational accuracy or universal provider behaviour.

Run the validators after the required source caches are present:

```text
Rscript R/validate_era5land_nyarugenge_real.R
Rscript R/validate_modis_ndvi_nyarugenge_real.R
Rscript R/validate_hand_rubavu_real.R
```

Current scoped evidence:

- **ERA5-Land, Nyarugenge, 2023:** production 20.597411 ?C versus independent `terra` 20.597414 ?C; absolute difference approximately 0.000003 ?C; complete reported coverage. The tracked evidence records the source SHA-256 and CDS request identity.
- **MOD13A3 v061, Nyarugenge, 2023:** production output 0.56 NDVI versus independent pre-rounding estimate 0.55775352, agreeing under the declared two-decimal output contract. Valid-area and mean-valid-month fractions differ by less than 0.000051. The tracked evidence records all 24 source granule names, byte sizes, SHA-256 digests, and a source-set fingerprint.
- **HAND 30 m, Rubavu, threshold <= 5 m:** production 26.133870170321% versus independent `terra` 26.133870170236%; effectively zero percentage-point difference, with complete reported coverage in the CI case. The tracked evidence records the exact source-tile SHA-256 and CI run/artifact identity.

ERA5-Land and MODIS source acquisition requires provider credentials configured outside the repository. HAND is public and account-free. No credential material is retained in `evidence/`.

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

The Rwanda check is computational reproduction of the archived CHIRPS layer, not validation of CHIRPS observational accuracy. The source-derived Uganda case adds an independent configured-workflow check for the same public product outside Rwanda: 1,238.073160 mm configured versus 1,238.073144 mm from an independent `terra` area-weighted calculation, with an absolute difference of 0.000016 mm and complete reported coverage. Scoped independent v1.4 checks now also pass for Nyarugenge ERA5-Land, Nyarugenge MOD13A3, and Rubavu HAND. Their source-pinned summaries are retained under `evidence/`; they establish computational cross-validation only for the stated product, source, place, year or threshold, and acceptance gates.

## Published v1.3 reference files versus v1.4 development outputs

Committed source-derived files under `data/` remain published v1.3 artifacts unless a v1.4 remediation step explicitly replaces them after regeneration and review. They must not be described as v1.4 results merely because the transformation code has been revised.

The default v1.4 builder outputs under `generated/` are development artifacts. Before release, approved source-derived outputs must be regenerated, numerically checked, independently reviewed, moved into the exact release scope, and covered by the tracked-file checksum manifest.

## Manuscript figures

Generate the current architecture, map, and profile figures from the committed GeoJSON files with:

```text
Rscript R/make_manuscript_figures.R
```

Outputs are written to `paper/figures/generated/` and are excluded from version control. GitHub Actions can retain the generated evidence bundle. `paper/figures/ALT_TEXT.md` records accessibility text.

The architecture figure source must remain synchronized with the configuration, adapter, aggregation, portability, and release contracts. The Rwanda map panels remain based on published v1.3 reference files until revised v1.4 source-derived layers are independently validated and approved.

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
6. review the tracked CHIRPS, ERA5-Land, MODIS, and HAND real-data validation evidence against the exact release commit;
7. confirm the three-platform core smoke matrix and full Ubuntu reproducibility CI remain green, and retain the explicit boundary that credentialed provider acquisition was not exercised on every platform;
8. complete independent code and manuscript review;
9. tag the exact approved commit `v1.4.0`;
10. create the matching GitHub release without altering tagged files;
11. archive that exact release content in the reserved Zenodo version and publish it;
12. confirm the DOI resolves to the exact v1.4.0 release;
13. render and inspect the final DOI-bearing journal package;
14. submit only after the response-to-reviewers ledger is complete.

## Reproducibility limits

- The account-free pathway verifies specified transformations, interfaces, configuration, orchestration, failure handling, schemas, and integrity controls. Controlled fixtures are not independent real-data validation.
- The Uganda synthetic-signal gate isolates geometry and identifier portability. A separate source-derived CHIRPS case demonstrates the configured workflow on a real second-country environmental raster and boundary, but does not validate CHIRPS observational accuracy or universal provider portability.
- The built-in adapter currently covers an already prepared local raster. The plugin boundary is stable, but source-specific production acquisition and QA adapters are not implied by that interface.
- ERA5-Land and MODIS rebuilds require provider accounts.
- Scoped independent v1.4 numerical checks now exist for ERA5-Land, MODIS, and HAND. Each is a computational cross-check of one stated case and does not establish observational accuracy, universal geographic validity, or provider-wide correctness.
- Annual administrative summaries suppress seasonality, extremes, and within-unit heterogeneity.
- MODIS QA filtering reduces spatial and temporal support; reported coverage is therefore part of the result, not an optional cosmetic field.
- HAND at or below 5 m is a static terrain descriptor, not observed flooding, flood probability, a validated hazard model, a forecast, or operational advice.
- Full hosted account-free reproducibility verification remains Ubuntu-based. The core smoke contract passes on Ubuntu 24.04, Windows 2025, and macOS 14; credentialed provider acquisition and the complete geospatial stack are not claimed to have been exercised on every platform.
