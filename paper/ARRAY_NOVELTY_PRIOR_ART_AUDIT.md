# Array novelty and prior-art audit

**Target journal:** Array  
**Audit date:** 2026-10-04  
**Status:** GO FOR ARRAY MANUSCRIPT HARDENING, RELEASE NOT AUTHORIZED  
**Scope:** SuRT-GeoHarmonizer v1.4 development branch. Internal evidence record, not submission text.

## 1. Decision

Proceed with an Array-specific manuscript and final hardening cycle.

The prior-art search does not support any claim that SuRT-GeoHarmonizer invents zonal statistics, polygon-cell overlap weighting, raster-cell area weighting, environmental or climate-health data integration, configurable geospatial workflows, plugin architectures, provenance recording, checksums, or reproducible scientific workflows. Mature systems already provide each of these capabilities, and several combine many of them.

The evidence now supports a narrower software-engineering contribution:

> SuRT-GeoHarmonizer is a contract-first administrative-raster harmonization layer that makes spatial support, transformation, extension, output semantics, numerical verification, and release identity machine-verifiable as one bounded workflow contract.

The value claim is no longer purely architectural. Three Array-specific experiments now provide direct empirical evidence for the contract: support-semantics collision, cost-of-auditability, and out-of-tree provider extension.

The remaining work is manuscript framing, adversarial claim review, exact-release validation, and journal submission preparation. No v1.4.0 DOI, tag, GitHub release, or Zenodo version is authorized by this audit.

## 2. What `novel` means for this manuscript

Array requires submissions to be novel, technically sound, and clearly presented. Novelty does not require every primitive in a system to be new. A defensible systems contribution may instead reside in a new architecture, interface or verification contract, provided the claimed difference is clearly defined and empirically evaluated.

For SuRT, novelty must therefore be expressed as a **newly evaluated integration contract**, not as new raster mathematics.

The manuscript should use research questions and controlled experiments to show what the contract adds to established geospatial primitives.

## 3. Closest prior art and claims it removes

### 3.1 DART-Pipeline / geoglue

Primary sources:

- Dasgupta A, Perez-Fernandez I, Huynh T, et al. *Scalable, open-access and multidisciplinary data integration pipeline for climate-sensitive diseases*. Wellcome Open Research. https://doi.org/10.12688/wellcomeopenres.24774.3
- https://github.com/kraemer-lab/DART-Pipeline
- https://dart-pipeline.readthedocs.io/

DART is the closest climate-health comparator. It runs locally, supports country and administrative-level configuration, downloads and processes multiple environmental and socioeconomic sources, aggregates gridded variables to administrative units, supports area- and population-weighted aggregation, records metadata/provenance, uses checksums in parts of its processing, has tests and CI, and documents custom metric/source extension.

Therefore SuRT must not claim that area weighting, provenance, checksums, extensibility, local climate-health processing, or reproducibility are individually unique.

The narrower distinction supported by current evidence is that SuRT binds a fail-closed machine-readable job schema to fixed raster-to-administrative output semantics, requires three explicit support quantities, and allows an out-of-tree `module:factory` provider adapter without editing the built-in registry or generic R harmonizer.

DART is broader than SuRT for climate-health data integration. SuRT is a smaller handoff and assurance layer that can complement DART-like systems.

### 3.2 DHIS2 Climate & Health / Climate Tools

Primary sources:

- https://dhis2.org/climate/
- https://climate-tools.dhis2.org/

DHIS2 Climate tooling already supports climate and environmental integration for health-information systems, including use in Africa and other LMIC settings. SuRT must not claim to be the first open climate-health integration tool for Africa or LMICs.

Safe distinction: SuRT operates below the HMIS/application layer. It does not ingest epidemiological records or provide a health-information platform. Its contribution is the raster-to-administrative contract.

### 3.3 AREAdata

Primary source:

- Pearse WD et al. *AREAdata: A worldwide climate dataset averaged across spatial units at different scales through time*. https://pmc.ncbi.nlm.nih.gov/articles/PMC9278028/

AREAdata automates climate aggregation across administrative units, uses fractional polygon overlap, and publishes reproducible code/data. Administrative climate aggregation plus reproducible publication is therefore not novel.

### 3.4 xagg

Primary sources:

- https://xagg.readthedocs.io/
- https://doi.org/10.21105/joss.07239

xagg performs fractional-area raster-to-polygon aggregation with optional secondary weights. Area-weighted administrative aggregation is therefore not novel.

### 3.5 exactextract / exactextractr

Primary sources:

- https://isciences.github.io/exactextract/
- https://isciences.gitlab.io/exactextractr/

These tools provide exact polygon-cell coverage fractions, weighted summaries and area weighting. SuRT uses exactextractr. Those algorithms are inherited primitives, not SuRT inventions.

### 3.6 GDAL and terra

Primary sources:

- https://gdal.org/en/stable/programs/gdal_raster_zonal_stats.html
- https://rspatial.org/terra/

GDAL and terra provide mature raster/vector operations including zonal statistics and area calculations. SuRT must not imply otherwise.

### 3.7 Google Earth Engine

Primary sources:

- https://developers.google.com/earth-engine/apidocs/ee-image-reduceregions
- https://developers.google.com/earth-engine/apidocs/ee-image-pixelarea

Earth Engine supports regional reducers, masks, CRS/scale controls and user-defined area weighting backed by a broad cloud catalogue. SuRT does not compete on catalogue breadth or computational scale.

### 3.8 openEO

Primary source:

- https://openeo.org/documentation/

openEO already provides declarative process graphs for geospatial computation. JSON or declarative execution alone is therefore not novel.

### 3.9 Reproducible geospatial workflow frameworks

Relevant recent work includes:

- Wang S et al. *Advancing sustainable geospatial analytics and geoinformatics through repeatable, reproducible, and expandable (RRE) framework and design*. International Journal of Applied Earth Observation and Geoinformation, 2026. https://doi.org/10.1016/j.jag.2026.105239
- Pritchard NJ, Wicenec A. *Formal definition and implementation of reproducibility tenets for computational workflows*. Future Generation Computer Systems, 2025. https://doi.org/10.1016/j.future.2024.107684

Workflow reproducibility, provenance and hash-based verification are established ideas and cannot be claimed as generic novelty.

### 3.10 Array precedent: FairFlow

Primary source:

- D'Onofrio A et al. *FairFlow: A transparency-first framework for verifiable and reproducible bioinformatics*. Array, 2026. https://doi.org/10.1016/j.array.2026.101150

FairFlow is relevant as an evaluation precedent for a reproducibility-centric systems paper. It is not evidence that SuRT is novel by analogy.

## 4. Contribution that survives the audit

The strongest defensible contribution is a **fixed integration and assurance contract at the raster-to-administrative handoff**.

### 4.1 Mandatory three-part spatial-support semantics

SuRT reports:

1. `raster_coverage_fraction`: fraction of polygon area intersecting the raster footprint;
2. `valid_within_raster_fraction`: fraction of the raster-covered polygon supported by finite values after masking/QA;
3. `valid_data_fraction`: overall supported polygon fraction, equal to the product of the first two quantities.

This is a mandatory output contract, not a first-ever claim.

### 4.2 Fail-closed harmonization job schema

`config/harmonization-job.schema.json` fixes provider, boundary, variable, raw-value transformation, aggregation, QA, output and provenance fields. Unknown keys fail validation. JSON Schema itself is prior art; the contribution is binding the domain semantics to an executable contract.

### 4.3 Out-of-tree provider boundary

The public `module:factory` mechanism loads a provider implementation outside the repository without changing the generic R harmonizer or built-in provider registry. Plugin architecture itself is prior art; the value is the tested decoupling around a fixed contract.

### 4.4 Executable release-evidence contract

The project combines deliberate failure injection, independent output-contract validation, source-pinned numerical cross-checks, second-country portability, multi-platform core smoke tests, tracked-file SHA-256 validation, release corruption tests, and explicit separation of software verification from environmental-product validity.

None is unique alone. The claim is the bounded integration of these controls around the same handoff contract.

## 5. Array-specific empirical evidence

### E1. Support-semantics collision - COMPLETE

`R/test_zonal_area_summary.R` contains four controlled cases with the same zonal mean of `10` but different support states:

| case | raster coverage | valid within raster | overall valid data |
|---|---:|---:|---:|
| complete | 1.0 | 1.0 | 1.00 |
| finite_gap | 1.0 | 0.5 | 0.50 |
| footprint_gap | 0.5 | 1.0 | 0.50 |
| combined_gap | 0.5 | 0.5 | 0.25 |

Local result on 2026-10-04: **18 passed, 0 failed** for the full zonal area/coverage regression suite.

Interpretation: a zonal mean alone can be identical while the evidence support differs materially. SuRT's mandatory fields expose whether loss is due to raster extent, finite-data support, or both. This does not claim that competing libraries cannot calculate comparable diagnostics when explicitly programmed.

### E2. Cost-of-auditability benchmark - COMPLETE

`R/benchmark_array_contract.R` compares a direct area-weighted mean using the same `terra`/`exactextractr` primitives against the SuRT support contract. Five repetitions were run on Microsoft Windows 11 Pro, Intel Core i7-8850H @ 2.60 GHz, approximately 15.76 GB installed RAM, R 4.6.0.

| workload | direct median | SuRT median | absolute overhead | direct R-heap peak delta | SuRT R-heap peak delta |
|---|---:|---:|---:|---:|---:|
| 10,000 cells / 16 polygons | 0.11 s | 0.14 s | +0.03 s | 22.7 MB | 26.8 MB |
| 90,000 cells / 64 polygons | 0.20 s | 0.24 s | +0.04 s | 88.9 MB | 97.6 MB |
| 360,000 cells / 144 polygons | 0.50 s | 0.57 s | +0.07 s | 144.7 MB | 150.7 MB |

All paired mean outputs were identical at the benchmark tolerance (`max_value_difference_vs_peer = 0`). R-heap measurements come from `gc()` and are **not process RSS**. Results are machine- and workload-specific and do not support a universal efficiency or speed claim.

Tracked evidence: `evidence/array/array_contract_benchmark.csv`, `evidence/array/array_contract_benchmark_summary.csv`, and `evidence/array/README.md`.

### E3. Out-of-tree extension - COMPLETE

`python/test_config_contract.py` creates a temporary adapter module physically outside the repository, loads it through `module:factory`, verifies artifact and provenance propagation, and exercises malformed-adapter and undeclared-option failure paths.

Local result on 2026-10-04: **21 passed, 0 failed**.

The experiment demonstrates zero required edits to the built-in provider registry and generic R harmonizer for the fixture provider. It does not claim plugin architectures are novel.

### E4. Additional geography/product replication - OPTIONAL

The real Uganda CHIRPS case plus Rwanda ERA5-Land, MODIS and HAND already provide multiple geography/product checks. Additional cases should be added only if they exercise a genuinely new boundary condition, not to inflate a validation count.

## 6. Performance hardening prompted by the Array audit

The first E2 prototype exposed a performance hotspot in `surt_raster_coverage_fraction()`: per-feature equal-area geometry intersections dominated runtime. The implementation was replaced by rectangular raster-footprint overlap extraction using the same exact-extraction stack, with a complete-footprint short circuit where appropriate.

Controlled large-fixture timing for that support path fell from approximately **19.3 s to 0.64 s**, while coverage results remained identical and the full zonal regression suite remained green. This is a local optimization result, not a general benchmark against other software.

## 7. Claims prohibited unless future evidence changes the audit

Do not state or imply that SuRT is:

- the first climate-health data integration pipeline;
- the first environmental-data harmonization workflow;
- the first reusable geospatial pipeline for Africa or LMICs;
- the first software to aggregate rasters to administrative units;
- the first to use exact polygon-cell overlap fractions;
- the first to perform cell-area-weighted zonal statistics;
- the first to record provenance or checksums;
- the first to use declarative configuration, plugins, or workflow orchestration;
- the first reproducible geospatial workflow;
- scientifically more accurate than DART, GEE, exactextractr, xagg, GDAL, terra, DHIS2 Climate Tools, or other comparators without a direct study designed to test that proposition; or
- an observational validation of CHIRPS, ERA5-Land, MODIS or HAND.

Preferred language: **contract-first**, **fixed contract**, **mandatory output semantics**, **integrated assurance boundary**, **release-evidence contract**.

Avoid priority or superiority language such as `first`, `unique`, `unprecedented`, `best`, or `superior`.

## 8. LMIC/Africa/tropical value

The LMIC/Africa argument is a deployment and usability rationale, not a novelty claim.

Supportable value statements are:

- the generic harmonizer accepts prepared local rasters and does not require a proprietary cloud platform;
- the account-free verification path runs without provider credentials once declared inputs are present;
- mandatory support fields prevent incomplete spatial/data support from being hidden behind a single administrative mean;
- provider logic can be replaced while preserving the harmonization/output contract;
- release artifacts are inspectable and checksum-verifiable; and
- the core implementation uses open R/Python dependencies rather than a commercial software licence.

The final benchmark now provides machine-specific runtime and R-heap measurements. Do not generalize those measurements into `lightweight`, `low-resource`, or universal efficiency claims without a dedicated deployment study.

## 9. Proposed Array research questions

**RQ1. Spatial-support semantics:** Can a fixed three-part support contract distinguish administrative summaries with identical values but materially different raster-footprint and finite-data support?

**RQ2. Computational correctness:** Does the configured workflow reproduce independently computed results across controlled fixtures and scoped public-data cases within declared tolerances?

**RQ3. Extensibility:** Can a provider be added out of tree without modifying the generic harmonization engine while retaining schema, provenance and output contracts?

**RQ4. Portability:** Does the same contract execute across non-Rwanda geometry and supported operating systems without geography-specific modifications to the generic harmonizer?

**RQ5. Computational cost:** What runtime and measured R-heap overhead is introduced by mandatory support semantics relative to a direct area-weighted mean using the same geospatial primitives?

## 10. Comparison posture

The manuscript should compare systems by layer rather than score unlike tools as interchangeable products:

- primitive/extraction: exactextract(r), GDAL, terra, xagg;
- cloud/process platforms: Google Earth Engine, openEO;
- domain integration: DART-Pipeline, DHIS2 Climate Tools, AREAdata;
- workflow/reproducibility infrastructure: Snakemake and general reproducibility frameworks;
- SuRT: contract-first raster-to-administrative harmonization and release-evidence layer.

SuRT composes mature primitives and is not presented as a replacement for broader platforms.

## 11. Stop/go rule

Proceed to final Array submission only if:

- E1, E2 and E3 remain reproducible on the intended release source tree;
- major numerical claims remain independently cross-checked;
- no unsupported priority or superiority claim enters the manuscript;
- the paper states the contribution as a bounded software contract and evaluates it through explicit research questions;
- the final manuscript and metadata use the author's current truthful affiliation;
- exact release metadata, checksums and DOI resolve to the same v1.4.0 artifact; and
- final journal/APC eligibility is verified at submission time.

## 12. Audit conclusion

**GO FOR ARRAY MANUSCRIPT HARDENING.**

The feature-level overlap with DART, DHIS2 Climate Tools, AREAdata, xagg, exactextract and general reproducibility frameworks is substantial and must remain visible in the manuscript. That overlap narrows the claim rather than invalidating the project.

The empirical evidence now demonstrates the remaining contribution more strongly: the mandatory three-part support contract distinguishes identical zonal results with different evidence support; an out-of-tree provider can be added without modifying the generic harmonizer or built-in registry; and the added support semantics carry a measured, disclosed runtime and R-heap cost on the tested workload while preserving numerical means.

The next work is Array-specific manuscript construction and adversarial claim-to-evidence review, not additional feature accumulation unless a concrete manuscript or reviewer gap requires it.
