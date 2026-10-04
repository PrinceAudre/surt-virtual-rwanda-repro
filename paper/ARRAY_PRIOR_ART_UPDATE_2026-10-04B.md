# Array prior-art delta audit B: support semantics and assurance systems

**Target journal:** Array  
**Date:** 2026-10-04  
**Status:** active novelty-control record; release not authorized

## Purpose

This second October 2026 delta records prior art found in a targeted search for systems that could invalidate or narrow the remaining SuRT-GeoHarmonizer contribution. The search focused on two questions:

1. Do current raster-to-polygon or raster-to-grid systems already report validity/coverage information alongside zonal values?
2. Do current geospatial systems already integrate validation, provenance and reproducibility controls strongly enough that those controls cannot support a novelty claim by themselves?

This record supplements `ARRAY_NOVELTY_PRIOR_ART_AUDIT.md` and `ARRAY_PRIOR_ART_UPDATE_2026-10-04.md`. It is not evidence of exhaustive world-wide novelty.

## 1. Development Data Lab Urban Growth Center

Primary source: https://cities.devdatalab.org/docs/datasets/ghsl-builtup

The Development Data Lab Urban Growth Center documentation for GHSL Built-up Zonal Statistics states that source raster values are summarized within released city/ADM polygons with coverage-fraction weighting. The published schema pairs multiple area-weighted metrics with metric-specific fields such as `built_up_surface_valid_coverage_share`, described as the share of zone area covered by valid pixels. The documentation explicitly instructs users to keep each metric with its corresponding validity-coverage share and states that a share of zero means the raster was absent or no valid pixel fell inside the zone.

**Consequence for SuRT:** a zonal value accompanied by an overall valid-area/valid-pixel coverage share is established current practice. SuRT must not claim novelty for pairing a zonal estimate with a valid-data fraction. The RQ1 collision experiment has a narrower role: it demonstrates that one overall support share can be identical when support loss arises from different causes, whereas SuRT's fixed output contract separately reports grid-extent support and finite/QA-accepted support within that grid-covered area.

## 2. GeoBrix raster-grid coverage modes

Primary sources:

- https://databrickslabs.github.io/geobrix/docs/release-notes/
- https://databrickslabs.github.io/geobrix/docs/api/raster-functions/

GeoBrix v0.5.1 documents raster-to-grid functions with `coverage=complete` and `coverage=sparse` behavior. Under complete coverage, every grid cell whose area overlaps the raster extent is returned, including cells whose raster content is entirely NoData; cells with valid pixels carry a measure while extent-covered all-NoData cells carry a null measure (or zero for count). Its raster API also exposes bounding-box/extent operations and valid non-NoData pixel counts.

**Consequence for SuRT:** the conceptual distinction between raster-extent support and valid-pixel support is not unique to SuRT. SuRT must not claim to have invented that distinction. The narrower contribution remains its per-administrative-polygon normalized support factors, explicit product invariant, fixed output semantics, and integration of those semantics with provider, validation and release-evidence contracts.

## 3. Geospatial Agentic Services

Peer-reviewed source: *Geospatial Agentic Services: a framework for interoperable geospatial intelligence*. International Journal of Digital Earth (2026). https://doi.org/10.1080/19475683.2026.2738374

The GAS framework integrates geospatial validation, provenance, reproducibility and governance. Its current implementation records structured execution traces and packages outputs, validation records, provenance and workflow traces into reproducibility bundles, including machine-readable JSON. Validation examples include CRS consistency, schema compatibility, geometry validity, topology, raster alignment, extent matching and missing-data checks.

**Consequence for SuRT:** integrated geospatial validation, provenance and reproducibility bundles are established research-software architecture. SuRT cannot rely on those concepts alone as novelty. Its release-evidence controls are part of an assurance package around a narrower raster-to-administrative handoff.

## 4. Enterprise Spatial Data Provenance Knowledge Infrastructure

Peer-reviewed source: Sadiq MA, Langat PK, Neupane A. *Enterprise Spatial Data Provenance Knowledge Infrastructure*. ISPRS International Journal of Geo-Information. 2026;15(5):182. https://doi.org/10.3390/ijgi15050182

ESDPKI proposes a standards-aligned geospatial provenance architecture with capture, semantic normalization, validation, queryable lineage, catalogue linkage and governance. It includes validation-gated ingestion and makes spatial operations, parameters, geometry and CRS context machine-actionable.

**Consequence for SuRT:** machine-actionable geospatial provenance and validation-gated architecture are established. They are useful assurance controls but not priority claims for SuRT.

## 5. Targeted search for the exact SuRT support decomposition

Search terms included combinations of `raster extent coverage`, `valid coverage`, `valid data fraction`, `NoData`, `polygon`, `zonal statistics`, `grid coverage`, and `valid pixels`. The search recovered systems that:

- report polygon coverage or valid-data shares;
- distinguish raster extent from NoData/valid pixels at raster or grid-cell level;
- compute fractional overlap and weighted zonal summaries; and
- reject or flag inadequate raster support.

The reviewed sources did **not** establish an exact published match for SuRT's complete per-polygon interface in which:

- `raster_coverage_fraction` is polygon support by the rectangular raster grid extent;
- `valid_within_raster_fraction` is finite/QA-accepted support conditional on that grid-covered area;
- `valid_data_fraction` is emitted as the explicit product of the first two and is independently checked as an invariant; and
- those semantics are mandatory within the same provider/configuration/output/release assurance contract.

This is a search result, not proof of uniqueness. Another implementation may exist or may be readily constructed from established geospatial primitives. Therefore the manuscript must continue to avoid `first`, `unique`, `only`, `unprecedented` and equivalent priority language.

## 6. Updated novelty boundary

The strongest defensible position after this search is narrower than before:

- **not novel:** fractional polygon overlap, surface-area weighting, zonal statistics, valid-data percentages, coverage reporting, raster footprints, separating extent-covered from NoData cells as a concept, fail-closed coverage thresholds, configuration schemas, provider plugins, workflow orchestration, provenance, reproducibility bundles, checksums or CI in isolation;
- **evaluated contribution:** one bounded raster-to-administrative handoff in which the two causes of support loss are normalized and mandatory at polygon level, their overall product is explicit and machine-checkable, provider preparation is decoupled from generic harmonization, scoped numerical results are independently cross-checked, negative paths are executable, and the release identity is integrity-gated.

The novelty argument therefore rests on **integrated interface semantics plus empirical evaluation**, not on ownership of any component technique.

## 7. Decision

**GO FOR ARRAY HARDENING remains justified, but priority language remains prohibited.**

The new evidence materially narrows the contribution but does not collapse it. Development Data Lab provides a strong real-world comparator for value-plus-validity-share outputs, and GeoBrix demonstrates that extent-versus-valid support is itself an established distinction. Those findings make the RQ1 result more precise: SuRT's claim is not that coverage is new, but that its fixed administrative-output decomposition preserves causal information that a single overall validity share cannot preserve in the controlled collision fixture.

Before submission, the Array manuscript and automated novelty gate must explicitly acknowledge this boundary.