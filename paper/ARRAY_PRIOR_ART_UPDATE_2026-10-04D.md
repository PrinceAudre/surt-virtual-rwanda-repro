# Array prior-art delta audit D: current zonal interfaces and epidemiological preprocessing

**Target journal:** Array  
**Date:** 2026-10-04  
**Status:** active novelty-control record; release not authorized

## Purpose

This fourth October 2026 delta tests the remaining SuRT-GeoHarmonizer contribution against very recent and directly adjacent software. The question is not whether other tools can perform the same raster mathematics. They can. The question is whether the proposed Array contribution survives after accounting for current zonal-statistics interfaces, robust polygon-covariate wrappers and epidemiological climate-preprocessing workflows.

The search further narrows the paper but does not collapse the five research questions. It strengthens the rule that SuRT must be presented as an evaluated integration/assurance contract rather than as a new zonal-statistics method, a new public-health preprocessing category, or a uniquely African/LMIC tool.

## 1. GDAL 3.12 zonal statistics

Primary documentation: https://gdal.org/en/stable/programs/gdal_raster_zonal_stats.html  
Release announcement: GDAL 3.12.0, 7 November 2025.

`gdal raster zonal-stats`, added in GDAL 3.12, supports polygon zones, fractional pixel inclusion, per-cell coverage arrays, coverage-weighted statistics and optional secondary weighting rasters. The command can also run as part of a GDAL pipeline.

**Consequence for SuRT:** fractional overlap, coverage arrays, weighted zonal means and composable command-line zonal processing are mature upstream capabilities. None is a SuRT novelty claim. The SuRT contribution must concern the mandatory administrative-output contract and its evaluated information/assurance properties, not the underlying computation.

## 2. `spatcovar` 0.1.0

Primary documentation: CRAN package `spatcovar` 0.1.0, published 8 September 2026, https://CRAN.R-project.org/package=spatcovar

`spatcovar` provides a consistent polygon-first interface for constructing spatial covariates. Its raster function uses `exactextractr` for coverage-fraction-weighted zonal summaries and the package handles CRS validation, geometry repair, unit conversion, row preservation and standardized missing-value semantics.

**Consequence for SuRT:** a robust reusable wrapper around established geospatial primitives, including CRS/geometry/missing-value handling, is not itself a publishable novelty boundary for SuRT. Array claims must remain tied to the explicit support-factor handoff, tested provider boundary, independent numerical evidence and release-integrity controls.

## 3. Climate-CAFE ERA5 administrative aggregation

Primary repository: https://github.com/Climate-CAFE/era5-daily-heat-aggregation  
Python companion: https://github.com/Climate-CAFE/era5-daily-heat-aggregation-python

Climate-CAFE publishes R and Python workflows that download ERA5-Land, derive heat metrics and aggregate them across administrative boundaries for epidemiological and sociodemographic analyses, using Kenya as a demonstration area. The repository documents computational scale, including multi-year storage, annual aggregation time and high memory use on a computing cluster.

**Consequence for SuRT:** ERA5-to-administrative preprocessing for health research, African demonstration, reproducible scripts and computational benchmarking all predate this submission. The Rwanda/health setting and the existence of a benchmark cannot carry novelty by themselves.

## 4. `stagg` and polygon support weights

Peer-reviewed source: Carleton et al., *stagg: A data pre-processing R package for climate impacts analysis*, Environmental Modelling & Software 183 (2025) 106202. https://doi.org/10.1016/j.envsoft.2024.106202

`stagg::overlay_weights()` calculates the share of each administrative polygon falling within each climate-grid cell and normalizes weights for later aggregation. It can also incorporate secondary population or cropland weights.

**Consequence for SuRT:** explicit polygon-to-grid area shares and weighted climate aggregation are established software concepts. SuRT's `raster_coverage_fraction` cannot be presented as inventing polygon-grid support accounting.

## 5. `geoglue` and missing-data-aware geospatial processing

Primary documentation: https://geoglue.readthedocs.io/

`geoglue`, used by DART-Pipeline, targets geospatial preparation for epidemiology and public health. Its code includes bounding-box coverage calculations and resampling logic that explicitly constructs non-NaN masks to prevent missing values spreading through interpolation. Its tutorials expose raster NoData metadata and weighted zonal-statistics workflows.

**Consequence for SuRT:** handling raster support, NoData and health-oriented zonal aggregation is established adjacent practice. SuRT may claim only that its output contract requires a particular decomposition and invariant and that the information value of that decomposition is evaluated in controlled fixtures.

## 6. Exact-extraction libraries remain stronger computational baselines

Primary documentation:

- https://isciences.github.io/exactextract/
- https://isciences.gitlab.io/exactextractr/

The exact-extraction libraries expose cell coverage fractions, weighted statistics, counts, custom summaries and explicit NoData handling. They can be composed to calculate many or all quantities required by SuRT.

**Consequence for SuRT:** the Array manuscript must continue to state that equivalent component capabilities can be assembled in other geospatial stacks. The claim is not exclusivity of capability; it is the behavior of one fixed, machine-checked handoff and the empirical evidence attached to it.

## 7. Novelty survival test after this delta

The search now contains direct collisions for every broad framing that would otherwise be tempting:

- zonal statistics and fractional overlap: exactextract(r), GDAL, terra, xagg;
- reusable polygon-covariate interfaces: `spatcovar`;
- climate-to-administrative preprocessing: `stagg`, Climate Econometrics Toolkit, AREAdata;
- health/epidemiological geospatial aggregation: DART-Pipeline, `geoglue`, Climate-CAFE, IPUMS Terra;
- African climate services: CDT and DHIS2 Climate & Health/Open Climate Service;
- workflow/reproducibility/provenance: Snakemake, QFlowCrate, GAS, ESDPKI and related systems;
- contract-driven geospatial computing: AutoGIS and broader data-contract work.

The remaining defensible contribution is therefore deliberately narrower:

> SuRT-GeoHarmonizer defines and evaluates a fixed raster-to-administrative output/assurance contract in which rectangular grid support and finite/QA-accepted support are separately emitted, their overall product is invariant-checked, invalid configuration and outputs fail closed, provider extension is tested out of tree, scoped real-data outputs are independently cross-checked, and exact release artifacts are integrity-gated.

This is an **integration and evaluation contribution**, not a priority claim. The prior-art search did not establish an exact published match for the complete mandatory contract, but absence of an exact match in a targeted search is **not proof of uniqueness**.

## 8. Array decision

**GO FOR ARRAY HARDENING remains justified, but only under the bounded contribution above.**

The project should stop rather than expand the novelty language if later prior art establishes the same mandatory support decomposition plus comparable fail-closed and release-assurance semantics as an already evaluated package. Until then, the correct strategy is to quantify what information the contract preserves, what coupling it removes, what numerical behavior it reproduces and what computational overhead it adds.
