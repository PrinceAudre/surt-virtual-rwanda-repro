# Tool-comparison evidence dossier

Prepared for the SoftwareX reviewer-remediation comparison of SuRT-GeoHarmonizer with established geospatial tools and adjacent environmental-data pipelines.

Evidence checked: 2026-10-03.

## Comparison rule

The manuscript compares each tool at the level of its documented primary scope and built-in workflow contract. A cell marked "user-constructed" does not mean that the platform cannot implement the capability; it means the capability is not a fixed output/release contract of the named tool. The comparison must not portray mature tools as deficient merely because SuRT integrates several controls into one reproducible release workflow.

The novelty claim must remain architectural. SuRT does **not** claim a new zonal-statistics algorithm, a new cell-area algorithm, the first configurable environmental-data pipeline, or the first reproducible geospatial workflow.

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

## GDAL and terra

Primary evidence:

- GDAL raster zonal statistics documentation: https://gdal.org/en/stable/programs/gdal_raster_zonal_stats.html
- terra package documentation: https://rspatial.org/pkg/

Supported claims:

- Current GDAL provides zonal-statistics operations, including fractional pixel coverage and weighted statistics where configured.
- `terra` provides mature raster/vector processing and raster-cell area calculation and is used in SuRT's independent numerical cross-checks.
- These tools reinforce the boundary of the SuRT novelty claim: the contribution is not zonal statistics or area weighting themselves, but the integration of explicit semantics and release-evidence controls.

## DART-Pipeline

Primary evidence:

- Dasgupta A, Perez-Fernandez I, Huynh T, et al. *Scalable, open-access and multidisciplinary data integration pipeline for climate-sensitive diseases*. Wellcome Open Research. DOI: https://doi.org/10.12688/wellcomeopenres.24774.3
- Repository: https://github.com/kraemer-lab/DART-Pipeline

Supported claims:

- DART is a locally deployable, scalable pipeline for integrating epidemiological, socioeconomic, climatic, and environmental data for climate-sensitive-disease analyses.
- Users can specify country, administrative level, and time period; the pipeline acquires and preprocesses several data sources and aggregates them to administrative units.
- The published methods include area- or population-weighted spatial aggregation, extensible aggregation methods, testing, version locking, and structured metadata.
- DART is therefore a closer adjacent system than a simple raster extraction package for the climate-health/public-health use case.
- SuRT must not claim broader data-integration functionality than DART. The safe distinction is narrower: SuRT formalizes a raster-to-administrative release boundary with three explicit coverage quantities, fail-closed declarative jobs, a provider extension contract, restricted provenance-labelled GeoJSON outputs, deliberate negative and release-corruption tests, source-pinned independent numerical checks, and complete tracked-file release-integrity gates.
- The two systems can be described as complementary at different layers of an analytical stack; absence of any specific DART feature must not be claimed unless directly established from its primary documentation.

## Snakemake

Primary evidence:

- Snakemake documentation: https://snakemake.readthedocs.io/

Supported claims:

- Snakemake is mature workflow infrastructure. SuRT does not claim workflow-management novelty.
- The v1.4 evidence DAG uses Snakemake to make controlled preparation, configured harmonization, validation, and evidence steps executable in CI.

## SuRT-GeoHarmonizer evidence

Repository evidence used for SuRT claims:

- `R/harmonize_admin_raster.R`: arbitrary raster/polygon CLI, validation, coverage and provenance output.
- `R/zonal_area_summary.R`: polygon-overlap times cell-area weighting and explicit coverage fractions.
- `config/harmonization-job.schema.json`: fail-closed declarative job schema.
- `python/provider_adapters.py`: built-in local-raster adapter and external adapter extension boundary.
- `python/fixture_external_adapter.py` and `python/test_config_contract.py`: positive executable proof that a `module:factory` adapter works without editing the built-in registry, plus malformed-plugin failures.
- `Snakefile`: account-free orchestration evidence DAG.
- `python/run_all_checks.py`: executable verification and negative-test aggregation.
- `python/validate_release_contract.py`: independent output-contract validation and corruption tests.
- `CHECKSUMS.sha256` plus CI workflows: tracked-file integrity and clean-run evidence.
- `config/uganda-chirps-2023.json` and `R/validate_uganda_chirps_case.R`: source-derived second-country environmental case and independent numerical cross-check.
- `evidence/era5land/`, `evidence/modis/`, and `evidence/hand/`: scoped source-pinned real-data numerical cross-check records.

## Safe comparison language

Use "integrated contract" or "release-evidence boundary" rather than "unique capability" when distinguishing SuRT. Google Earth Engine and exactextractr can be composed into sophisticated workflows, MODIStsp has substantial automation and QA, GDAL and terra provide mature geospatial primitives, and DART provides a broader climate-disease data-integration pipeline. SuRT's demonstrated contribution is the integration of provider preparation boundaries, a generic administrative schema, explicit area and coverage semantics, provenance, fail-closed configuration, a tested external adapter boundary, negative tests, independent release validation, source-pinned cross-checks, checksums, CI, and versioned evidence in one small research-software workflow.

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

The matrix is deliberately architectural and retains the three tools named by the SoftwareX reviewer. DART, GDAL, terra, and Snakemake are discussed in prose because they occupy different layers and forcing them into the same matrix would imply false one-to-one equivalence.
