# Tool-comparison evidence dossier

Prepared for the SoftwareX reviewer-remediation comparison of SuRT-GeoHarmonizer with Google Earth Engine, MODIStsp, and exactextractr.

Evidence checked: 2026-10-03.

## Comparison rule

The manuscript compares each tool at the level of its documented primary scope and built-in workflow contract. A cell marked "user-constructed" does not mean that the platform cannot implement the capability; it means the capability is not a fixed output/release contract of the named tool. The comparison must not portray mature tools as deficient merely because SuRT integrates several controls into one reproducible release workflow.

## Google Earth Engine

Primary evidence:

- Google Earth Engine `ee.Image.reduceRegions`: https://developers.google.com/earth-engine/apidocs/ee-image-reduceregions
- Earth Engine authentication and initialization: https://developers.google.com/earth-engine/guides/auth

Supported claims:

- `reduceRegions` applies a reducer to each feature in a collection and returns the input features augmented with reducer results.
- Scale and CRS can be explicitly supplied for regional reductions.
- Python and command-line clients require authentication and initialization with a Google Cloud project.
- Earth Engine is therefore a broad cloud geospatial computation platform, not a fixed local release contract for SuRT-style coverage, provenance, checksums, and negative-test evidence.
## MODIStsp

Primary evidence:

- Package overview: https://docs.ropensci.org/MODIStsp/
- Interactive processing and QA controls: https://docs.ropensci.org/MODIStsp/articles/interactive_execution.html
- Non-interactive JSON options: https://docs.ropensci.org/MODIStsp/articles/noninteractive_execution.html
- Offline processing: https://docs.ropensci.org/MODIStsp/articles/faq.html

Supported claims:

- MODIStsp automates creation of raster time series from MODIS Land Products, including download, mosaicking, reprojection, resize, and data extraction.
- It can extract quality indicators from MODIS QA layers and compute spectral indices.
- It supports non-interactive execution using saved JSON options and can process already-downloaded MODIS data in offline mode.
- Its documented scope is MODIS-specific preprocessing and time-series production rather than an arbitrary-provider administrative harmonization and release-evidence contract.

## exactextractr

Primary evidence:

- Package documentation: https://isciences.gitlab.io/exactextractr/
- `exact_extract` reference: https://isciences.gitlab.io/exactextractr/reference/exact_extract.html

Supported claims:

- exactextractr extracts or summarizes raster values covered by polygons.
- Named operations include polygon coverage-aware summaries.
- `weighted_mean` weights cell values by polygon coverage fraction and a weighting raster.
- `weights = "area"` calculates cell areas and uses them as weights.
- SuRT-GeoHarmonizer uses exactextractr as an extraction engine; it does not claim the underlying exact polygon extraction or area-weighting algorithm as a new contribution.
## SuRT-GeoHarmonizer evidence

Repository evidence used for the SuRT column:

- `R/harmonize_admin_raster.R`: arbitrary raster/polygon CLI, validation, coverage and provenance output.
- `R/zonal_area_summary.R`: polygon-overlap times cell-area weighting and explicit coverage fractions.
- `config/harmonization-job.schema.json`: fail-closed declarative job schema.
- `python/provider_adapters.py`: built-in local-raster adapter and external adapter extension boundary.
- `Snakefile`: account-free orchestration evidence DAG.
- `python/run_all_checks.py`: executable verification and negative-test aggregation.
- `python/validate_release_contract.py`: independent output-contract validation and corruption tests.
- `CHECKSUMS.sha256` plus CI workflows: tracked-file integrity and clean-run evidence.
- `config/uganda-chirps-2023.json` and `R/validate_uganda_chirps_case.R`: source-derived second-country environmental case and independent numerical cross-check.

## Safe comparison language

Use "integrated contract" rather than "unique capability" when distinguishing SuRT. Google Earth Engine and exactextractr can be composed into sophisticated workflows, and MODIStsp has substantial automation, QA, offline processing, and saved options. SuRT's demonstrated contribution is the integration of provider preparation boundaries, a generic administrative schema, explicit coverage semantics, provenance, fail-closed configuration, negative tests, independent release validation, checksums, CI, and versioned evidence in one small research-software workflow.
## Reviewer-facing comparison matrix

| Capability | Google Earth Engine | MODIStsp | exactextractr | SuRT-GeoHarmonizer |
|---|---|---|---|---|
| Data acquisition | Cloud catalogue | MODIS-specific | Not primary scope | Adapter/provider layer |
| Arbitrary raster + polygon processing | Platform capability | MODIS-oriented | Yes | Yes |
| Polygon zonal summaries | Yes | Downstream/user-defined | Core capability | Core workflow |
| Explicit cell-area weighting | User-defined reducers/weights | User-defined | Built in via area weights | Fixed default contract |
| Separate valid-data coverage fields | User-defined | Product/QA dependent | Coverage information available | Fixed output schema |
| Per-feature provenance field | User-defined | Processing metadata | User-defined | Fixed output schema |
| Fail-closed configuration schema | User-defined | Saved processing options | Not primary scope | Built in |
| Negative/failure tests | User workflow | Package tests | Package tests | Release gate |
| Independent output-contract validation | User workflow | Not primary scope | Not primary scope | Built in |
| Tracked-file checksums | User workflow | Not primary scope | Not primary scope | Release gate |
| Clean-run CI evidence | User workflow | Package CI | Package CI | Release gate |
| Account-free verification path | Cloud service authentication/project required | Offline processing possible after acquisition | Yes | Yes |
| Provider extension boundary | Platform/data-catalogue model | MODIS-specific | Raster-agnostic extraction | Adapter contract |
| Workflow orchestration | Platform task model/user workflow | Processing workflow | Function-level | Snakemake evidence DAG |

The matrix is deliberately architectural. It does not imply that capabilities marked user-defined are impossible in the comparison tool; it records what is built into the named tool's documented primary contract versus what a user must compose separately.