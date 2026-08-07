# SuRT-GeoHarmonizer

**Auditable administrative-scale Earth-data harmonization and provenance labelling in R and Python**

SuRT-GeoHarmonizer is an open command-line workflow for converting heterogeneous raster products into consistent, provenance-labelled administrative-unit GeoJSON layers. It combines provider-specific preparation, coverage-fraction-weighted polygon aggregation, fail-closed evidence classification, executable positive and negative tests, release-contract validation, and versioned archival practice.

Rwanda is the reference implementation, not a hard-coded product boundary. The generic interface accepts an arbitrary raster, polygon boundary file, unique identifier field, output measurement name, transformation controls, and provenance statement.

The software is descriptive and research-oriented. It does not generate validated hazards, forecasts, epidemiological effects, exposure estimates, or operational recommendations.

## Software status

- **SoftwareX candidate version:** `1.3.0`
- **Candidate branch:** `codex/softwarex-submission-v1.3.0`
- **Reserved v1.3.0 Zenodo DOI:** `10.5281/zenodo.21840177`
- **Zenodo concept DOI:** `10.5281/zenodo.21671788`
- **Historical immutable release:** `v1.2.0`, DOI `10.5281/zenodo.21744708`
- **Code licence:** MIT
- **Validated continuous-integration environment:** Ubuntu Linux

Version `1.2.0` remains immutable. The version-specific DOI `10.5281/zenodo.21840177` is reserved for the SoftwareX-facing `v1.3.0` release and will be registered when the exact validated `v1.3.0` archive is published on Zenodo.

## What the software does

SuRT-GeoHarmonizer provides four connected layers:

1. **Generic administrative harmonization.** `R/harmonize_admin_raster.R` accepts a raster and polygon boundary file and writes a WGS84 GeoJSON containing `unit_id`, a user-defined measurement field, provenance, and geometry.
2. **Provider-specific reference builders.** The Rwanda implementation prepares CHIRPS rainfall, ERA5-Land temperature, MODIS NDVI, and HAND terrain descriptors.
3. **Fail-closed evidence and release controls.** The provenance module defaults unknown, incomplete, synthetic, or placeholder outputs to illustrative status. Independent validators reject malformed transformations and corrupted release files.
4. **Executable evidence.** A one-command account-free suite exercises controlled transformations, arbitrary projected geometry, the generic input contract, deliberate failure modes, GeoJSON contracts, and checksum integrity.

## Five-minute quick start

### 1. Requirements

The verified workflow uses:

- R 4.6.0;
- `terra`, `sf`, `exactextractr`, and `jsonlite` from `renv.lock`;
- Python 3 for standard-library validation and orchestration;
- GDAL, GEOS, PROJ, and UDUNITS system libraries on Linux.

Restore the locked R environment from the repository root:

```text
Rscript -e "renv::restore(prompt = FALSE)"
```

The account-free test pathway uses only bundled data and generated fixtures. Provider downloads are optional and have separate credential requirements.

### 2. Run all account-free checks

```text
python python/run_all_checks.py
```

The suite currently evaluates 48 explicit behavioural and contract outcomes:

- 9 provenance assertions;
- 9 controlled environmental-transformation assertions;
- 6 geometry-agnostic transformation assertions;
- 7 generic administrative-harmonizer assertions;
- 7 deliberate transformation failures;
- 5 valid release-contract checks; and
- 5 corrupted-release rejections.

The command also validates release metadata and verifies every file listed in `CHECKSUMS.sha256`.

### 3. Run the generic example directly

```text
Rscript R/test_generic_harmonizer.R
```

This test creates a projected synthetic raster and three arbitrary polygon units named `ALPHA-01`, `BETA-02`, and `GAMMA-03`. It invokes the public generic interface and writes `generated/generic_admin_example.geojson`.

## Generic command-line interface

```text
Rscript R/harmonize_admin_raster.R \
  --raster input.tif \
  --boundaries administrative_units.geojson \
  --id-field admin_code \
  --value-name environmental_mean \
  --output generated/environmental_mean.geojson \
  --provenance "Source, product, period, method and applicable terms"
```

Optional controls support:

- raster layer selection;
- scale and offset conversion;
- lower and upper no-data masking;
- output rounding;
- minimum and maximum fail-closed bounds.

Display the full interface:

```text
Rscript R/harmonize_admin_raster.R --help
```

### Generic input contract

The raster must:

- be readable by `terra`;
- have a declared coordinate reference system;
- contain at least one selected layer;
- provide finite values for every polygon after optional masking.

The boundary file must:

- be readable by `sf`;
- contain valid polygon or multipolygon geometry;
- have a declared coordinate reference system;
- contain the requested identifier field;
- provide unique, non-empty identifiers.

The output is normalized to EPSG:4326 and contains only:

- `unit_id`;
- the requested measurement property;
- `provenance`;
- polygon geometry.

The generic interface validates processing behaviour. It does not determine whether a selected source, period, threshold, unit conversion, or scientific interpretation is appropriate.

## Rwanda reference implementation

The archived Rwanda layers contain one feature for each of 30 districts:

- CHIRPS v2.0 annual rainfall for 2023;
- ERA5-Land 2 m mean temperature for 2023;
- MODIS/Terra MOD13A3 v061 mean NDVI for 2023;
- Global 30 m HAND share at or below 5 m;
- common World Bank district geometry.

Run the real-data builders from any working directory:

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

Access requirements:

- CHIRPS and HAND require network access but no account.
- ERA5-Land requires a free Copernicus Climate Data Store account and accepted product terms.
- MODIS requires a free NASA Earthdata account.
- Credentials are read from provider-standard local configuration and are never committed.

Provider client versions used for the candidate are recorded in `requirements-providers.txt`.

## Public CHIRPS numerical validation

```text
Rscript R/validate_chirps_rainfall.R 2023
```

The workflow independently reacquires the public annual CHIRPS raster, reproduces the archived district values, compares `exactextractr` with `terra::extract`, and evaluates cell-area weighting sensitivity.

Current verified results for the tested source, year, and Rwanda geometry are:

- 30 of 30 archived values reproduce exactly after rounding;
- maximum cross-engine difference: 0.000136 mm;
- maximum cell-area-weighting difference: 0.005127 mm.

This validates computational reproduction of the CHIRPS layer only. Equivalent independent numerical validation has not been completed for ERA5-Land, MODIS, or HAND.

## Repository map

- `R/harmonize_admin_raster.R`: generic public command-line interface.
- `R/test_generic_harmonizer.R`: account-free arbitrary-region example.
- `R/`: provider transformations, builders, fixtures, failure tests, and figure generation.
- `python/`: provider clients, orchestration, release validation, and metadata checks.
- `data/`: Rwanda reference geometry and environmental GeoJSON layers.
- `paper/`: SoftwareX manuscript source, submission records, figures, and independent review material.
- `.github/workflows/`: reproducibility, metadata, and public-data validation.
- `DATA_DICTIONARY.md`: output-field definitions.
- `NOTICE.md`: source attribution, data terms, and scope boundaries.
- `REPRODUCIBILITY.md`: complete execution and evidence instructions.
- `CONTRIBUTING.md`: contribution and review rules.
- `codemeta.json` and `CITATION.cff`: machine-readable software metadata.

Historical journal-targeting records are retained for transparency but do not define the active SoftwareX product.

## Provenance contract

`R/provenance_value_class.R` accepts `source-derived` status only when a register row declares a documented method applied to real or public data. Unknown, incomplete, synthetic, and placeholder entries default to `illustrative` and receive an explanatory note.

The current release records lightweight human-readable provenance. It does not claim PROV-O, RO-Crate, Common Workflow Language, or workflow-engine conformance.

## Reproducibility and integrity

- `renv.lock` records the R dependency graph.
- `python/run_all_checks.py` runs the account-free evidence suite.
- `python/validate_release_contract.py` independently checks committed GeoJSON files and rejects controlled corruptions.
- `CHECKSUMS.sha256` covers the complete tracked candidate scope and is regenerated only after the source tree is frozen.
- GitHub Actions reruns the evidence suite on a clean hosted runner.
- The final `v1.3.0` tag and the Zenodo version registered as DOI `10.5281/zenodo.21840177` must identify the same exact release content.

Checksums establish byte integrity, not scientific validity.

## Licences and attribution

- **Code:** MIT, see `LICENSE`.
- **District geometry:** World Bank CC BY 4.0.
- **CHIRPS:** public domain or CC0.
- **ERA5-Land:** Copernicus Products licence.
- **MODIS and HAND outputs:** CC0.

See `NOTICE.md` for complete attribution and interpretation boundaries.

## Contributing and support

Use GitHub Issues for reproducible bug reports, documentation defects, provider changes, and feature proposals. Include the command, operating system, R and Python versions, input schema, and the smallest non-sensitive example that reproduces the problem.

Security-sensitive reports should follow `SECURITY_REVIEW.md` rather than being posted with credentials or private data.

Support contact: `priplee@gmail.com`.

## Citation

For version `1.3.0`, cite:

> Tuyishime AP (2026). SuRT-GeoHarmonizer: auditable administrative-scale Earth-data harmonization and provenance labelling. Version 1.3.0. Zenodo. https://doi.org/10.5281/zenodo.21840177

The DOI above is reserved for the exact validated `v1.3.0` archive and becomes registered when that Zenodo version is published. Historical version `1.2.0` remains permanently available at https://doi.org/10.5281/zenodo.21744708.
