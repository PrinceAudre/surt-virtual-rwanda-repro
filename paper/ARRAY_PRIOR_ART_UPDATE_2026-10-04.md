# Array prior-art delta audit: October 2026

**Target journal:** Array  
**Date:** 2026-10-04  
**Status:** active novelty-control record; release not authorized; manuscript integration of the newest findings is required before submission

## Purpose

This delta audit records material prior art found after the first Array novelty review. It narrows the admissible novelty claim. It must be read with `ARRAY_NOVELTY_PRIOR_ART_AUDIT.md` and `ARRAY_CLAIM_EVIDENCE_MATRIX.md`.

## 1. GDAL 3.12+ raster zonal statistics

Primary source: https://gdal.org/en/stable/programs/gdal_raster_zonal_stats.html

Current GDAL documentation states that `gdal raster zonal-stats` was added in GDAL 3.12. For polygon zones it supports fractional pixel inclusion, cell-coverage fractions, weighted statistics using a second raster, and statistics including `count`, `coverage`, `mean`, and `weighted_mean`.

**Consequence for SuRT:** exact/fractional polygon overlap, coverage information, weighted zonal summaries, and a command-line zonal-statistics interface are established capabilities. SuRT must not claim novelty for any of those primitives.

## 2. spatcovar 0.1.0

Primary package record: https://cran.r-project.org/package=spatcovar  
Package DOI: https://doi.org/10.32614/CRAN.package.spatcovar

`spatcovar` version 0.1.0 was published on 2026-09-08. Its documented scope includes a consistent interface for spatial covariate construction from polygon data, raster zonal summaries, CRS validation, geometry repair, unit conversion, row preservation, and standardized missing-value semantics. It builds on `exactextractr`, `sf`, `terra`, and `units`.

**Consequence for SuRT:** a consistent polygon-covariate interface, robust geometry/CRS handling, raster summaries, and standardized missing-value behavior are not sufficient novelty claims by themselves.

## 3. DHIS2 Open Climate Service and Climate Tools

Primary sources:

- https://dhis2.org/introducing-open-climate-service/
- https://open-climate-service.dhis2.org/
- https://climate-tools.dhis2.org/

The 2026 Open Climate Service materially strengthens the closest public-health implementation context. It can ingest sources including CHIRPS, ERA5-Land and WorldPop, scope storage to a country or region, update datasets on a schedule, summarize data by administrative or health-service area, produce DHIS2- and Chap-ready outputs, accept national or project-specific datasets, and run locally, in the cloud, or on national infrastructure. The broader DHIS2 Climate tooling already documents workflows for harmonizing environmental data with administrative health-information units.

**Consequence for SuRT:** open-source climate-data integration, administrative or health-service-area summarization, local or national deployment, provider extensibility, and an Africa/LMIC health rationale are established capabilities and deployment goals. SuRT must not claim priority for climate-health harmonization, local deployment, or use in African public-health settings. Its contribution must remain below the health-information-system layer and be demonstrated as a specific handoff and assurance contract.

## 4. QFlowCrate and geospatial provenance

Peer-reviewed source: Rademaker A, Koukouraki E, Pondi B. *QFlowCrate: A QGIS Plugin for Workflow Documentation and Provenance Capture to Enhance Geoscientific Reproducibility*. Journal of Open Research Software. 2026;14:44. https://doi.org/10.5334/jors.704

QFlowCrate records geospatial workflow inputs, processing steps, parameters and symbology and exports standards-compliant RO-Crates using a modular architecture. It is explicitly designed around geospatial provenance, reproducibility, reuse and FAIR-oriented packaging.

**Consequence for SuRT:** provenance capture, reproducibility metadata, FAIR-oriented workflow packaging, modular geospatial workflow architecture and cross-platform reproducibility controls are established research-software contributions. SuRT cannot use provenance or reproducibility packaging alone as novelty.

## 5. Zonify and current coverage reporting

Primary source: https://plugins.qgis.org/plugins/Zonify/  
Project documentation: https://github.com/dragosgontariu/zonify/blob/main/docs/USER_GUIDE.md

Zonify 1.0.0 is a 2026 QGIS plugin for batch zonal statistics. Its documentation reports `Count` and `Coverage`, describes coverage as the percentage of a polygon containing valid raster data, excludes NoData from calculations, and documents geometric coverage for partial pixels.

**Consequence for SuRT:** reporting a polygon coverage percentage alongside zonal statistics is not novel. The support-collision experiment therefore cannot be framed as proving that other software lacks coverage diagnostics. Its narrower evidentiary role is to show the information preserved when SuRT requires a fixed three-part decomposition that separates raster-footprint support from finite accepted support.

## 6. mbg and public-health spatial aggregation

Primary sources:

- https://cran.r-project.org/package=mbg
- https://henryspatialanalysis.github.io/mbg/

`mbg` 1.2.0, published in 2026, provides model-based geostatistics and functions to aggregate raster estimates and predictive draws to polygon regions while preserving uncertainty. Its documented workflow includes administrative-boundary aggregation, fractional aggregation and optional weighting rasters. The package acknowledges the Demographic and Health Surveys Program geospatial analysis community among its influences/contributors.

**Consequence for SuRT:** raster-to-administrative aggregation in health/geostatistical workflows, validation wrappers, fractional aggregation and uncertainty-aware polygon summaries are established. SuRT must not frame administrative raster covariates for health as a new software category.

## 7. Additional landscape controls

### 7.1. HE2AT environmental exposure ecosystem

Primary source: https://portal.placealert.org/heat-catalogue/

The HE2AT environmental-exposure catalogue documents multi-country Sub-Saharan African linkage of climate and environmental products with maternal and newborn health research. It demonstrates that African climate-health exposure integration is already an active, technically sophisticated field.

**Consequence for SuRT:** Africa, tropical settings and public health are application rationales, not novelty claims.

### 7.2. CTreesKit

Primary project source: https://ctrees.org/news/introducing-ctreeskit

CTreesKit is an open-source Python effort for efficient large-scale environmental zonal statistics. The available source is project documentation rather than a peer-reviewed software paper, so it is retained as landscape evidence rather than a central manuscript comparator.

**Consequence for SuRT:** large-scale zonal-statistics processing and engineering for environmental rasters are not themselves novelty.

### 7.3. Machine-readable data contracts

Primary technical reference: https://docs.datacontract.com/

Machine-readable, versioned data contracts that encode schema, semantics and quality expectations and are linted or tested in CI are established data-engineering practice.

**Consequence for SuRT:** the terms `data contract`, `machine-readable contract`, JSON Schema, CI enforcement and fail-closed schema validation are not priority claims. The defensible contribution is the domain-specific content and evaluated integration of SuRT's raster-to-administrative contract, not the generic concept of a data contract.

## 8. Current novelty boundary after the expanded search

The expanded search removes several broad claims but does not invalidate the central study if the manuscript remains narrow and empirical.

The evidence supports saying that SuRT-GeoHarmonizer **defines and evaluates** an integrated raster-to-administrative assurance contract in which:

- `raster_coverage_fraction` reports polygon support by the raster footprint;
- `valid_within_raster_fraction` reports finite accepted support within that footprint;
- `valid_data_fraction` reports overall supported polygon area and is algebraically constrained to the product of the first two values;
- fail-closed job semantics bind provider, transformation, QA, aggregation, output and provenance declarations;
- an out-of-tree provider boundary is tested without modification of the built-in registry or generic harmonizer;
- scoped numerical calculations are independently cross-checked rather than merely rerun through the same implementation;
- failure injection and release-contract corruption are tested; and
- exact tracked-file identity is checked as release evidence.

None of those component ideas is claimed to be unique. The Array contribution is the evaluated integration of these controls around one bounded scientific-data handoff and the empirical demonstration of what that integration exposes and costs.

The RQ1 collision experiment is evidence of **information added by the fixed decomposition**, not evidence of algorithmic exclusivity. The RQ5 benchmark is evidence of **measured implementation cost on one declared system**, not evidence of performance superiority.

## 9. Claims now explicitly prohibited

In addition to the prohibitions in the main novelty audit, do not state or imply that SuRT is the first or only system to provide:

- data contracts or machine-verifiable data contracts;
- coverage reporting or valid-data coverage;
- geospatial provenance or FAIR/reproducible workflow packaging;
- open-source climate-health data integration;
- administrative or health-service-area environmental summaries;
- local/national climate-data infrastructure;
- African or LMIC climate-health data integration;
- health-oriented raster-to-polygon aggregation; or
- scalable environmental zonal statistics.

## 10. Updated decision

**GO FOR ARRAY HARDENING remains justified, with a narrower novelty statement.**

The search has repeatedly found strong prior art for every individual primitive. That is useful rather than fatal: it tells us exactly what cannot be claimed. The remaining manuscript must stand or fall on the evidence for the integrated assurance boundary, especially the three-part support semantics, fail-closed handoff contract, external-provider decoupling, independent numerical checks and release-evidence gates.

Before submission, the newest findings in this delta, particularly Open Climate Service, QFlowCrate, current coverage-reporting software, `mbg`, and the generic data-contract literature, must be reflected in the manuscript's novelty boundary or explicitly judged non-material with a recorded reason. No priority wording is permitted merely because an exact integrated match was not found.