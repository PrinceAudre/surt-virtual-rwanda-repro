# Changelog

## 1.4.0 - release freeze, 2026-10-05

### Reviewer-driven scientific corrections

- Replaced coverage-fraction-only raster aggregation with polygon-overlap and cell-surface-area weighting through the shared `R/zonal_area_summary.R` contract.
- Split spatial support into `raster_coverage_fraction`, `valid_within_raster_fraction`, and `valid_data_fraction`, with explicit partial-coverage regression fixtures.
- Corrected the ERA5-Land annual temperature statistic to a calendar-day-weighted mean of the 12 monthly means, including leap-year handling, before Celsius conversion and spatial aggregation.
- Added explicit MOD13A3 v061 pixel-reliability filtering, a production default of rank 0, configurable accepted ranks, and a minimum valid-month fraction for annual NDVI cells.
- Corrected the HAND low-lying denominator to valid HAND-covered area, excluding negative no-data sentinels and reporting spatial support separately.
- Added latitude-sensitive weighting, primary-raster no-data, partial raster-footprint, ERA5 annual-statistic, MODIS QA, HAND denominator, and transformation-failure regressions.
- Added scoped source-derived numerical cross-checks for Nyarugenge ERA5-Land 2023, Nyarugenge MOD13A3 v061 2023, and Rubavu HAND <= 5 m, with tracked source-pinned evidence and explicit observational-validity limits.
- Strengthened the independent release validator to reject incomplete, out-of-range, and algebraically inconsistent coverage-fraction groups while retaining compatibility with immutable v1.3 reference files that predate those fields.

### Generic interface, configuration, and workflow evidence

- Extended the generic harmonizer to validate raster and boundary CRS, polygon geometry, unique non-empty identifiers, layer selection, raw-unit no-data masking, scaling, bounds, and minimum valid-data coverage.
- Normalized the v1.4 generic output contract around explicit coverage fields while retaining provenance-labelled EPSG:4326 GeoJSON output.
- Added `config/harmonization-job.schema.json` and a fail-closed declarative configuration contract covering provider preparation, boundaries, variables, transformations, aggregation, QA, output, and provenance.
- Added a stable provider-adapter protocol with a built-in `local_raster` adapter and an external `module:factory` extension mechanism. Production provider-specific adapters remain separate future work.
- Added a Snakemake evidence DAG that validates configuration, prepares a controlled raster fixture, executes configured harmonization, validates the output, and records machine-readable workflow evidence.
- Added a source-derived Uganda national-boundary fixture and an account-free second-country portability gate. The test uses a deterministic synthetic raster, so it demonstrates cross-country geometry and identifier portability rather than scientific validation of an environmental product for Uganda.
- Added a separate source-derived Uganda CHIRPS 2023 configured case and independent `terra` cross-check, including regression coverage for near-global geographic raster-footprint normalization.
- Added a three-platform core smoke matrix covering Ubuntu 24.04, Windows 2025, and macOS 14 while retaining the explicit boundary that the full geospatial reproducibility workflow and credentialed provider acquisition are not claimed on every platform.
- Expanded hermetic fixtures to exercise the revised scientific contracts and to expose real reprojection support loss rather than silently asserting complete coverage.
- Made account-free result counting dynamic so reviewer-driven tests do not require a manually maintained assertion total.
- Separated ordinary development verification from the tracked-file manifest release gate. The dedicated manifest workflow rebuilds and checks `CHECKSUMS.sha256`, while `python/run_all_checks.py --verify-manifest` remains the strict frozen-candidate gate.

### Documentation and reproducibility

- Updated `README.md`, `DATA_DICTIONARY.md`, and `REPRODUCIBILITY.md` to describe the v1.4 spatial weighting, coverage, ERA5, MODIS, HAND, configuration, adapter, workflow, and development-versus-release contracts.
- Preserved the committed `data/` files as immutable published v1.3 reference artifacts while directing revised v1.4 builder outputs to `generated/` until independent validation and release approval are complete.
- Added CMake and the required geospatial system libraries to hosted Ubuntu CI for clean-cache restoration of the locked R environment.
- Added explicit Natural Earth attribution and interpretation limits for the Uganda portability fixture in `NOTICE.md`.

### Release-freeze status

- Final independent code/manuscript review and reviewer-response sign-off are complete.
- Version-specific Zenodo DOI `10.5281/zenodo.23162055` is reserved and inserted into release-facing metadata and the Array manuscript.
- The exact DOI-bearing source tree must now receive a regenerated complete tracked-file manifest and strict verification.
- After rendering inspection, tag `v1.4.0`, create the matching GitHub release, and publish that exact archive to Zenodo.

## 1.3.0 - SoftwareX release candidate, 2026-08-07

### Productization and reuse

- Introduced the standalone product identity **SuRT-GeoHarmonizer** while retaining the repository and SuRT-Virtual Rwanda relationship.
- Added `R/harmonize_admin_raster.R`, a provider-agnostic command-line interface for raster and polygon inputs, arbitrary unique identifiers, scale and offset conversion, no-data masking, bounds, provenance, and WGS84 GeoJSON output.
- Added `R/test_generic_harmonizer.R`, a complete account-free projected non-Rwanda example that writes and validates a three-unit GeoJSON output.
- Increased the account-free behavioural and contract suite from 41 to 48 explicit outcomes.
- Added a direct installation and quick-start pathway, generic input contract, contribution policy, CodeMeta record, and pinned optional provider clients.

### SoftwareX submission preparation

- Replaced Earth Science Informatics-specific identity in active README, CFF, project metadata, verification summaries, and candidate validation.
- Rebuilt the active manuscript as a SoftwareX Original Software Publication within the journal's 3,000-word limit.
- Added the SoftwareX code-metadata table, impact and reuse section, clear generic interface, and explicit separation between software verification and scientific validation.
- Preserved `v1.2.0` and DOI `10.5281/zenodo.21744708` as immutable history.
- Completed the account-free reproducibility workflow and public CHIRPS 2023 numerical validation on the release candidate.
- Reserved version-specific Zenodo DOI `10.5281/zenodo.21840177` for the exact validated `v1.3.0` archive.
- Defined a controlled DOI-bearing exact-head validation, immutable tag, GitHub release, and Zenodo publication gate.

## 1.2.0 - 2026-08-01

### Scientific and software evaluation

- Reframed the article as an Earth Science Informatics Software article focused on cross-provider Earth-data harmonization, provenance, executable evidence, and release integrity.
- Expanded account-free verification from 18 positive assertions to 41 explicit outcomes:
  - 9 provenance assertions;
  - 9 environmental-transformation assertions;
  - 6 projected, arbitrary-identifier portability assertions;
  - 7 transformation failure-injection assertions;
  - 5 valid GeoJSON release-contract checks; and
  - 5 deliberate release-corruption rejections.
- Added `python/validate_release_contract.py`, an independent standard-library validator for feature counts, identifiers, schemas, values, provenance, coordinates, district ordering, and exact geometry identity.
- Added `R/test_portability_fixture.R` to exercise generic transformations with projected non-Rwanda geometry and arbitrary administrative identifiers.
- Added `R/test_failure_modes.R` to prove that missing coverage, unit errors, inversion, unscaled MODIS values, partial years, all-no-data terrain, and impossible percentages fail closed.
- Added public CHIRPS numerical validation with exact archived-value reproduction, an independent `terra` cross-check, cell-area weighting sensitivity, machine-readable evidence, and a source-raster digest.
- Distinguished the 41 behavioural and contract outcomes from the separately scoped listed-file SHA-256 integrity checks.

### Manuscript and figures

- Rebuilt `paper/manuscript.md` around a six-level evidence hierarchy and narrowed every portability, numerical-validation, hazard, epidemiological, and operational claim.
- Added literature on Earth-science workflow reuse, FAIR provenance, PROV-O, and RO-Crate while explicitly avoiding standards-conformance claims.
- Added reproducible manuscript figures generated from the committed GeoJSON files.
- Added caption-free EPS and SVG line art and 600 dpi TIFF combination art, numeric map intervals, greyscale-ordered colour, and redundant line types and symbols.
- Added `paper/figures/ALT_TEXT.md` for final Word accessibility checks.
- Added a journal-specific reviewer dossier and a strict editorial-readiness record.
- Added `paper/DUAL_AGENT_REVIEW.md` as a shared Claude and Codex finding and decision ledger.

### Submission-package and release hygiene

- Archived the prior F1000Research readiness record and removed the historical F1000Research Word file and build script from the active candidate tree without rewriting Git history.
- Finalized release-facing metadata at version 1.2.0 with immutable Zenodo version DOI `10.5281/zenodo.21744708` and release date 2026-08-01.
- Retained version 1.1.1 and DOI `10.5281/zenodo.21677162` as the historical published base archive only.
- Regenerated the complete all-tracked SHA-256 manifest after DOI insertion and required exact-head CI before tagging and archival.

## Archived - F1000Research resubmission hardening attempt

- Reframed the earlier manuscript as one integrated Software Tool workflow.
- Added comparison with Google Earth Engine, MODIStsp, and `exactextractr`.
- Added input/output contracts, use cases, and a clearer distinction between software verification and scientific validation.
- Removed an unverified institutional affiliation from `CITATION.cff`.
- Added an editorial-readiness checklist and synchronized the then-current manuscript title.

This attempt was superseded after submission 188121 was declined at pre-publication check on 31 July 2026. Historical records are preserved under `paper/archive/` and in Git history.

## 1.1.1 - 2026-07-29

- Expanded the account-free NDVI fixture to exercise the complete two-month and two-tile MODIS-sinusoidal mosaic, annual-mean, scale, reprojection, and district-extraction path.
- Corrected the manuscript and submission package to report the resulting nine environmental-fixture assertions.

## 1.1.0 - 2026-07-29

- Replaced the potentially evaluative evidence class `sound` with `source-derived`.
- Renamed the HAND output and field to the neutral `low_lying_share_pct`; it is no longer described as flood-prone or flood-susceptibility.
- Removed the peripheral WorldPop-derived population attribute and its ODbL dependency from the released district geometry.
- Corrected ERA5-Land licensing language to the Copernicus Products licence.
- Made all builders repository-relative and parameterised their output, geometry, and cache paths.
- Added an account-free fixture pipeline, a one-command verification runner, an R dependency lockfile, and GitHub Actions.
- Added explicit reproducibility guidance and strengthened release metadata.
