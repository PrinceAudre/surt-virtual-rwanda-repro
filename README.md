# SuRT-GeoHarmonizer

**Auditable administrative-scale Earth-data harmonization and provenance labelling in R and Python**

SuRT-GeoHarmonizer is an open command-line workflow for converting heterogeneous raster products into consistent, provenance-labelled administrative-unit GeoJSON layers. The public harmonizer separates raster-footprint coverage, finite-data coverage, and value aggregation; weights finite raster contributions by polygon-cell overlap multiplied by cell surface area; and retains fail-closed tests and release-integrity controls.

Rwanda is the reference implementation, not a hard-coded product boundary. The generic interface accepts an arbitrary raster, polygon boundary file, unique identifier field, output measurement name, transformation controls, coverage threshold, and provenance statement.

The software is descriptive and research-oriented. It does not generate validated hazards, forecasts, epidemiological effects, exposure estimates, or operational recommendations.

## Software status

- **Active peer-review remediation target:** `1.4.0` development
- **Development branch:** `review/softwarex-resubmission-v1.4.0`
- **Published immutable baseline:** `v1.3.0`, DOI `10.5281/zenodo.21840177`
- **Zenodo concept DOI:** `10.5281/zenodo.21671788`
- **Earlier immutable release:** `v1.2.0`, DOI `10.5281/zenodo.21744708`
- **Code licence:** MIT
- **Current clean-run CI environment:** Ubuntu Linux

Version `1.4.0` is not yet a release. No v1.4.0 tag or version DOI should be created until the reviewer-remediation ledger and release gates are complete. The published v1.3.0 release remains immutable.

## What the software does

SuRT-GeoHarmonizer currently provides four connected layers:

1. **Generic administrative harmonization.** `R/harmonize_admin_raster.R` accepts a raster and polygon boundary file and writes WGS84 GeoJSON containing `unit_id`, a user-defined measurement field, three explicit coverage fields, provenance, and geometry.
2. **Provider-specific reference builders.** The Rwanda implementation prepares CHIRPS rainfall, ERA5-Land temperature, MODIS NDVI, and HAND terrain descriptors using explicit transformation rules.
3. **Fail-closed evidence and release controls.** The provenance module defaults unknown, incomplete, synthetic, or placeholder outputs to illustrative status. Independent validators reject malformed transformations and corrupted release files.
4. **Executable evidence.** A one-command account-free development suite exercises controlled transformations, spatial weighting, partial coverage, arbitrary projected geometry, the generic input contract, deliberate failure modes, GeoJSON contracts, and metadata consistency. Manifest integrity can be added explicitly for a frozen release candidate.

The v1.4 remediation roadmap additionally requires a stable provider-adapter/configuration contract, workflow orchestration, a real second-country portability case, additional real-data numerical cross-checks, and broader operating-system CI. Those items remain development work until the tracked remediation ledger records executable evidence for them.

## Five-minute quick start

### 1. Requirements

The verified workflow uses:

- R 4.6.0;
- `terra`, `sf`, `exactextractr`, and `jsonlite` from `renv.lock`;
- Python 3 for standard-library validation and orchestration;
- GDAL, GEOS, PROJ, UDUNITS, and CMake-related system support on Linux for the locked geospatial stack.

Restore the locked R environment from the repository root:

```text
Rscript -e "renv::restore(prompt = FALSE)"
```

The account-free test pathway uses only bundled data and generated fixtures. Provider downloads are optional and have separate access requirements.

### 2. Run the account-free development checks

```text
python python/run_all_checks.py
```

The suite reports test outcomes dynamically rather than relying on a manually maintained total. It runs the provenance checks, hermetic environmental fixture pipeline, geometry-portability fixture, generic harmonizer contract suite, zonal area/coverage regressions, ERA5 annual-statistic tests, MODIS quality-policy tests, HAND denominator/coverage tests, deliberate transformation failures, release-contract checks, and remediation metadata checks.

During active development, `CHECKSUMS.sha256` is rebuilt and validated by the dedicated manifest-refresh workflow after each human source commit. This separation prevents the scientific CI job from failing merely because it started before the automated manifest-refresh commit landed.

For a frozen release candidate, or after the manifest-refresh workflow has made the manifest current, require the exact tracked-file manifest as part of the same run:

```text
python python/run_all_checks.py --verify-manifest
```

The GitHub Actions reproducibility workflow also exposes this strict mode through its manual `verify_manifest` input.

### 3. Run the generic example directly

```text
Rscript R/test_generic_harmonizer.R
```

This test creates a projected synthetic raster and arbitrary polygon units, invokes the public generic interface, and writes `generated/generic_admin_example.geojson`.

## Generic command-line interface

```text
Rscript R/harmonize_admin_raster.R \
  --raster input.tif \
  --boundaries administrative_units.geojson \
  --id-field admin_code \
  --value-name environmental_mean \
  --output generated/environmental_mean.geojson \
  --provenance "Source, product, period, method and applicable terms" \
  --min-valid-fraction 0.95
```

Optional controls support:

- raster layer selection by index or name;
- scale and offset conversion;
- lower and upper no-data masking in raw/source units before scale and offset;
- output rounding;
- minimum and maximum fail-closed value bounds;
- a fail-closed minimum overall valid-data fraction.

Display the full interface:

```text
Rscript R/harmonize_admin_raster.R --help
```

### Generic aggregation and coverage contract

The raster must be readable by `terra`, have a declared coordinate reference system, contain the selected layer, and provide finite values for every polygon after optional raw-value masking and conversion.

The boundary file must be readable by `sf`, have a declared coordinate reference system, contain valid polygon or multipolygon geometry, contain the requested identifier field, and provide unique non-empty identifiers.

For each polygon, finite raster contributions are weighted by:

```text
polygon-cell overlap fraction x raster-cell surface area in square metres
```

The denominator of the measurement mean is the summed weight of finite cells only. Equal angular cells are therefore not treated as equal-area observations.

The output is normalized to EPSG:4326 and contains:

- `unit_id`;
- the requested measurement property;
- `raster_coverage_fraction`;
- `valid_within_raster_fraction`;
- `valid_data_fraction`;
- `provenance`;
- polygon or multipolygon geometry.

Coverage fields mean:

- `raster_coverage_fraction`: polygon surface-area fraction intersecting the raster footprint;
- `valid_within_raster_fraction`: finite-data fraction within the raster-covered part of the polygon;
- `valid_data_fraction`: overall polygon valid-data fraction, equal to the product of the two fractions above.

`--min-valid-fraction` is tested against `valid_data_fraction`. Its default is `0`, which reports partial support without rejecting it. A stricter scientific workflow should select an explicit threshold appropriate to the source and use case.

The generic interface validates processing behaviour. It does not decide whether a selected source, period, threshold, scale, unit conversion, coverage threshold, or interpretation is scientifically appropriate.

See `DATA_DICTIONARY.md` for exact field definitions.

## Rwanda reference implementation

The v1.4 builders operate on the common Rwanda district geometry and default to outputs under `generated/` so revised results can be independently checked before any published reference artifact is replaced.

### CHIRPS rainfall

`R/build_relief_climate_rainfall.R` masks negative fill/no-data values and computes surface-area-weighted district means. The output reports raster-footprint, within-raster finite-data, and overall valid-data fractions.

### ERA5-Land temperature

`R/build_relief_climate_temperature.R` calculates an annual raster as the calendar-day-weighted mean of the 12 monthly means, using the correct February length for leap years, converts Kelvin to Celsius, and then computes surface-area-weighted district means with explicit coverage fields.

### MODIS MOD13A3 v061 NDVI

`R/build_relief_climate_ndvi_real.R` uses the MOD13A3 `1 km monthly NDVI` and `1 km monthly pixel reliability` subdatasets. The v1.4 production default accepts pixel reliability rank `0` only, requires at least 50% monthly valid support for an annual raster cell, and reports district annual-NDVI area coverage plus mean valid-month completeness. An explicit unfiltered transform mode exists for controlled use but is not the production default.

### HAND low-lying terrain share

`R/build_relief_low_lying_hand.R` reports the percentage of **valid HAND-covered district area** at or below the selected HAND threshold. Negative HAND sentinels are treated as no-data. Numerator and denominator are both weighted by polygon-cell overlap and cell surface area. The metric is a terrain descriptor, not observed flooding, flood probability, or a validated hazard model.

Run the development builders from any working directory:

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

Access requirements:

- CHIRPS and HAND require network access but no account.
- ERA5-Land requires a Copernicus Climate Data Store account and accepted product terms.
- MODIS requires a NASA Earthdata account.
- Credentials are read from provider-standard local configuration and are never committed.

Provider client versions are recorded in `requirements-providers.txt`.

## Published v1.3 data versus v1.4 development outputs

The committed files under `data/` are the published v1.3 reference artifacts unless a v1.4 remediation step explicitly replaces them after regeneration and review. They must not be interpreted as automatically upgraded scientific results merely because the v1.4 transformation code exists on this branch.

The revised builders write to `generated/` by default. Before a v1.4 release, revised source-derived files must be regenerated, numerically checked, reviewed, moved into the approved release scope, and covered by the exact tracked-file checksum manifest.

## Public CHIRPS numerical validation

```text
Rscript R/validate_chirps_rainfall.R 2023
```

The existing validation independently reacquires the public annual CHIRPS raster, reproduces the archived district values, compares `exactextractr` with `terra::extract`, and evaluates cell-area weighting sensitivity.

The published v1.3 validation evidence for the tested source, year, and Rwanda geometry reports:

- 30 of 30 archived values reproduce exactly after rounding;
- maximum cross-engine difference: 0.000136 mm;
- maximum cell-area-weighting difference: 0.005127 mm.

This is computational reproduction of the CHIRPS layer only. Equivalent independent numerical validation for the revised ERA5-Land, MODIS, and HAND v1.4 methods remains a release gate and should not be inferred from the controlled fixtures.

## Repository map

- `R/harmonize_admin_raster.R`: generic public command-line interface.
- `R/zonal_area_summary.R`: shared surface-area-weighted zonal and coverage contract.
- `R/test_generic_harmonizer.R`: direct generic-interface contract tests.
- `R/test_zonal_area_summary.R`: partial-coverage and latitude-sensitive spatial regressions.
- `R/test_temperature_annual_mean.R`: ERA5 annual-statistic tests.
- `R/test_ndvi_qa.R`: MOD13A3 quality and temporal-completeness tests.
- `R/test_hand_summary.R`: HAND denominator and coverage tests.
- `R/`: provider transformations, builders, fixtures, failure tests, and figure generation.
- `python/`: provider clients, orchestration, release validation, checksum generation, and metadata checks.
- `data/`: published Rwanda reference geometry and environmental GeoJSON layers.
- `generated/`: development outputs and account-free evidence generated by tests.
- `paper/`: SoftwareX manuscript source, submission records, figures, and review material.
- `.github/workflows/`: reproducibility, metadata, manifest, and public-data validation.
- `DATA_DICTIONARY.md`: output-field definitions.
- `NOTICE.md`: source attribution, data terms, and scope boundaries.
- `REPRODUCIBILITY.md`: execution and evidence instructions.
- `CONTRIBUTING.md`: contribution and review rules.
- `codemeta.json` and `CITATION.cff`: machine-readable metadata, retained at the published baseline until v1.4 release freeze where appropriate.

## Provenance contract

`R/provenance_value_class.R` accepts `source-derived` status only when a register row declares a documented method applied to real or public data. Unknown, incomplete, synthetic, and placeholder entries default to `illustrative` and receive an explanatory note.

The current release records lightweight human-readable provenance. It does not claim PROV-O, RO-Crate, Common Workflow Language, or workflow-engine conformance.

## Reproducibility and integrity

- `renv.lock` records the R dependency graph.
- `python/run_all_checks.py` runs the account-free scientific, interface, failure-mode, release-contract, and metadata suite and reports outcome counts dynamically.
- `python/run_all_checks.py --verify-manifest` additionally requires the exact tracked-file manifest and verifies every listed digest.
- `python/validate_release_contract.py` independently checks committed GeoJSON files and rejects controlled corruptions.
- `CHECKSUMS.sha256` covers the complete tracked development scope and is rebuilt and checked by the dedicated v1.4 manifest workflow after human source commits.
- GitHub Actions reruns the account-free evidence suite on a clean hosted runner; manual dispatch can enable strict manifest verification.
- The eventual v1.4 tag and Zenodo version DOI must identify the exact same approved release content.

Checksums establish byte integrity, not scientific validity.

## Licences and attribution

- **Code:** MIT, see `LICENSE`.
- **District geometry:** World Bank CC BY 4.0.
- **CHIRPS:** public domain or CC0 as documented in the repository attribution records.
- **ERA5-Land:** Copernicus Products licence.
- **MODIS and HAND outputs:** source/product terms are documented in `NOTICE.md`; do not infer a broader licence than the source permits.

See `NOTICE.md` for complete attribution and interpretation boundaries.

## Contributing and support

Use GitHub Issues for reproducible bug reports, documentation defects, provider changes, and feature proposals. Include the command, operating system, R and Python versions, input schema, and the smallest non-sensitive example that reproduces the problem.

Security-sensitive reports should follow `SECURITY_REVIEW.md` rather than being posted with credentials or private data.

Support contact: `priplee@gmail.com`.

## Citation

Until v1.4.0 is frozen, tagged, and archived, cite the published v1.3.0 release:

> Tuyishime AP (2026). SuRT-GeoHarmonizer: auditable administrative-scale Earth-data harmonization and provenance labelling. Version 1.3.0. Zenodo. https://doi.org/10.5281/zenodo.21840177

The release-family concept DOI is `10.5281/zenodo.21671788`. A new v1.4.0 version DOI will be inserted only after the exact reviewer-remediated release commit is approved and frozen.
