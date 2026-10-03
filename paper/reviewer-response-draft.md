# Draft point-by-point response to SoftwareX reviewers

Manuscript: `SOFTX-D-26-01014`

Working title: **SuRT-GeoHarmonizer: An auditable R and Python workflow for administrative-scale Earth-data harmonization and provenance labelling**

This document is a response draft for a rebuilt submission. The verbatim five-page reviewer report remains archived outside the public repository as `SOFTX-D-26-01014-reviews.pdf`; reviewer comments below are summarized rather than republished verbatim.

## Reviewer 1

### R1.1 Partial valid-data coverage was not quantified

**Response:** Addressed. The generic zonal primitive now separates `raster_coverage_fraction`, `valid_within_raster_fraction`, and `valid_data_fraction`. The public CLI exposes `--min-valid-fraction`, while the default reports partial support without silently rejecting it.

**Code/evidence:**
- `R/zonal_area_summary.R`
- `R/harmonize_admin_raster.R`
- `R/test_zonal_area_summary.R`
- `R/test_generic_harmonizer.R`
- `DATA_DICTIONARY.md`

**Manuscript:** Sections 2.2, 3.3, and 4.

### R1.2 Coverage fraction was not equivalent to true surface-area weighting

**Response:** Addressed. Finite raster contributions are now weighted by polygon-cell overlap fraction multiplied by raster-cell surface area in square metres. Latitude-sensitive and partial-coverage regressions are included. A later CI-discovered antimeridian regression from tiny near-global longitude spill was also fixed and tested.
**Code/evidence:**
- `R/zonal_area_summary.R`
- `R/test_zonal_area_summary.R`
- `R/validate_chirps_rainfall.R`
- `R/validate_uganda_chirps_case.R`

**Manuscript:** Sections 2.2 and 3.3.

### R1.3 HAND denominator and no-data semantics were ambiguous

**Response:** Addressed. HAND is now explicitly defined as the percentage of **valid HAND-covered area** at or below the selected threshold. Numerator and denominator use overlap times cell-surface-area weighting, valid coverage is reported separately, and mixed valid/no-data controlled fixtures verify the denominator exactly.

**Code/evidence:**
- `R/relief_low_lying_transform.R`
- `R/build_relief_low_lying_hand.R`
- `R/test_hand_summary.R`
- `R/validate_hand_rubavu_real.R`
- `evidence/hand/rubavu_hand_real_validation_summary.json`

**Manuscript:** Sections 2.4, 3.3, and 4.

### R1.4 Controlled verification needed to remain distinct from independent real-data validation

**Response:** Addressed. Controlled fixtures remain explicitly separate from independent real-data numerical checks. Rwanda CHIRPS reproduction is retained as a public-source check; the source-derived Uganda CHIRPS case runs the generic configured workflow and is independently cross-checked with `terra`; scoped independent checks now also cover the revised ERA5-Land, MODIS, and HAND methods. None is presented as validation of observational accuracy.
**Real-data evidence:**
- Rwanda CHIRPS: 30/30 archived district values reproduced after rounding; maximum cross-engine difference 0.000136 mm.
- Uganda CHIRPS: configured mean 1,238.073160 mm; independent `terra` mean 1,238.073144 mm; absolute difference 0.000016 mm; all reported coverage fractions 1.0.
- Nyarugenge ERA5-Land 2023: production 20.597411 °C; independent `terra` 20.597414 °C; absolute difference approximately 0.000003 °C; complete reported coverage.
- Nyarugenge MOD13A3 2023: production reports 0.56 NDVI; independent estimate 0.55775352 before the declared two-decimal output rounding; valid-area and valid-month fraction differences remain within 0.000051.
- Rubavu HAND <=5 m: production 26.133870170321%; independent `terra` 26.133870170236%; effectively zero percentage-point difference; complete reported coverage.
- Tracked summaries: `evidence/chirps/`, `evidence/era5land/`, `evidence/modis/`, and `evidence/hand/`.
- Primary public numerical CI run `37118685044`, artifact `11272582312`, verifies CHIRPS and HAND on the remediation branch.

### R1.5 The generic public interface did not directly test every documented branch

**Response:** Addressed. Direct contract tests now cover layer selection by index and name, scale, offset, raw-unit masking order, `na_below`, `na_above`, strict integer parsing, duplicate and empty identifiers, missing raster and boundary CRS, invalid or unsupported geometry, value bounds, full no-data failure, partial coverage, reserved output-name collisions, output schema, and CRS. The independent Python release validator also rejects incomplete coverage-field groups, out-of-range fractions, and algebraically inconsistent `valid_data_fraction` values while remaining backward-compatible with the immutable v1.3 files that predate those fields.

**Code/evidence:** `R/test_generic_harmonizer.R`; account-free CI suite.

### R1.6 The integration contribution needed a clearer comparison with established tools

**Response:** Addressed. The revised manuscript adds an explicit comparison matrix covering Google Earth Engine, MODIStsp, exactextractr, and SuRT-GeoHarmonizer. The comparison is deliberately framed around documented primary scope and built-in contracts, not theoretical composability or claims that established tools are deficient.

**Evidence:**
- Manuscript Table 1
- `paper/tool-comparison-evidence.md`

### R1.7 MODIS quality information was available but unused

**Response:** Addressed. The v1.4 production builder uses the MOD13A3 pixel-reliability layer with an explicit policy; the production default accepts reliability rank 0, and a deliberate unfiltered mode remains available for controlled use. Temporal completeness and QA behavior have controlled tests. A credentialed real-data check independently reads all 24 source HDF granules for 2023, applies raw-DN scaling and rank-0 QA independently, and reproduces the Nyarugenge result under the declared two-decimal output contract. Per-granule SHA-256 values and the source-set fingerprint are retained in `evidence/modis/nyarugenge_mod13a3_2023_validation_summary.json`.

**Code/evidence:** `R/relief_ndvi_transform.R`; `R/build_relief_climate_ndvi_real.R`; `R/test_ndvi_qa.R`; `R/validate_modis_ndvi_nyarugenge_real.R`.

### R1.8 ERA5-Land annual temperature statistic needed a precise definition

**Response:** Addressed. The v1.4 transformation computes a calendar-day-weighted annual mean of the 12 monthly means, including leap-year handling, before kelvin-to-Celsius conversion. Controlled leap-year and non-leap-year tests are green. The source-derived Nyarugenge 2023 cross-check also passes: 20.597411 °C from the production path versus 20.597414 °C from an independent `terra` calculation, with complete reported coverage. The source SHA-256, CDS request identity, and acceptance gate are retained in `evidence/era5land/nyarugenge_era5land_2023_validation_summary.json`.

**Code/evidence:**
- `R/relief_temp_transform.R`
- `R/test_temperature_annual_mean.R`
- `R/validate_era5land_nyarugenge_real.R`
- `evidence/era5land/nyarugenge_era5land_2023_validation_summary.json`

### R1.9 Raw-unit no-data thresholds and `round_digits` parsing needed clarification

**Response:** Addressed. Documentation now states that `na_below` and `na_above` operate on raw/source values before scale and offset. Integer parsing for `round_digits` is fail-closed and directly tested.

### R1.10 Geographic/input portability should not be conflated with operating-system portability

**Response:** Addressed with an explicit support boundary and executable evidence. Geographic/input portability remains distinct from operating-system portability. The full reproducibility workflow remains Ubuntu-based, while the core dependency-light contract now passes a GitHub Actions smoke matrix on Ubuntu 24.04, Windows 2025, and macOS 14. Credentialed provider acquisition is not claimed cross-platform. Core platform smoke run `37137478475` passed Ubuntu 24.04, Windows 2025, and macOS 14 on the current evidence commit `a902bdd`.

## Reviewer 2

### R2.1 The workflow had not been exercised beyond Rwanda

**Response:** Addressed substantively. The rebuilt software now includes two Uganda cases using the source-derived Natural Earth boundary. One uses a deterministic synthetic raster to isolate geometry and identifier portability. The second uses the public CHIRPS v2.0 annual 2023 raster through the same declarative `local_raster` adapter and generic harmonizer, followed by an independent `terra` numerical cross-check. No Rwanda-specific edit to the generic harmonizer is required.

**Evidence:**
- `fixtures/uganda_natural_earth_110m.geojson`
- `R/test_second_country_portability.R`
- `config/uganda-chirps-2023.json`
- `R/validate_uganda_chirps_case.R`
- Public CHIRPS CI run and artifact

### R2.2 The design lacked sufficient customizability and extensibility

**Response:** Addressed in the software architecture and now demonstrated by an executable external-extension test. A fail-closed JSON Schema declares provider input, boundaries, variable/layer selection, transformations, aggregation, QA, coverage threshold, output, and provenance. A stable Python adapter boundary exposes a built-in `local_raster` adapter plus an external `module:factory` extension mechanism. The account-free suite now loads `fixture_external_adapter:make_adapter` from a module that is not registered in the core `_BUILTINS` mapping, prepares a declared raster artifact through that adapter, checks its provenance contribution, and separately rejects a malformed external adapter object and undeclared adapter options. The generic R harmonizer is not edited for this extension.

**Code/evidence:**
- `config/harmonization-job.schema.json`
- `python/config_contract.py`
- `python/provider_adapters.py`
- `python/fixture_external_adapter.py`
- `python/test_config_contract.py`
- `python/run_configured_harmonization.py`

**Documentation:** `docs/CONFIGURATION_AND_ADAPTERS.md` provides the bring-your-own-raster/boundaries sequence, stable adapter contract, external `module:factory` example, QA ownership rules, adapter testing requirements, and the scope of the executable plugin proof. This demonstrates the extension boundary itself; it does not claim that every third-party provider is already implemented.

### R2.3 The manuscript did not demonstrate enough value over a tailored reimplementation

**Response:** Addressed through a narrower value proposition, executable reuse evidence, and a broader related-software audit. The revised manuscript does not present a new raster, zonal-statistics, or cell-area algorithm. It identifies the reusable contribution as a raster-to-administrative release-evidence contract combining provider-preparation boundaries, generic harmonization, explicit area and three-part coverage semantics, provenance-labelled outputs, fail-closed declarative configuration, a tested external adapter boundary, negative and corruption tests, independent release validation, source-pinned numerical cross-checks, checksums, CI, and versioned evidence. The same configured generic engine is exercised on a source-derived Uganda CHIRPS case without Rwanda-specific core edits.

The comparison retains Google Earth Engine, MODIStsp, and exactextractr because they were named by the reviewer, but the related-work audit now also discusses GDAL, `terra`, Snakemake, and DART-Pipeline. DART is a particularly relevant adjacent climate-sensitive-disease pipeline: it integrates epidemiological, socioeconomic, climatic, and environmental data and performs administrative aggregation. The revised manuscript therefore makes a deliberately narrower claim. SuRT does not claim broader integration than DART; it focuses on the raster-to-administrative release boundary and its explicit coverage, provenance, fail-closed, numerical-cross-check, and release-integrity contracts. The systems can be complementary at different layers of an analytical stack.

**Evidence:** Manuscript Sections 1 and 4; Table 1; `paper/tool-comparison-evidence.md`; `paper/FINAL_REVIEW_PROTOCOL.md`; Dasgupta et al., DOI `10.12688/wellcomeopenres.24774.3`.

### R2.4 The project did not use a workflow-management system

**Response:** Addressed. A Snakemake evidence DAG now models the account-free configured demonstration and is executed independently in CI. The R and Python CLIs remain callable directly. The workflow proves orchestration and interface contracts without converting controlled synthetic evidence into a claim of real-product scientific validity.

**Code/evidence:** `Snakefile`, `generated/workflow_demo/`, reproducibility CI.

## Remaining items before a final response can be signed

The following are intentionally unresolved rather than overstated:
- final release metadata, v1.4.0 tag, and version-specific Zenodo DOI;
- final exact-manifest verification on the DOI-bearing release commit;
- final rendered manuscript inspection and evidence-led final code/manuscript review under `paper/FINAL_REVIEW_PROTOCOL.md`.

## Evidence and commit index

Major reviewer-remediation commits on `review/softwarex-resubmission-v1.4.0` include:

- `05d7f224`: explicit area-weighted zonal coverage core.
- `9d08c4a3`: spatial weighting and partial-coverage reviewer regressions.
- `a737db8d`: generic harmonizer made area-aware and coverage-explicit.
- `bdded592`: expanded generic-interface reviewer contract tests.
- `8941202b`: verification totals made evidence-derived rather than hard-coded.
- `9922ff8b`, `eea49dc4`, `4145c9a6`: HAND valid-area denominator, coverage, and regression tests.
- `a1984391`, `533ae037`, `3293bdae`: ERA5 calendar-day annual statistic and controlled tests.
- `a3729572`, `d36ecf29`, `2b14b25e`: MOD13A3 QA, coverage, and controlled tests.
- `8dff8c59`: declarative configuration and provider-adapter contract.
- `4476356e`: explicit Snakemake workflow evidence DAG.
- `74963ff9`: source-derived Uganda-boundary synthetic portability fixture.
- `82889085`: source-derived Uganda CHIRPS configured case and independent validator.
- `4d038864`: near-global geographic raster-footprint normalization regression fix.
- `9b4efed5`: manuscript Uganda evidence, comparison matrix, and supporting documentation.
- `a902bdd`: source-pinned CHIRPS/MODIS/HAND evidence consolidation, MODIS independent validator, reviewer-response synchronization, and stricter coverage-fraction release-contract corruption tests.

Key CI evidence:

- Public CHIRPS validation run `37113953260`: success; artifact `chirps-2023-numerical-validation`.
- Artifact digest: `sha256:404100e16130ca13dd8661a2e1069498c6bf3846c8e11a6c56273f6f416026ed`.
- Metadata/manuscript validation run `37115602062`: success on `9b4efed5`.
- Reproducibility run `37115602063`: success on `9b4efed5`.
- Primary public numerical run `37118685044`: success; Uganda CHIRPS 1,238.073160 versus 1,238.073144 mm and Rubavu HAND 26.133870% in both implementations; artifact `11272582312`.
- Three-platform core smoke run `37137478475`: success on Ubuntu 24.04, Windows 2025, and macOS 14 at `a902bdd`.
- Metadata/manuscript validation run `37137478460`: success at `a902bdd`.
- Reproducibility run `37137478520`: success at `a902bdd`.
- ERA5-Land source-pinned evidence: `evidence/era5land/nyarugenge_era5land_2023_validation_summary.json`.
- MOD13A3 source-pinned evidence: `evidence/modis/nyarugenge_mod13a3_2023_validation_summary.json`.

The final signed response must replace this development commit index with the exact frozen v1.4.0 release commit and version DOI once release gates are complete.
