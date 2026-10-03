# SuRT-GeoHarmonizer

**Auditable administrative-scale Earth-data harmonization and provenance labelling in R and Python**

SuRT-GeoHarmonizer is an open command-line workflow for converting heterogeneous raster products into consistent, provenance-labelled administrative-unit GeoJSON layers. The public harmonizer separates raster-footprint coverage, finite-data coverage, and value aggregation; weights finite raster contributions by polygon-cell overlap multiplied by cell surface area; and retains fail-closed tests and release-integrity controls.

Rwanda is the reference implementation, not a hard-coded product boundary. The generic interface accepts an arbitrary raster, polygon boundary file, unique identifier field, output measurement name, transformation controls, coverage threshold, and provenance statement. A declarative JSON contract and Snakemake evidence workflow now exercise the same generic harmonization boundary without embedding Rwanda-specific identifiers in the core interface.

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

SuRT-GeoHarmonizer currently provides five connected layers:

1. **Generic administrative harmonization.** `R/harmonize_admin_raster.R` accepts a raster and polygon boundary file and writes WGS84 GeoJSON containing `unit_id`, a user-defined measurement field, three explicit coverage fields, provenance, and geometry.
2. **Declarative job configuration.** `config/harmonization-job.schema.json` defines a fail-closed JSON contract for provider preparation, boundaries, variables, transformations, aggregation, QA, output, and provenance. `python/run_configured_harmonization.py` validates that contract before invoking the generic R engine.
3. **Provider-adapter boundary.** `python/provider_adapters.py` defines a stable adapter protocol, a built-in `local_raster` adapter for already prepared inputs, and an external `module:factory` plugin mechanism. This is an extension contract, not a claim that production adapters for every provider are already implemented.
4. **Provider-specific Rwanda reference builders.** The reference implementation prepares CHIRPS rainfall, ERA5-Land temperature, MODIS NDVI, and HAND terrain descriptors using explicit transformation rules.
5. **Executable evidence and release controls.** Account-free checks exercise controlled transformations, spatial weighting, partial coverage, arbitrary projected geometry, a real second-country boundary, declarative configuration, deliberate failure modes, GeoJSON contracts, metadata consistency, and a Snakemake evidence DAG. Manifest integrity can be added explicitly for a frozen release candidate.

Uganda now provides two complementary portability cases. `R/test_second_country_portability.R` uses a source-derived Uganda national boundary with a deterministic synthetic raster to isolate geometry and identifier portability. Separately, `config/uganda-chirps-2023.json` runs the public CHIRPS v2.0 annual 2023 raster and the same Uganda boundary through the generic configured workflow; `R/validate_uganda_chirps_case.R` independently cross-checks the result with `terra` exact fractions and cell-area weights.

Remaining release work includes independent v1.4 numerical validation for ERA5-Land, MODIS, and HAND, broader operating-system evidence or an explicit supported-platform boundary, and the final reviewer-response and release-freeze sequence.

## Five-minute quick start

### 1. Requirements

The verified workflow uses:

- R 4.6.0;
- `terra`, `sf`, `exactextractr`, and `jsonlite` from `renv.lock`;
- Python 3 for validation and orchestration;
- Snakemake for the declarative workflow evidence DAG;
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

The suite reports test outcomes dynamically rather than relying on a manually maintained total. It runs provenance checks, the hermetic environmental fixture pipeline, the projected geometry-portability fixture, the real Uganda-boundary portability gate, the generic harmonizer contract suite, the declarative configuration and adapter contract tests, zonal area and coverage regressions, ERA5 annual-statistic tests, MODIS quality-policy tests, HAND denominator and coverage tests, deliberate transformation failures, release-contract checks, and remediation metadata checks.

During active development, `CHECKSUMS.sha256` is rebuilt and validated by the dedicated manifest-refresh workflow after each human source commit. This separation prevents the scientific CI job from failing merely because it started before the automated manifest-refresh commit landed.

For a frozen release candidate, or after the manifest-refresh workflow has made the manifest current, require the exact tracked-file manifest as part of the same run:

```text
python python/run_all_checks.py --verify-manifest
```

The GitHub Actions reproducibility workflow also exposes this strict mode through its manual `verify_manifest` input.

### 3. Run the declarative workflow evidence DAG

```text
snakemake --cores 1
```

The bundled `Snakefile` validates `config/demo-harmonization.json`, prepares a controlled multilayer raster and boundary fixture, transforms the configured raster, invokes the generic harmonizer, validates the GeoJSON result, and writes machine-readable workflow evidence under `generated/workflow_demo/`.

The demo is deliberately hermetic. It proves the orchestration and configuration contract, not real-provider scientific validity.

### 4. Run the generic example directly

```text
Rscript R/test_generic_harmonizer.R
```

This test creates a projected synthetic raster and arbitrary polygon units, invokes the public generic interface, and writes `generated/generic_admin_example.geojson`.

### 5. Run the real second-country boundary portability gate

```text
Rscript R/test_second_country_portability.R
```

This gate uses the source-derived Uganda polygon in `fixtures/uganda_natural_earth_110m.geojson` and a deterministic synthetic raster. The output is therefore evidence of geometry and identifier portability only. Source and interpretation terms are recorded in `NOTICE.md`.

### 6. Run the source-derived Uganda CHIRPS case

```text
python python/run_configured_harmonization.py --config config/uganda-chirps-2023.json
Rscript R/validate_uganda_chirps_case.R 2023
```

The configured case uses the public CHIRPS v2.0 annual 2023 raster and the source-derived Uganda boundary. In clean Ubuntu CI it produced 1,211.186986 mm with all three coverage fractions equal to 1.0; an independent `terra` area-weighted calculation produced 1,211.186812 mm, an absolute difference of 0.000174 mm. This is computational cross-validation of the specified workflow, not validation of CHIRPS observational accuracy.

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

## Declarative configuration and provider adapters

`config/harmonization-job.schema.json` fixes the machine-readable job shape at schema version `1.0`. Unknown top-level and nested keys fail closed. The schema covers provider adapter selection, boundary path and identifier field, variable and layer selection, raw-value transformation controls, the `surface_area_weighted_mean` aggregation method, QA settings, output constraints, and provenance text.

Validate a job without producing output:

```text
python python/run_configured_harmonization.py \
  --config config/demo-harmonization.json \
  --validate-only
```

Run the configured job after its prepared raster exists:

```text
python python/run_configured_harmonization.py \
  --config config/demo-harmonization.json
```

The built-in `local_raster` adapter accepts an already prepared raster and rejects undeclared provider-specific QA options. New providers can implement the documented adapter protocol through an external `module:factory` plugin without changing the generic R harmonizer. Provider-specific scientific QA and acquisition remain the adapter author's responsibility.

## Rwanda reference implementation

The v1.4 builders operate on the common Rwanda district geometry and default to outputs under `generated/` so revised results can be independently checked before any published reference artifact is replaced.

### CHIRPS rainfall

`R/build_relief_climate_rainfall.R` masks negative fill or no-data values and computes surface-area-weighted district means. The output reports raster-footprint, within-raster finite-data, and overall valid-data fractions.

### ERA5-Land temperature

`R/build_relief_climate_temperature.R` calculates an annual raster as the calendar-day-weighted mean of the 12 monthly means, using the correct February length for leap years, converts kelvin to degrees Celsius, and then computes surface-area-weighted district means with explicit coverage fields.

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

The public-data validation evidence now reports:

- Rwanda: 30 of 30 archived values reproduce exactly after rounding;
- Rwanda maximum cross-engine difference: 0.000136 mm;
- Rwanda maximum cell-area-weighting difference: 0.005127 mm;
- Uganda configured national mean: 1,211.186986 mm;
- Uganda independent `terra` area-weighted mean: 1,211.186812 mm;
- Uganda absolute cross-engine difference: 0.000174 mm;
- Uganda raster-footprint, within-raster finite-data, and overall valid-data fractions: 1.0.

These are computational reproduction and cross-validation results for the specified CHIRPS source, year, geometries, and aggregation contracts. They do not validate CHIRPS observational accuracy. Equivalent independent numerical validation for the revised ERA5-Land, MODIS, and HAND v1.4 methods remains a release gate.

## Repository map

- `R/harmonize_admin_raster.R`: generic public command-line interface.
- `R/zonal_area_summary.R`: shared surface-area-weighted zonal and coverage contract.
- `R/test_generic_harmonizer.R`: direct generic-interface contract tests.
- `R/test_second_country_portability.R`: real Uganda-boundary portability gate using a synthetic signal.
- `config/uganda-chirps-2023.json`: source-derived Uganda CHIRPS configured job.
- `R/validate_uganda_chirps_case.R`: independent Uganda CHIRPS numerical cross-check.
- `R/test_zonal_area_summary.R`: partial-coverage, latitude-sensitive, and near-global footprint regressions.
- `R/test_temperature_annual_mean.R`: ERA5 annual-statistic tests.
- `R/test_ndvi_qa.R`: MOD13A3 quality and temporal-completeness tests.
- `R/test_hand_summary.R`: HAND denominator and coverage tests.
- `config/harmonization-job.schema.json`: declarative job schema.
- `config/demo-harmonization.json`: account-free workflow demo configuration.
- `python/config_contract.py`: fail-closed config validation and command mapping.
- `python/provider_adapters.py`: built-in and external provider-adapter protocol.
- `python/run_configured_harmonization.py`: configured generic-harmonization runner.
- `Snakefile`: account-free orchestration and workflow-evidence DAG.
- `R/`: provider transformations, builders, fixtures, failure tests, and figure generation.
- `python/`: provider clients, orchestration, release validation, checksum generation, and metadata checks.
- `data/`: published Rwanda reference geometry and environmental GeoJSON layers.
- `fixtures/`: controlled and source-attributed portability fixtures.
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

The current release records lightweight human-readable provenance. It does not claim PROV-O, RO-Crate, Common Workflow Language, or workflow-engine standards conformance.

## Reproducibility and integrity

- `renv.lock` records the R dependency graph.
- `python/run_all_checks.py` runs the account-free scientific, interface, configuration, portability, failure-mode, release-contract, and metadata suite and reports outcome counts dynamically.
- `snakemake --cores 1` executes the bundled declarative workflow evidence DAG.
- `python/run_all_checks.py --verify-manifest` additionally requires the exact tracked-file manifest and verifies every listed digest.
- `python/validate_release_contract.py` independently checks committed GeoJSON files and rejects controlled corruptions.
- `CHECKSUMS.sha256` covers the complete tracked development scope and is rebuilt and checked by the dedicated v1.4 manifest workflow after human source commits.
- GitHub Actions reruns the account-free evidence suite and Snakemake workflow on a clean Ubuntu runner; manual dispatch can enable strict manifest verification.
- The eventual v1.4 tag and Zenodo version DOI must identify the exact same approved release content.

Checksums establish byte integrity, not scientific validity.

## Licences and attribution

- **Code:** MIT, see `LICENSE`.
- **District geometry:** World Bank CC BY 4.0.
- **CHIRPS:** public domain or CC0 as documented in the repository attribution records.
- **ERA5-Land:** Copernicus Products licence.
- **MODIS and HAND outputs:** source and product terms are documented in `NOTICE.md`; do not infer a broader licence than the source permits.
- **Uganda portability boundary:** Natural Earth 1:110m Admin 0 Countries, public domain, as documented in `NOTICE.md`.

See `NOTICE.md` for complete attribution and interpretation boundaries.

## Contributing and support

Use GitHub Issues for reproducible bug reports, documentation defects, provider changes, and feature proposals. Include the command, operating system, R and Python versions, input schema, and the smallest non-sensitive example that reproduces the problem.

Security-sensitive reports should follow `SECURITY_REVIEW.md` rather than being posted with credentials or private data.

Support contact: `priplee@gmail.com`.

## Citation

Until v1.4.0 is frozen, tagged, and archived, cite the published v1.3.0 release:

> Tuyishime AP (2026). SuRT-GeoHarmonizer: auditable administrative-scale Earth-data harmonization and provenance labelling. Version 1.3.0. Zenodo. https://doi.org/10.5281/zenodo.21840177

The release-family concept DOI is `10.5281/zenodo.21671788`. A new v1.4.0 version DOI will be inserted only after the exact reviewer-remediated release commit is approved and frozen.
