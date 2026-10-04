# Array prior-art delta audit: October 2026

**Target journal:** Array  
**Date:** 2026-10-04  
**Status:** active novelty-control record; release not authorized

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

## 3. Current novelty boundary after this update

The search still supports a bounded systems contribution, but only at the level of the evaluated integration contract. The manuscript may claim that SuRT-GeoHarmonizer **defines and evaluates** a mandatory three-part support decomposition and binds it to fail-closed configuration, an out-of-tree provider boundary, independent numerical evidence, and exact release-integrity controls.

It may **not** claim that competing software cannot compute equivalent coverage quantities. `exactextractr`, GDAL, terra, xagg and related tools expose sufficient primitives for users to construct many such diagnostics. The defensible distinction is that SuRT makes the following quantities mandatory, algebraically linked, validated output semantics:

- `raster_coverage_fraction`: fraction of polygon area inside the raster footprint;
- `valid_within_raster_fraction`: finite accepted support within the raster-covered portion;
- `valid_data_fraction`: overall supported polygon fraction, constrained to equal the product of the first two quantities.

The RQ1 collision experiment is therefore evidence of **information added by the fixed decomposition**, not evidence of algorithmic exclusivity.

## 4. Reproducibility and workflow novelty boundary

Workflow orchestration, provenance, CI, checksums, FAIR-oriented packaging and reproducible geospatial execution are also established prior art. They remain valuable engineering controls but are not individually novel. SuRT's claim is limited to their integration as release evidence for the same raster-to-administrative handoff contract.

## 5. Updated decision

**GO FOR ARRAY HARDENING remains justified.** The new prior art narrows the wording but does not invalidate the central contribution because the manuscript already frames SuRT as an evaluated contract rather than a new geospatial algorithm.

Before submission, the main Array manuscript must explicitly acknowledge both current GDAL zonal-statistics capabilities and `spatcovar`, and the automated Array manuscript gate must prevent regression to generic coverage, zonal-statistics, missing-data, reproducibility, or Africa/LMIC priority claims.
