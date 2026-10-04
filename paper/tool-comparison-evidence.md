# Tool-comparison evidence dossier

Prepared originally for the SoftwareX reviewer-remediation comparison and retained as prior-art evidence for the Array hardening cycle.

Evidence checked: 2026-10-04.

See also `paper/ARRAY_NOVELTY_PRIOR_ART_AUDIT.md`.

## Comparison rule

Compare each tool at the level of its documented primary scope and built-in workflow contract. A cell marked "user-constructed" does not mean that the platform cannot implement the capability; it means the capability is not a fixed output/release contract of the named tool. Mature tools must not be portrayed as deficient merely because SuRT integrates several controls into one bounded workflow.

The novelty claim must remain architectural. SuRT does **not** claim a new zonal-statistics algorithm, polygon-cell overlap method, raster-cell-area algorithm, first configurable environmental-data pipeline, first reproducible geospatial workflow, first provenance/checksum pipeline, or first climate-health integration system.

## Google Earth Engine

Primary evidence:

- `ee.Image.reduceRegions`: https://developers.google.com/earth-engine/apidocs/ee-image-reduceregions
- `ee.Image.pixelArea`: https://developers.google.com/earth-engine/apidocs/ee-image-pixelarea
- authentication: https://developers.google.com/earth-engine/guides/auth

Supported claims:

- Earth Engine applies reducers to feature collections and allows scale/CRS control.
- Pixel area and masking can be composed into custom weighted workflows.
- Python and command-line service use requires authentication/initialization.
- Earth Engine is a broad cloud geospatial platform, not a fixed local SuRT-style administrative output/release contract.

## MODIStsp

Primary evidence:

- https://docs.ropensci.org/MODIStsp/
- https://docs.ropensci.org/MODIStsp/articles/interactive_execution.html
- https://docs.ropensci.org/MODIStsp/articles/noninteractive_execution.html
- https://docs.ropensci.org/MODIStsp/articles/faq.html

Supported claims:

- MODIStsp automates MODIS download, mosaicking, reprojection, resize and data extraction.
- It supports MODIS QA controls, spectral indices, saved JSON options and offline processing after acquisition.
- Its documented scope is MODIS-specific preprocessing/time-series production rather than arbitrary-provider administrative harmonization.

## exactextract / exactextractr

Primary evidence:

- https://isciences.github.io/exactextract/
- https://isciences.gitlab.io/exactextractr/

Supported claims:

- exactextract(r) provides exact polygon-cell coverage fractions and zonal summaries.
- Weighted operations can combine polygon coverage with a weighting raster; cell-area weighting is supported.
- SuRT uses exactextractr as an extraction engine and does not claim these algorithms as new.

## xagg

Primary evidence:

- https://xagg.readthedocs.io/
- https://doi.org/10.21105/joss.07239

Supported claims:

- xagg aggregates xarray gridded data to polygons using fractional area overlap and optional secondary weights.
- Climate econometrics and administrative societal-data applications are explicit use cases.
- SuRT therefore cannot claim novelty for area-weighted gridded-to-administrative aggregation itself.

## GDAL and terra

Primary evidence:

- https://gdal.org/en/stable/programs/gdal_raster_zonal_stats.html
- https://rspatial.org/terra/

Supported claims:

- Current GDAL provides zonal-statistics operations including fractional pixel coverage when configured.
- terra provides mature raster/vector processing and cell-area calculation and is used in SuRT's independent numerical cross-checks.

## AREAdata

Primary evidence:

- Pearse WD et al. *AREAdata: A worldwide climate dataset averaged across spatial units at different scales through time*. https://pmc.ncbi.nlm.nih.gov/articles/PMC9278028/

Supported claims:

- AREAdata uses CDO and exactextractr to aggregate climate variables to administrative units with fractional-overlap weighting.
- Its automated pipeline updates and republishes derived datasets and can be rerun locally.
- Automated/reproducible administrative climate aggregation is therefore prior art.

## DART-Pipeline

Primary evidence:

- Dasgupta A, Perez-Fernandez I, Huynh T, et al. *Scalable, open-access and multidisciplinary data integration pipeline for climate-sensitive diseases*. https://doi.org/10.12688/wellcomeopenres.24774.3
- repository: https://github.com/kraemer-lab/DART-Pipeline
- configuration documentation: https://dart-pipeline.readthedocs.io/en/latest/workflow/configuration.html
- custom metrics: https://dart-pipeline.readthedocs.io/en/latest/reference/custom_metrics.html

Directly supported claims:

- DART is a locally deployable climate-health pipeline integrating epidemiological, socioeconomic, climatic and environmental data.
- Users specify geography/administrative level and time; multiple source products are prepared and aggregated to administrative units.
- DART/geoglue uses exact polygon-cell coverage fractions and spherical cell-area weighting, with area- or population-weighted aggregation.
- DART has tests, CI, version locking, structured metadata, licences/citations, valid bounds and documented custom-source/metric extension.
- Repository inspection of the ERA5 daily processing path shows provenance propagation and a SHA-256 of a resampled source artifact included in provenance. SuRT therefore must **not** imply that provenance plus checksums distinguishes it from DART.
- DART's documented convenience workflow uses a shell configuration (`config.sh`). Its custom-metric documentation instructs users to add a module under `src/dart_pipeline/metrics` and register metadata/fetch/process functions.
- Targeted repository searches performed on 2026-10-04 did not identify an output contract equivalent to SuRT's mandatory decomposition into `raster_coverage_fraction`, `valid_within_raster_fraction`, and `valid_data_fraction`. This is only a candidate differentiator; it is **not** evidence of first-ever priority.

Safe distinction:

- DART is broader and stronger for climate-health integration.
- SuRT is narrower: a raster-to-administrative handoff with a fail-closed JSON Schema job contract, three mandatory support quantities, an out-of-tree `module:factory` provider boundary, restricted output schema, deliberate failure/release-corruption tests, independent numerical cross-checks and complete tracked-file release-integrity gates.
- The systems can be complementary. Do not claim absence of a DART capability unless directly established from primary code/documentation.

## DHIS2 Climate Tools

Primary evidence:

- https://dhis2.org/climate/
- https://climate-tools.dhis2.org/

Supported claims:

- DHIS2 provides climate/health integration tooling and reproducible reference workflows for products such as ERA5-Land and CHIRPS.
- The initiative explicitly serves health-system settings including Africa and Asia and emphasizes local adaptation/ownership.
- SuRT must not claim to be the first LMIC/Africa climate-health integration tool.

## openEO

Primary evidence:

- https://openeo.org/documentation/

Supported claims:

- openEO provides declarative geospatial process graphs and spatial aggregation.
- Declarative geospatial configuration/process graphs are therefore not generic novelty for SuRT.

## Reproducibility/workflow infrastructure

Relevant evidence:

- Snakemake: https://snakemake.readthedocs.io/
- Wang S et al. RRE geospatial framework, 2026: https://doi.org/10.1016/j.jag.2026.105239
- Pritchard NJ, Wicenec A. reproducibility tenets/workflow signatures, 2025: https://doi.org/10.1016/j.future.2024.107684

Supported claims:

- Workflow orchestration, FAIR/RRE framing, provenance and hash-based reproducibility checks are mature research areas.
- SuRT uses Snakemake for an evidence DAG; it does not claim workflow-manager novelty.

## Array precedent

- D'Onofrio A et al. *FairFlow: A transparency-first framework for verifiable and reproducible bioinformatics*. Array, 2026. https://doi.org/10.1016/j.array.2026.101150

FairFlow is evidence that Array accepts reproducibility/framework contributions when the contract is technically defined and quantitatively evaluated. It is precedent for evaluation style, not evidence of SuRT novelty.

## SuRT-GeoHarmonizer evidence

Repository evidence used for SuRT claims:

- `R/harmonize_admin_raster.R`: arbitrary raster/polygon CLI, validation, coverage and provenance output.
- `R/zonal_area_summary.R`: polygon-overlap × raster-cell-surface-area weighting and the three support fractions.
- `config/harmonization-job.schema.json`: Draft 2020-12 fail-closed job schema with unknown fields rejected.
- `python/provider_adapters.py`: built-in local-raster adapter plus external `module:factory` loading boundary.
- `python/fixture_external_adapter.py` and `python/test_config_contract.py`: executable external-adapter proof plus malformed-plugin failures.
- `Snakefile`: account-free orchestration evidence DAG.
- `python/run_all_checks.py`: verification and negative-test aggregation.
- `python/validate_release_contract.py`: independent output-contract validation and deliberate corruptions.
- `CHECKSUMS.sha256` plus CI workflows: tracked-file integrity and clean-run evidence.
- `config/uganda-chirps-2023.json` and `R/validate_uganda_chirps_case.R`: source-derived second-country case and independent cross-check.
- `evidence/era5land/`, `evidence/modis/`, `evidence/hand/`: scoped source-pinned public-data cross-check records.

## Safe comparison language

Use **contract-first harmonization**, **fixed administrative output contract**, **mandatory spatial-support semantics**, or **integrated release-evidence boundary** rather than `unique capability`.

SuRT's defensible candidate contribution is the integration of:

1. mandatory separation of raster-footprint coverage, within-footprint finite-data support and overall valid-data support;
2. a fail-closed machine-readable harmonization job contract;
3. an out-of-tree provider extension boundary that leaves the core harmonizer/registry unchanged;
4. independent numerical/output validation, deliberate failures/corruptions, source-pinned evidence, CI and release-integrity checks.

The Array manuscript must demonstrate the value and cost of this contract empirically. No first-ever or superiority claim is currently authorized.

## Layer-aware comparison posture for Array

| Layer | Representative systems | What is prior art | SuRT positioning |
|---|---|---|---|
| Extraction primitives | exactextract(r), GDAL, terra, xagg | Exact overlap, area weighting, zonal summaries | Composes these primitives; no algorithm claim |
| Cloud/process platforms | Google Earth Engine, openEO | Catalogue-scale computation, reducers, declarative process graphs | Local bounded harmonization/output contract |
| Domain integration | DART, DHIS2 Climate Tools, AREAdata | Climate/health integration, administrative aggregation, reproducible pipelines | Narrow raster-to-admin handoff, not end-to-end health integration |
| Workflow/reproducibility | Snakemake, FAIR/RRE workflow frameworks | Orchestration, reproducibility, provenance, signatures | Uses them as release/evidence controls |
| SuRT | SuRT-GeoHarmonizer | Not a replacement for the above | Contract-first support/configuration/extension/release assurance |

This layer-aware comparison should replace any table that implies one-to-one equivalence among tools that operate at different architectural levels.