# Array novelty and prior-art audit

**Target journal:** Array  
**Audit date:** 2026-10-04  
**Status:** GO WITH CONDITIONS for Array hardening  
**Scope:** SuRT-GeoHarmonizer v1.4 development branch. This is an internal evidence record, not submission text.

## 1. Decision

Proceed with an Array-specific hardening cycle.

The audit does **not** support a claim that SuRT-GeoHarmonizer invents zonal statistics, polygon-cell overlap weighting, raster-cell area weighting, climate-data integration, configurable geospatial workflows, provenance recording, checksums, reproducible scientific workflows, or LMIC climate-health data integration. Strong prior systems already provide each of those capabilities, and some provide several of them together.

The audit **does** support a narrower systems/software-engineering contribution that is worth testing and presenting to Array:

> SuRT-GeoHarmonizer is a contract-first administrative-raster harmonization layer that makes spatial support, transformation, extension, output semantics, numerical verification, and release identity machine-verifiable as one bounded workflow contract.

This contribution is potentially publishable because it changes the unit of assurance from an individual raster statistic or processing script to a fixed, executable handoff contract for administrative environmental covariates. However, the manuscript must demonstrate the value of that contract empirically rather than assert uniqueness.

The main evidence still required before final Array submission is:

1. a controlled **support-semantics experiment** showing that indistinguishable or near-indistinguishable zonal means can arise from materially different raster-footprint and finite-data support, while SuRT's mandatory three-part support fields expose the difference;
2. a **performance and resource benchmark** quantifying the runtime and memory cost of the contract relative to direct underlying geospatial primitives over increasing raster and polygon workloads;
3. an explicit **extension experiment** demonstrating that a third-party provider can be loaded out-of-tree without changing the core provider registry or R harmonizer, with the changed-file/LOC boundary recorded;
4. an Array-oriented manuscript that treats the Rwanda/Uganda cases as domain evaluation rather than as the definition of the software.

If those experiments fail to demonstrate practical value, the novelty claim must be reduced or the Array submission reconsidered.

## 2. What Array-level novelty means here

Array does not require every primitive used by a system to be new. A software/systems contribution can be novel through architecture, interface contracts, integration, validation methodology, or demonstrated behaviour built on established libraries. Recent Array work reinforces this interpretation. For example, FairFlow presents a reproducibility framework whose contribution is an integrated transparency and execution contract across existing languages/workflow environments rather than a new underlying bioinformatics algorithm; the paper reports cross-environment concordance as evidence. Array also publishes application-domain pipeline and framework work where novelty resides in system structure and evaluation.

For SuRT, therefore, novelty must be expressed as a **newly evaluated software contract**, not a claim to novel raster mathematics.

## 3. Closest prior art and what it removes from our novelty claim

### 3.1 DART-Pipeline / geoglue

Primary sources:

- Dasgupta A, Perez-Fernandez I, Huynh T, et al. *Scalable, open-access and multidisciplinary data integration pipeline for climate-sensitive diseases*. Wellcome Open Research. https://doi.org/10.12688/wellcomeopenres.24774.3
- https://github.com/kraemer-lab/DART-Pipeline
- https://dart-pipeline.readthedocs.io/

DART is the most important adjacent comparator because it is explicitly a climate-health pipeline, runs locally, supports country/administrative-level configuration, downloads and processes multiple environmental/socioeconomic sources, and aggregates gridded variables to administrative units.

Direct repository inspection confirms that DART already provides:

- polygon-cell fractional-overlap weighting through exactextract/geoglue;
- spherical cell-area weighting;
- area- and population-weighted aggregation;
- metadata including units, valid ranges, licences and citations;
- provenance propagation;
- SHA-256 values for processed inputs in at least parts of the ERA5 workflow;
- version locking, tests and CI;
- CLI execution;
- custom metric/source registration and documented extension mechanisms.

Therefore SuRT must **not** claim that area weighting, provenance, checksums, extensibility, local climate-health processing or reproducibility are individually unique.

Relevant distinction supported by current evidence:

- DART's convenience workflow is configured primarily through a shell configuration (`config.sh`) and its custom-metric integration documentation instructs users to add a source module under the DART source tree and register fetch/process functions.
- SuRT's harmonization job is a Draft 2020-12 JSON Schema with unknown fields rejected (`additionalProperties: false`), fixed aggregation/output semantics, an explicit minimum-valid-data gate, and an external `module:factory` adapter that is executable without changing the built-in provider registry or R harmonizer.
- Targeted inspection did not identify a DART output contract equivalent to SuRT's mandatory decomposition into `raster_coverage_fraction`, `valid_within_raster_fraction`, and `valid_data_fraction`. This is a **candidate differentiator**, not a priority or first-ever claim.

The manuscript must state that DART is broader than SuRT for climate-health data integration. SuRT is a smaller raster-to-administrative handoff layer that can complement DART-like systems.

### 3.2 DHIS2 Climate & Health / Climate Tools

Primary sources:

- https://dhis2.org/climate/
- https://climate-tools.dhis2.org/

DHIS2 Climate tooling provides reproducible reference workflows for integrating ERA5, CHIRPS and other climate/environmental data into health-information systems. It is explicitly targeted to health-system use, including deployments and partnerships in Africa and Asia, and the broader initiative emphasizes local ownership and digital sovereignty.

Therefore SuRT must **not** claim that it is the first open climate-health integration tool for Africa/LMICs, or that local climate-data integration for public-health systems is novel.

Safe distinction: SuRT operates below the HMIS/application layer and formalizes a generic raster-to-administrative output/evidence contract. It does not ingest epidemiological records, provide DHIS2 integration, or provide a health-information platform.

### 3.3 AREAdata

Primary source:

- Pearse WD et al. *AREAdata: A worldwide climate dataset averaged across spatial units at different scales through time*. https://pmc.ncbi.nlm.nih.gov/articles/PMC9278028/

AREAdata uses CDO and exactextractr to automate climate-variable aggregation across administrative units, weights cells by fractional polygon overlap, updates outputs automatically, and publishes reproducible code/data archives.

Therefore administrative climate aggregation plus an automated/reproducible publication pipeline is not novel.

Safe distinction: AREAdata is primarily a maintained climate-data product/pipeline. SuRT's candidate contribution is a generic fail-closed job/output/release contract with mandatory support diagnostics and provider extension boundaries.

### 3.4 xagg

Primary sources:

- https://xagg.readthedocs.io/
- https://doi.org/10.21105/joss.07239

xagg aggregates xarray gridded data to polygons using fractional area overlaps and optional secondary weights, with export to common formats. Its motivating use cases include climate econometrics where societal outcomes are at administrative level.

Therefore area-weighted raster-to-polygon aggregation for downstream health/social analyses is not novel.

### 3.5 exactextract / exactextractr

Primary sources:

- https://isciences.github.io/exactextract/
- https://isciences.gitlab.io/exactextractr/

These tools provide exact polygon-cell coverage fractions, weighted summaries, and area-weighted operations. SuRT itself uses exactextractr.

Therefore exact polygon extraction, coverage-fraction weighting and raster-cell area weighting are inherited primitives, not SuRT inventions.

### 3.6 GDAL, terra and general GIS tooling

Primary sources:

- https://gdal.org/en/stable/programs/gdal_raster_zonal_stats.html
- https://rspatial.org/terra/

Current GDAL and terra provide mature raster/vector operations, including zonal statistics and area calculations. SuRT must not imply otherwise.

### 3.7 Google Earth Engine

Primary sources:

- https://developers.google.com/earth-engine/apidocs/ee-image-reduceregions
- https://developers.google.com/earth-engine/apidocs/ee-image-pixelarea

Earth Engine supports regional reducers, masking, scale/CRS controls and user-defined area weighting, backed by a very broad cloud catalogue.

Therefore SuRT does not compete on data catalogue breadth or computational scale. Safe distinction: SuRT's core verification can run locally/account-free on prepared inputs, and the release contract is fixed by the project rather than constructed ad hoc by each Earth Engine user.

### 3.8 openEO and declarative geospatial processing

Primary source:

- https://openeo.org/documentation/

openEO uses declarative process graphs and supports geospatial aggregation and validation concepts. JSON/graph-based declarative execution is therefore not itself novel.

SuRT's relevant contribution is the domain-specific combination of a fail-closed harmonization schema with mandatory administrative output/support semantics and release-evidence gates.

### 3.9 Reproducible geospatial workflow frameworks

Relevant recent work includes the Repeatable, Reproducible and Expandable (RRE) geospatial framework and workflow-management research integrating FAIR principles, workflow representations, provenance and reproducible packaging. Examples include:

- Wang S et al. *Advancing sustainable geospatial analytics and geoinformatics through repeatable, reproducible, and expandable (RRE) framework and design*. International Journal of Applied Earth Observation and Geoinformation, 2026. https://doi.org/10.1016/j.jag.2026.105239
- Pritchard NJ, Wicenec A. *Formal definition and implementation of reproducibility tenets for computational workflows*. Future Generation Computer Systems, 2025. https://doi.org/10.1016/j.future.2024.107684

Therefore reproducible geospatial workflow management, provenance and hash-based reproducibility checks are not generic novelty claims available to SuRT.

### 3.10 Array precedent: FairFlow

Primary source:

- D'Onofrio A et al. *FairFlow: A transparency-first framework for verifiable and reproducible bioinformatics*. Array, 2026. https://doi.org/10.1016/j.array.2026.101150

FairFlow is strategically important because it shows that Array will publish a systems/framework contribution focused on verifiability and reproducibility when the framework is technically defined and empirically evaluated. Its reported cross-operating-system/architecture concordance demonstrates the style of evidence expected from a reproducibility-centric software paper.

This is precedent for our **evaluation strategy**, not evidence that SuRT is novel by analogy.

## 4. Candidate SuRT contribution that survives the prior-art audit

The strongest defensible contribution is not any single feature. It is a **fixed integration contract with mandatory evidence at the raster-to-administrative handoff**.

### 4.1 Mandatory three-part spatial-support semantics

Current SuRT output separates:

1. `raster_coverage_fraction`: fraction of polygon area intersecting the raster footprint;
2. `valid_within_raster_fraction`: fraction of the raster-covered polygon supported by finite raster values after masking/QA;
3. `valid_data_fraction`: overall supported polygon fraction, defined as the product of the first two quantities.

This decomposition matters because two polygons can yield the same mean while having different reasons for incomplete support. A single mean, a single count, or a generic coverage statistic can hide whether missing support is caused by raster extent or invalid/masked data.

No first-ever claim is authorized from the current search. The defensible claim is that this is a **mandatory output contract in SuRT**, and its value must be demonstrated experimentally.

### 4.2 Fail-closed harmonization job schema

`config/harmonization-job.schema.json` fixes provider, boundary, variable, raw-value transformation, aggregation, QA, output and provenance fields. Unknown top-level/nested keys fail validation. The method is fixed to surface-area-weighted mean for this contract, output CRS is fixed, and a minimum valid fraction can be required.

JSON Schema itself is prior art. The contribution is making the spatial/result semantics machine-checkable and binding them to the execution path.

### 4.3 Out-of-tree provider extension boundary

The tested `module:factory` mechanism can load an external provider without modifying the generic R harmonizer or built-in provider registry. Malformed plugin objects and undeclared options fail closed.

Plugin architectures are prior art. The candidate value is reducing coupling between provider acquisition and a fixed harmonization/output contract. This should be quantified in an extension experiment.

### 4.4 Executable release-evidence contract

The project combines:

- deliberate failure injection;
- independent output-contract validation;
- source-pinned real-data numerical cross-checks;
- second-country portability evidence;
- multi-platform core smoke tests;
- tracked-file SHA-256 manifest validation;
- release corruption tests;
- explicit distinction between software validation and environmental-product observational validity.

None is unique alone. The candidate contribution is that these controls are required as part of the same small administrative-raster release boundary.

## 5. Claims that are prohibited unless new evidence changes this audit

Do **not** state or imply that SuRT is:

- the first climate-health data integration pipeline;
- the first environmental-data harmonization workflow;
- the first reusable geospatial pipeline for Africa or LMICs;
- the first software to aggregate raster data to administrative units;
- the first to use exact polygon-cell overlap fractions;
- the first to perform cell-area-weighted zonal statistics;
- the first to record provenance or checksums;
- the first to use declarative configuration or workflow orchestration;
- the first reproducible geospatial workflow;
- more scientifically accurate than GEE, DART, exactextractr, xagg, GDAL, terra or DHIS2 Climate Tools without a direct benchmark designed to test that claim;
- observational validation of CHIRPS, ERA5-Land, MODIS or HAND.

Use terms such as **contract-first**, **fixed contract**, **mandatory output semantics**, **integrated assurance boundary**, or **release-evidence contract**. Avoid `unique`, `first`, `unprecedented`, `best`, `superior` and comparable priority claims.

## 6. LMIC/Africa/tropical value: what is supportable

The LMIC/Africa argument is a **deployment and usability rationale**, not a novelty claim.

The context is real: African climate/health work is affected by uneven observing networks, heterogeneous environmental products, infrastructure constraints and limited specialist capacity. Rwanda itself has active national work integrating climate data into DHIS2. DART and DHIS2 Climate initiatives already respond to several of these challenges, so SuRT must not claim ownership of this problem space.

Potential SuRT value that can be demonstrated rather than asserted:

- the core harmonizer accepts a prepared local raster and does not require a proprietary cloud platform;
- account-free verification can run locally without provider credentials;
- mandatory support fractions expose incomplete spatial/data support rather than silently treating all administrative means as equally supported;
- provider logic can be replaced while preserving the same output contract;
- release artifacts are portable, inspectable and checksum-verifiable;
- open R/Python dependencies permit institutional reuse without a commercial licence.

Before claiming suitability for constrained computing environments, measure runtime and peak memory on a documented commodity machine. Do not use `lightweight`, `low-resource`, `efficient` or similar language without those measurements.

## 7. Experiments required for immutable value evidence

### E1. Support-semantics collision experiment — required

Construct controlled polygons/raster cases that deliberately produce the same or nearly the same zonal mean while differing in support:

- A: full raster footprint, partial finite data;
- B: partial raster footprint, all in-footprint data finite;
- C: partial raster footprint plus partial finite data;
- D: complete support control.

Report the mean and all three support fractions. The experiment succeeds if cases can share the same mean while the mandatory support fields correctly distinguish why evidence is incomplete.

This experiment demonstrates the practical information value of the contract. It must not claim competing libraries cannot calculate comparable diagnostics when explicitly programmed.

### E2. Cost-of-auditability benchmark — required

Benchmark representative workloads across increasing:

- raster dimensions/cell counts;
- polygon counts/complexity;
- finite-data missingness patterns.

Capture wall-clock time and peak memory for:

1. a direct underlying spatial-summary baseline;
2. SuRT harmonization with support/provenance/output validation;
3. full configured run where meaningful.

Report absolute performance and incremental overhead. The goal is not to prove SuRT is fastest; the goal is to quantify the computational price of its additional guarantees.

### E3. Out-of-tree extension experiment — required

Use a provider fixture outside the built-in provider registry. Record:

- files/LOC added outside core;
- files/LOC modified in the generic harmonizer and provider registry (target: zero);
- successful artifact preparation and provenance propagation;
- fail-closed behaviour for malformed adapter and undeclared options.

### E4. Geographic/provider replication — desirable

The Uganda CHIRPS case already provides one source-derived second-country check. If inexpensive and scientifically appropriate, add another geography/product only if it tests a genuinely different boundary condition. Do not add countries merely to inflate a count.

## 8. Proposed Array research questions

The Array manuscript should be organized around testable software questions rather than a product description:

**RQ1. Spatial-support semantics:** Can a fixed three-part support contract distinguish administrative summaries that have similar values but materially different raster-footprint and finite-data support?

**RQ2. Reproducibility/correctness:** Does the configured workflow reproduce independently computed results across controlled fixtures and scoped public-data cases within declared numerical tolerances?

**RQ3. Extensibility:** Can a provider be added out-of-tree without modifying the generic harmonization engine while retaining schema, provenance and output contracts?

**RQ4. Portability:** Does the same contract execute across non-Rwanda geometry and supported operating systems without geography-specific modifications to the core harmonizer?

**RQ5. Computational cost:** What runtime and memory overhead is introduced by the added support, validation, provenance and release-evidence controls?

These questions are stronger than a claim that SuRT is merely `reproducible` or `generalizable`.

## 9. Comparison posture for the Array paper

A fair comparator table should distinguish tool layers rather than score all systems as if they solve identical problems:

- **Primitive/extraction:** exactextract(r), GDAL, terra, xagg.
- **Cloud/process platform:** Google Earth Engine, openEO.
- **Domain integration:** DART-Pipeline, DHIS2 Climate Tools, AREAdata.
- **Workflow/reproducibility infrastructure:** Snakemake and general FAIR/RRE workflow frameworks.
- **SuRT:** contract-first raster-to-administrative harmonization and release-evidence layer.

The manuscript should explicitly state that SuRT composes mature primitives and does not attempt to replace broader platforms.

## 10. Stop/go rule before final submission

Proceed to Array submission only if all of the following are true:

- E1 demonstrates information that a zonal mean alone does not expose;
- E2 quantifies acceptable resource/latency cost without hiding unfavourable results;
- E3 proves the intended decoupled extension boundary;
- all major numerical claims remain independently cross-checked;
- the paper makes no unsupported priority/superiority claim;
- the contribution is stated as a bounded software contract and evaluated through explicit research questions;
- final code/manuscript/release metadata identify the same exact v1.4.0 artifact.

If these conditions fail, do not manufacture novelty. Reframe the contribution or reconsider the target journal.

## 11. Audit conclusion

**GO WITH CONDITIONS.**

The prior-art search finds substantial overlap at the feature level, especially with DART, DHIS2 Climate Tools, AREAdata, xagg, exactextract and general reproducibility frameworks. That overlap is a reason to narrow the claim, not to abandon the project.

The remaining defensible research contribution is the **mandatory, machine-verifiable integration contract at the raster-to-administrative handoff**, especially the separation of spatial support semantics and the coupling of that contract to fail-closed configuration, out-of-tree extension, independent numerical checks and exact release evidence.

The next engineering work should be evidence generation for E1-E3 and performance measurement, not additional feature accumulation.