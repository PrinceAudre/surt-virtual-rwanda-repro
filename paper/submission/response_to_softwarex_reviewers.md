# Response to prior SoftwareX reviewers

**Prior manuscript:** `SOFTX-D-26-01014`  
**Prior title:** *SuRT-GeoHarmonizer: An auditable R and Python workflow for administrative-scale Earth-data harmonization and provenance labelling*  
**Transferred journal:** Array  
**Current title:** *SuRT-GeoHarmonizer: A contract-first workflow for verifiable raster-to-administrative data harmonization*  
**Released software:** SuRT-GeoHarmonizer v1.4.0  
**Exact tagged commit:** `49a87472c3581b6f1912cde97c900ec3dbd17335`  
**Zenodo version DOI:** `10.5281/zenodo.23162055`

## Overview

Thank you for the detailed external review of the SoftwareX submission. The manuscript and software were not simply reformatted for transfer. They were substantively rebuilt around the reviewers' technical and software-engineering concerns. The revised work narrows its novelty claim, corrects the spatial formulations, adds direct tests and independent numerical cross-checks, demonstrates the generic workflow outside Rwanda, introduces declarative configuration and an external provider-adapter boundary, adds workflow orchestration, and binds the reported software state to an exact released source tree.

The comments below are summarized rather than reproduced verbatim. The complete five-page reviewer report remains the controlling source in the author's records.

## Reviewer 1

### 1. Valid-data coverage was not quantified clearly

**Response:** Addressed. The harmonization contract now reports three separate support quantities for every polygon: `raster_coverage_fraction`, `valid_within_raster_fraction`, and `valid_data_fraction`. The last is invariant-checked as the product of the first two. Partial support is therefore visible rather than hidden behind a plausible zonal mean. A configurable minimum overall valid-data fraction can fail closed when required.

**Evidence:** `R/zonal_area_summary.R`, `R/harmonize_admin_raster.R`, `R/test_zonal_area_summary.R`, `R/test_generic_harmonizer.R`, `DATA_DICTIONARY.md`.

### 2. Geographic-coordinate calculations needed true surface-area weighting

**Response:** Addressed. Finite raster contributions are weighted by polygon-cell overlap fraction multiplied by raster-cell surface area in square metres. Controlled tests include partial coverage, latitude-sensitive cells, and a near-global footprint regression that exposed and then fixed a longitude-normalization edge case.

**Evidence:** `R/zonal_area_summary.R`, `R/test_zonal_area_summary.R`.

### 3. The HAND denominator and no-data treatment were ambiguous

**Response:** Addressed. HAND is defined as the percentage of **valid HAND-covered area** at or below the selected threshold. Numerator and denominator use overlap multiplied by cell surface area. Negative sentinel values are excluded as unknown rather than being counted as non-low-lying terrain. Coverage is reported separately.

Controlled mixed valid/no-data fixtures verify the denominator, and a public real-data cross-check for Rubavu at or below 5 m reproduced the production result independently: `26.133870170321%` versus `26.133870170236%`.

**Evidence:** `R/relief_low_lying_transform.R`, `R/build_relief_low_lying_hand.R`, `R/test_hand_summary.R`, `R/validate_hand_rubavu_real.R`, `evidence/hand/`.

### 4. Controlled verification needed to be distinguished from independent real-data validation

**Response:** Addressed. Controlled software fixtures are explicitly separated from source-pinned numerical cross-checks. The latter establish computational agreement for defined cases, not observational accuracy of the source products.

Selected checks include:

- Uganda CHIRPS 2023: configured `1,238.073160 mm` versus independent `terra` `1,238.073144 mm`, absolute difference `0.000016 mm`, with all three support fractions equal to 1.0.
- Nyarugenge ERA5-Land 2023: production `20.597411 °C` versus independent `20.597414 °C`.
- Nyarugenge MOD13A3 v061 2023: reported `0.56` versus independent pre-rounding estimate `0.55775352`, consistent with the declared two-decimal output contract.
- Rubavu HAND at or below 5 m: production `26.133870170321%` versus independent `26.133870170236%`.

**Evidence:** `evidence/chirps/`, `evidence/era5land/`, `evidence/modis/`, `evidence/hand/`.

### 5. The public generic interface required broader direct testing

**Response:** Addressed. Direct positive and negative tests now cover layer selection by index and name, scale, offset, raw-unit `na_below` and `na_above`, masking before transformation, strict integer parsing, duplicate and empty identifiers, missing raster and boundary CRS, invalid and unsupported geometry, value bounds, full no-data failure, partial coverage, minimum-valid-fraction failure, reserved output-name collisions, output schema, and CRS.

The independent release validator additionally rejects incomplete support-field groups, support fractions outside [0,1], and algebraically inconsistent overall support.

**Evidence:** `R/test_generic_harmonizer.R`, `python/validate_release_contract.py`, account-free reproducibility workflow.

### 6. The value proposition needed comparison with established tools

**Response:** Addressed and narrowed. The revised manuscript explicitly states that SuRT-GeoHarmonizer does not introduce a new zonal-statistics algorithm. It discusses exactextractr/exactextract, terra, GDAL, xagg, spatcovar, Google Earth Engine, DART-Pipeline/geoglue, DHIS2 climate tooling, stagg, Climate-CAFE and other adjacent systems. The contribution claimed is the evaluated integration and assurance contract around one raster-to-administrative handoff, not priority over the underlying geospatial operations.

**Evidence:** manuscript Section 2 and Table 1; `paper/ARRAY_NOVELTY_PRIOR_ART_AUDIT.md`; `paper/ARRAY_CLAIM_EVIDENCE_MATRIX.md`.

### 7. MODIS quality information was available but unused

**Response:** Addressed. The production MOD13A3 path uses the pixel-reliability subdataset explicitly. Reliability rank 0 is the production default, an unfiltered mode is available only when deliberately requested, and temporal completeness is reported. QA behavior and minimum-month completeness have direct controlled tests.

A source-pinned real-data check independently processed the 24 source HDF granules for 2023, including raw scaling and rank-0 filtering, and reproduced the Nyarugenge result within the declared output contract. Each source granule is SHA-256 pinned.

**Evidence:** `R/relief_ndvi_transform.R`, `R/build_relief_climate_ndvi_real.R`, `R/test_ndvi_qa.R`, `R/validate_modis_ndvi_nyarugenge_real.R`, `evidence/modis/`.

### 8. The ERA5-Land annual statistic required a precise definition

**Response:** Addressed. The annual temperature statistic is now the calendar-day-weighted mean of the 12 monthly means, with explicit leap-year handling, followed by Kelvin-to-Celsius conversion and surface-area-weighted polygon aggregation. Leap and non-leap controlled tests are included.

The source-derived Nyarugenge 2023 cross-check produced `20.597411 °C` from the production path and `20.597414 °C` independently.

**Evidence:** `R/relief_temp_transform.R`, `R/test_temperature_annual_mean.R`, `R/validate_era5land_nyarugenge_real.R`, `evidence/era5land/`.

### 9. Raw no-data thresholds and `round_digits` parsing needed clarification

**Response:** Addressed. `na_below` and `na_above` are documented and tested as raw/source-unit masks applied before scale and offset. `round_digits` is parsed strictly as an integer and fails closed for invalid forms.

### 10. Geographic portability should not be conflated with operating-system portability

**Response:** Addressed. Geographic/input portability and OS portability are now separate claims. The same generic contract is exercised on Rwanda and Uganda geometry. A separate core smoke matrix passes on Ubuntu 24.04, Windows 2025 and macOS 14. Full geospatial reproducibility remains Ubuntu-based, and credentialed provider acquisition is not claimed to have been validated on all operating systems.

**Evidence:** `.github/workflows/platform-smoke.yml`, Uganda cases, manuscript portability limitations.

## Reviewer 2

### 1. The workflow had not been demonstrated beyond Rwanda

**Response:** Addressed with a source-derived second-country case. The same configuration-driven generic harmonizer processes a Natural Earth Uganda boundary and public CHIRPS v2.0 annual 2023 raster without Rwanda-specific edits to the core harmonizer. An independent `terra` calculation reproduces the result within `0.000016 mm`, with complete reported support.

A separate Uganda synthetic-signal fixture isolates geometry and identifier portability from source-product behavior.

**Evidence:** `fixtures/uganda_natural_earth_110m.geojson`, `config/uganda-chirps-2023.json`, `R/test_second_country_portability.R`, `R/validate_uganda_chirps_case.R`.

### 2. Customizability and extensibility were insufficiently demonstrated

**Response:** Addressed in code and tests. A fail-closed JSON Schema defines provider input, boundaries, variable selection, transformations, aggregation, QA, coverage thresholds, output and provenance. The Python provider layer exposes a stable built-in adapter contract plus an external `module:factory` mechanism. The account-free suite loads an out-of-tree fixture provider without modifying the generic R harmonizer or the built-in registry and rejects malformed adapter objects and undeclared options.

**Evidence:** `config/harmonization-job.schema.json`, `python/config_contract.py`, `python/provider_adapters.py`, `python/fixture_external_adapter.py`, `python/test_config_contract.py`, `docs/CONFIGURATION_AND_ADAPTERS.md`.

### 3. The manuscript needed clearer value over a tailored reimplementation

**Response:** Addressed by narrowing the claim and evaluating the contract directly. The revised manuscript does not claim broad superiority over established geospatial or climate-health systems. It evaluates the information value of decomposed support semantics, source-pinned numerical agreement, the external provider boundary, geographic and bounded OS portability, and the measured cost of the mandatory support contract.

The value proposition is therefore not that each component is individually novel. It is that one bounded raster-to-administrative handoff is made explicit, fail-closed, provider-extensible, independently checkable and release-verifiable.

**Evidence:** manuscript RQ1-RQ5, Table 1, `paper/ARRAY_CLAIM_EVIDENCE_MATRIX.md`, prior-art audit records.

### 4. The project lacked workflow management

**Response:** Addressed. Snakemake now models the account-free evidence DAG while preserving independently callable R and Python CLIs. CI executes that DAG and retains the evidence outputs. Credentialed provider acquisition remains intentionally outside the account-free DAG and uses provider-standard external credential handling.

**Evidence:** `Snakefile`, `docs/WORKFLOW.md`, reproducibility workflow.

## Additional changes made during the rebuild

Beyond the minimum reviewer requests, the rebuild added release-contract corruption tests, an exact tracked-file SHA-256 manifest, negative tests for fail-closed behavior, a three-platform core smoke matrix, a documented final adversarial review, multiple prior-art delta audits, and a measured benchmark of the support contract against a direct area-weighted mean using the same geospatial primitives.

The manuscript was also rewritten around five explicit research questions and a narrower novelty boundary. Unsupported or weakly evidenced claims were removed, including an earlier historical optimization timing anecdote for which a durable pre-change benchmark artifact had not been retained.

## Final release and submission identity

The reviewer-remediated software has now been frozen and published as:

- **Version:** 1.4.0
- **Git tag:** `v1.4.0`
- **Exact commit:** `49a87472c3581b6f1912cde97c900ec3dbd17335`
- **Zenodo version DOI:** `10.5281/zenodo.23162055`
- **Zenodo concept DOI:** `10.5281/zenodo.21671788`
- **Repository:** `https://github.com/PrinceAudre/surt-virtual-rwanda-repro`

The prior v1.3.0 release remains immutable historical provenance. The Array manuscript uses the current title *SuRT-GeoHarmonizer: A contract-first workflow for verifiable raster-to-administrative data harmonization* and explicitly discloses the prior SoftwareX review history.

## Closing statement

The reviewers' comments materially improved both the software and the manuscript. Every reviewer-blocking scientific or engineering concern identified in the SoftwareX review has been addressed with executable evidence, a bounded claim, or both. Remaining actions are editorial-system completion and final author approval; they do not require rewriting the published v1.4.0 software release.
