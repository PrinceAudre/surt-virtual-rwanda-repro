# SuRT-GeoHarmonizer: A contract-first workflow for verifiable raster-to-administrative data harmonization

**TUYISHIME AUDRE PRINCE**

School of Public Health, College of Medicine and Health Sciences, University of Rwanda, Kigali, Rwanda

ORCID: 0009-0002-0799-3140

Corresponding author: TUYISHIME AUDRE PRINCE, priplee@gmail.com

**Target journal:** Array  
**Status:** Development manuscript for v1.4.0. Do not submit until the exact release artifact is frozen and the final review protocol is closed.

## Abstract

Administrative analyses in public health, environmental science, ecology and related fields routinely convert gridded environmental products into polygon-level covariates. The numerical reduction is mature, but the handoff can obscure whether a reported value represents the whole administrative unit, only the part intersecting the raster grid extent, or only finite values remaining after provider-specific quality control. We present SuRT-GeoHarmonizer, an open R and Python workflow that treats this raster-to-administrative handoff as a machine-verifiable software contract. The contract combines surface-area-weighted polygon extraction, explicit grid-coverage and finite-data support semantics, fail-closed declarative jobs, an out-of-tree provider extension boundary, provenance-labelled outputs, independent numerical cross-checks and release-integrity gates. We evaluate five research questions. First, four controlled fixtures all produced the same zonal mean of 10. A mean-only handoff therefore produced one unique interface signature; adding only overall valid-data support produced three because raster-grid loss and finite-data loss can yield the same total support; reporting the two causal support factors plus their explicit overall product produced four signatures. Second, source-pinned public-data cases agreed with independent calculations: Uganda CHIRPS 2023 differed by 0.000016 mm, Nyarugenge ERA5-Land 2023 by approximately 0.000003 °C, MOD13A3 agreed under the declared two-decimal output contract, and Rubavu HAND differed by less than 1e-9 percentage points. Third, a provider module located outside the repository loaded through the public adapter interface without modification of the generic harmonizer or built-in provider registry, while malformed adapters failed closed. Fourth, the same core contract is exercised on Rwanda and Uganda geometry and passes a separate core smoke matrix on Ubuntu, Windows and macOS, with full provider acquisition deliberately excluded from the cross-platform claim. Fifth, on one documented Windows workstation, the mandatory support contract added median wall-clock costs of 0.03, 0.04 and 0.07 s over a direct area-weighted mean for workloads of 10,000/16, 90,000/64 and 360,000/144 raster cells/polygons, with identical paired means. SuRT-GeoHarmonizer does not introduce a new zonal-statistics algorithm. Its contribution is the evaluated integration and assurance contract around a common scientific-data handoff.

**Keywords:** research software; geospatial computing; zonal statistics; environmental data; reproducibility; provenance; climate and health; software verification

## 1. Introduction

Environmental covariates are increasingly combined with administrative health, demographic, ecological and socioeconomic data. Precipitation, temperature, vegetation indices, terrain descriptors and other environmental variables usually originate as rasters, whereas routine public-health and policy data are frequently reported for districts, provinces, catchments or other polygons. Converting one representation into the other is therefore a common analytical step.

The underlying geospatial operations are well established. `exactextractr`, `exactextract`, `terra`, GDAL, xagg and cloud platforms such as Google Earth Engine provide mature mechanisms for polygon extraction, fractional pixel coverage, area weighting and related raster operations [1-5]. Broader systems already automate environmental and climate-data integration. DART-Pipeline integrates epidemiological, socioeconomic, climatic and environmental data for climate-sensitive-disease analyses [6]. AREAdata publishes climate variables averaged over administrative units [7]. DHIS2 Climate Tools, the DHIS2 Climate App and the 2026 Open Climate Service integrate or serve climate and environmental products for health and other operational systems [8,9,18]. These systems remove any defensible claim that raster-to-polygon aggregation, climate-health data integration, reproducible geospatial workflows, declarative execution, local climate infrastructure or provenance are individually new.

Coverage diagnostics are also established. Current GDAL exposes coverage arrays and weighted zonal summaries [4]; `exactextractr` exposes polygon-cell coverage and non-NA counts [1]; STAC raster-band metadata standardizes `valid_percent` [21]; valid-data footprint software can derive geometry from non-NoData raster support [22]; and documented modelling workflows already fail when required raster coverage falls below a configured polygon threshold [23]. Development Data Lab's Urban Growth Center pairs area-weighted polygon summaries with metric-specific `valid_coverage_share` fields [24]. GeoBrix distinguishes raster-extent overlap from valid-pixel sparsity in its raster-to-grid coverage modes, returning extent-covered cells even when their raster content is entirely NoData under complete coverage [25]. A novelty claim based on reporting coverage, identifying NoData, deriving a footprint, pairing a value with one valid-data share, distinguishing extent-covered from NoData cells as a concept, or rejecting low coverage would therefore be unsustainable.

A narrower problem remains important. A polygon-level value can be numerically valid while the evidence supporting that value is incomplete or ambiguous. A rectangular raster grid can intersect only part of a polygon. Within the grid-covered area, provider-specific quality control, no-data values or masking can remove additional cells. A single overall valid-data percentage reports the magnitude of remaining support but not why support was lost. At the same time, a reusable pipeline needs a clear boundary between source-specific preparation and generic harmonization, and a release needs evidence that its declared configuration, output semantics and exact files are internally consistent.

SuRT-GeoHarmonizer addresses that boundary. It is not presented as a replacement for broad geospatial platforms or domain pipelines. Instead, it defines a small, contract-first layer in which input transformation, spatial support, provider extension, output semantics, numerical verification and release identity are explicit and testable.

This study asks five questions:

- **RQ1, spatial-support semantics:** Can a fixed support contract distinguish administrative summaries that have identical values and even identical overall valid support but different causes of support loss?
- **RQ2, computational correctness:** Does the configured workflow reproduce independently computed results across controlled fixtures and scoped public-data cases within declared numerical tolerances?
- **RQ3, extensibility:** Can a provider be added out of tree without modifying the generic harmonization engine while retaining schema, provenance and output contracts?
- **RQ4, portability:** Does the same contract execute across non-Rwanda geometry and supported operating systems without geography-specific changes to the generic harmonizer?
- **RQ5, computational cost:** What runtime and measured R-heap overhead is introduced by the mandatory support semantics relative to a direct area-weighted mean using the same geospatial primitives?

The contribution is therefore empirical and architectural. We evaluate the information added by explicit support decomposition, the cost of calculating it, the coupling required to extend the provider layer, and the numerical agreement of scoped real-data cases. We deliberately avoid priority claims and distinguish software verification from validation of the environmental products themselves.

## 2. Related systems and novelty boundary

### 2.1. Raster extraction, coverage and polygon aggregation

`exactextractr` and its underlying exact-extraction approach calculate polygon-cell overlap fractions and weighted summaries [1]. xagg aggregates gridded xarray data to polygons with fractional-area and optional secondary weights [2]. `terra` and GDAL provide broad raster/vector processing, including area calculations and zonal operations [3,4]. Current GDAL 3.12 documentation further exposes fractional polygon-pixel inclusion, coverage reporting and weighted zonal summaries [4]. The recently released `spatcovar` 0.1.0 package provides a consistent polygon-covariate interface with coverage-fraction-weighted raster summaries, CRS handling, geometry repair, unit conversion and standardized missing-value semantics [17]. Google Earth Engine provides regional reducers, pixel-area operations, masking, coordinate-system controls and a large cloud catalogue [5].

Other software and standards further narrow the claim. STAC raster metadata includes a standardized valid-pixel percentage [21], and `raster-footprint` constructs geometries that bound valid raster data [22]. The SWATbuildR modelling workflow documents minimum per-polygon raster coverage checks that raise errors below configured thresholds [23]. `mbg` provides model-based geostatistics and polygon aggregation of raster predictions while preserving uncertainty [20]. Urban Growth Center's GHSL module publishes area-weighted city and administrative summaries together with metric-specific valid-area coverage shares and instructs users to retain each metric with its corresponding validity share [24]. GeoBrix exposes a separate but relevant raster-to-grid distinction: complete coverage can retain cells that overlap the raster extent even when they contain only NoData, while sparse processing is driven by valid pixels [25].

These capabilities preclude novelty claims based on generic coverage reporting, valid-data percentages, footprint derivation, thresholded coverage rejection, robust polygon-covariate wrappers, missing-value handling, health-oriented raster aggregation, value-plus-validity-share outputs, extent-versus-valid support as a general concept, or weighted zonal summaries alone. SuRT-GeoHarmonizer uses mature geospatial ideas rather than replacing them. The workflow uses `exactextractr`, `terra` and `sf` for the core geospatial implementation. The novelty claim does not include polygon-cell intersection, cell-area calculation, zonal means, reprojection, generic coverage calculation or robust geometry handling.

### 2.2. Climate and environmental integration

DART-Pipeline is the closest published climate-health comparator. It is locally deployable, can acquire and process multiple climatic, environmental, socioeconomic and epidemiological sources, supports administrative aggregation, area- and population-weighted statistics, metadata, provenance, tests, CI and extension through custom metrics [6]. DART is broader than SuRT in domain integration and disease-modelling preparation.

AREAdata provides a maintained global resource of climate variables averaged across administrative units and demonstrates that automated, reproducible production of administrative climate summaries is established practice [7]. DHIS2 Climate Tools provides open Python workflows for accessing, processing and uploading climate and environmental data to DHIS2, while the DHIS2 Climate App offers no-code integration through Google Earth Engine [8,9]. The 2026 DHIS2 Open Climate Service goes further by self-hosting sources including CHIRPS and ERA5-Land, scheduling updates, summarizing data by administrative or health-service area, accepting custom data sources and deploying locally, in the cloud or on national infrastructure [18]. Rwanda is among the countries participating in DHIS2 Climate & Health work, so climate-data harmonization for health systems is an active local practice rather than a novel problem owned by this project [10].

### 2.3. Reproducibility, provenance and workflow infrastructure

Snakemake provides mature workflow orchestration and is used by SuRT only as infrastructure [11]. QFlowCrate records QGIS workflow inputs, processing steps, parameters and symbology and exports standards-compliant RO-Crates through a modular provenance architecture [19]. Geospatial Agentic Services integrates validation, provenance, execution traces and machine-readable reproducibility bundles into an interoperable geospatial-services architecture [26]. ESDPKI likewise proposes validation-gated, machine-actionable spatial provenance with explicit parameters, geometry and CRS context [27]. Provenance capture, validation-gated geospatial architecture, reproducibility packaging and modular workflow documentation are therefore not SuRT novelty claims. Recent work such as FairFlow demonstrates that Array publishes reproducibility-centred software frameworks when their execution and verification contracts are clearly defined and empirically evaluated [12]. FairFlow is relevant to evaluation style, not evidence of SuRT novelty.

### 2.4. Position of SuRT-GeoHarmonizer

Table 1 positions the software by system layer rather than scoring unlike products as interchangeable competitors.

**Table 1. Relationship to adjacent software layers.**

| Layer | Examples | Established capability | SuRT relationship |
|---|---|---|---|
| Extraction / geospatial primitives | exactextract(r), terra, GDAL, xagg, spatcovar, raster-footprint, Urban Growth Center, GeoBrix | fractional overlap, zonal summaries, area weighting, coverage diagnostics, valid-data shares/footprints, extent/NoData distinctions, raster/vector operations, polygon-covariate interfaces | SuRT composes mature primitives and does not claim their algorithms or generic wrappers |
| Health / spatial modelling | mbg and related geostatistical workflows | raster prediction, polygon aggregation, weighting and uncertainty-aware summaries | SuRT does not claim a new health or geostatistical aggregation category |
| Cloud / geospatial process platforms | Google Earth Engine, openEO | large catalogues, regional reduction, declarative or programmable processing | SuRT provides a smaller local handoff contract for prepared inputs |
| Domain integration | DART-Pipeline, DHIS2 Climate Tools, Open Climate Service, AREAdata | climate/environmental acquisition, administrative aggregation, health or domain integration, local/national deployment | SuRT is narrower and can serve as an auditable raster-to-administrative boundary |
| Workflow / provenance infrastructure | Snakemake, QFlowCrate, GAS, ESDPKI, general reproducibility frameworks | dependency orchestration, repeatable execution, validation, provenance and reproducibility packaging patterns | SuRT uses these ideas to verify its bounded domain contract |
| Contract-first handoff | SuRT-GeoHarmonizer | explicit per-polygon grid-support and finite-support decomposition, overall-support invariant, fail-closed job/output semantics, tested provider boundary and release-evidence gates | evaluated contribution of this study |

The defensible novelty is therefore not a single unique feature. It is the evaluated integration of explicit per-polygon support decomposition, a fail-closed configuration contract, an out-of-tree provider boundary, independent numerical evidence and exact release-integrity controls around one bounded raster-to-administrative handoff. Equivalent component capabilities can be assembled in other geospatial stacks. A targeted October 2026 search did not establish an exact published match for the complete integrated interface evaluated here, but that search result is not a priority claim and cannot prove uniqueness. The claim concerns the tested integration contract implemented and evaluated here.

The three reported support fields are also not presented as three independent measurements. Only two factors are algebraically independent because overall valid support is their product. All three are emitted so downstream users receive both causal components and the total support directly, while independent validators can check the invariant.

## 3. System design

### 3.1. Contract architecture

SuRT-GeoHarmonizer separates five concerns:

1. **Provider preparation.** Source-specific acquisition and quality-control logic prepares a raster without changing the generic harmonizer.
2. **Declarative job validation.** A JSON Schema defines provider, boundary, variable, raw-value transformation, aggregation, quality-control, output and provenance fields. Unknown fields fail validation.
3. **Generic harmonization.** The R engine validates raster and polygon inputs, applies declared raw-value masks before scale/offset transformation, calculates surface-area-weighted summaries and writes restricted WGS84 GeoJSON.
4. **Independent verification.** Separate tests and validators exercise numerical results, schema invariants, negative paths and deliberate release corruption.
5. **Release evidence.** CI, checksums, versioned archives and exact-tree validation bind claims to a reproducible source state.

The built-in provider adapter accepts a prepared local raster. Provider-specific acquisition is intentionally outside the generic contract because quality-control semantics differ across CHIRPS, ERA5-Land, MODIS, HAND and other products.

### 3.2. Spatial-support semantics

For polygon \(P\), let \(P_R\) be the portion intersecting the raster's rectangular grid extent and let \(P_V\) be the finite, quality-accepted portion of \(P_R\). SuRT reports three fields:

\[
r = \frac{A(P_R)}{A(P)},
\]

\[
v = \frac{A(P_V)}{A(P_R)},
\]

and

\[
d = r\,v = \frac{A(P_V)}{A(P)}.
\]

In the output schema these are `raster_coverage_fraction`, `valid_within_raster_fraction`, and `valid_data_fraction`. Only \(r\) and \(v\) are algebraically independent; \(d\) is reported explicitly as the overall support fraction and independently validated against \(r\times v\). The implementation clamps numerical round-off to the interval [0,1] and can fail closed below a configured minimum overall valid-data fraction.

Here, raster coverage refers to the rectangular grid extent, not a geometry derived from valid pixels. Internal NoData, provider QA rejection and other finite-data loss are represented by \(v\). Keeping these meanings separate is the point of the contract.

The zonal value itself is a surface-area-weighted mean over finite contributions. If raster cell \(i\) has value \(x_i\), cell surface area \(a_i\), and polygon-cell coverage fraction \(c_i\), then

\[
\bar{x}=\frac{\sum_{i\in V}x_i a_i c_i}{\sum_{i\in V}a_i c_i}.
\]

`terra::cellSize(..., transform = TRUE)` supplies square-metre cell-area weights and `exactextractr` supplies polygon-cell coverage fractions. The formulation prevents equal-degree geographic cells at different latitudes from being treated as equal physical areas.

### 3.3. Fail-closed configuration

The Draft 2020-12 job schema uses `additionalProperties: false` for the contract objects. The configured aggregation method is fixed to the surface-area-weighted mean for this version of the public contract. Output CRS is fixed to EPSG:4326. Raw-value no-data thresholds are applied before scale and offset, and integer-only controls such as output rounding are parsed strictly. Invalid CRS, unsupported geometry, duplicate or empty identifiers, missing layers, no finite values, invalid bounds and incomplete configuration trigger explicit failure paths.

This does not make JSON Schema, quality thresholds or fail-closed validation novel. The engineering point is that this workflow binds its scientific handoff semantics to machine-checkable requirements rather than leaving them only in prose documentation.

### 3.4. Provider extension boundary

`python/provider_adapters.py` defines a minimal provider protocol: validation of provider/QA options and preparation of a raster artifact plus optional provenance suffix. Built-ins are registered internally, while an external provider can be loaded from `module:factory`. The generic R harmonizer has no provider-specific registry.

The boundary deliberately does not promise that arbitrary environmental products are scientifically interchangeable. A new provider still requires scientifically appropriate acquisition, QA, units, scaling, temporal aggregation and provenance. The adapter only decouples those responsibilities from the generic spatial handoff.

### 3.5. Release-evidence boundary

The verification layer includes controlled fixtures, deliberate failure injection, independent output-contract validation, source-pinned numerical checks, checksum-manifest validation, multi-platform core smoke tests and a Snakemake evidence DAG. The published v1.3.0 release remains immutable; v1.4.0 is not treated as published until one exact source tree, DOI, tag, archive and checksum manifest agree.

## 4. Evaluation methods

### 4.1. RQ1: support-semantics collision experiment

A controlled two-cell projected raster fixture was constructed to create four cases with the same finite zonal mean while varying two independent causes of incomplete support:

- complete grid coverage and complete finite support;
- complete grid coverage with one of two in-grid cells missing;
- half-grid coverage with all covered cells finite;
- half-grid coverage with half of the covered area finite.

All finite cells were assigned value 10. We therefore compare three interface states: mean only; mean plus the single overall valid-data fraction \(d\); and mean plus the full reported support tuple \((r,v,d)\). The experiment records the number of unique signatures under each interface and specifically tests whether finite-data loss can be distinguished from raster-grid extent loss when both yield the same overall valid support. This is an interface-information experiment, not a claim that other geospatial software cannot be programmed to compute the same quantities.

### 4.2. RQ2: independent numerical reproduction

Controlled unit tests are separated from real-product computational cross-checks.

**Uganda CHIRPS 2023.** A source-derived Uganda boundary and public CHIRPS v2.0 annual 2023 raster are processed through the same declarative local-raster adapter and generic harmonizer. A separate `terra` calculation recomputes the national area-weighted mean.

**ERA5-Land 2023.** Nyarugenge monthly mean 2 m temperature is aggregated using exact calendar-day weights for 12 months before kelvin-to-Celsius conversion, then independently recomputed.

**MOD13A3 v061 2023.** Nyarugenge annual NDVI uses the declared MOD13A3 subdataset, scale and Pixel Reliability rule. Twenty-four HDF source granules are individually SHA-256 pinned. Production output is compared with an independently implemented pre-rounding estimate and support fractions.

**HAND 30 m.** Rubavu percentage area at or below 5 m is calculated over valid HAND-covered area, excluding negative sentinels, and independently recomputed.

These checks test implementation agreement for specified source cases. They do not test the observational accuracy of CHIRPS, ERA5-Land, MODIS or HAND.

### 4.3. RQ3: out-of-tree extension experiment

The account-free configuration test creates a temporary Python provider module outside the repository source tree. The module is added only to the interpreter search path and is loaded through `module:factory`. The experiment verifies:

- the module is physically outside the repository;
- no edit is required to the built-in provider registry;
- no edit is required to the generic R harmonizer;
- the prepared artifact and adapter-provided provenance are preserved; and
- malformed adapter objects and undeclared options fail closed.

### 4.4. RQ4: geographic and operating-system portability

Portability is evaluated at separate levels to avoid conflation.

**Geometry and identifier portability.** Controlled projected fixtures use arbitrary non-Rwanda identifiers and polygon geometry. A second-country test uses a source-derived Uganda administrative boundary with a deterministic synthetic raster. The real Uganda CHIRPS case then exercises the same generic configured workflow with public environmental data.

**Operating-system portability.** Core smoke CI runs on Ubuntu 24.04, Windows 2025 and macOS 14. The full account-free reproducibility workflow is Ubuntu-based. Credentialed ERA5-Land and MODIS acquisition is not claimed to be verified across all three operating systems.

### 4.5. RQ5: cost-of-auditability benchmark

`R/benchmark_array_contract.R` compares two paths using the same `terra` and `exactextractr` stack:

1. `direct_mean`, which returns only the finite-value surface-area-weighted mean;
2. `surt_support_contract`, which returns that mean plus raster-grid coverage, finite support within the grid-covered area, and overall valid-data support.

Three deterministic workloads were used: 10,000 raster cells with 16 polygons, 90,000 cells with 64 polygons, and 360,000 cells with 144 polygons. Each mode was warmed before timing and run five times. The final benchmark machine was Microsoft Windows 11 Pro with an Intel Core i7-8850H @ 2.60 GHz, approximately 15.76 GB installed RAM, and R 4.6.0.

Wall-clock time was measured with `proc.time()`. Memory values are R garbage-collector heap indicators, reported as the increase between pre-execution heap occupancy and the maximum heap use observed by `gc()`. They are not total operating-system resident-set size and are not presented as a general hardware-efficiency measure.

## 5. Results

### 5.1. RQ1: identical means, different support

All four collision fixtures returned a zonal mean of 10, while the mandatory support fields separated the cases exactly as intended (Table 2). The full zonal area and coverage regression suite returned 18 passed and 0 failed in the recorded local run.

**Table 2. Support-semantics collision experiment.**

| Case | Mean | Raster-grid coverage | Valid within grid-covered area | Overall valid data |
|---|---:|---:|---:|---:|
| Complete | 10 | 1.0 | 1.0 | 1.00 |
| Finite-data gap | 10 | 1.0 | 0.5 | 0.50 |
| Raster-grid footprint gap | 10 | 0.5 | 1.0 | 0.50 |
| Combined gap | 10 | 0.5 | 0.5 | 0.25 |

A mean-only handoff produced **one** unique interface signature across the four cases. Adding only the overall valid-data fraction produced **three** signatures: the finite-data-gap and raster-grid-gap cases both returned `(mean = 10, overall valid data = 0.5)`. Reporting the two causal support factors plus their explicit overall product produced **four** signatures and distinguished those mechanisms as `(1.0, 0.5, 0.5)` versus `(0.5, 1.0, 0.5)`.

The result demonstrates information value rather than algorithmic exclusivity. Urban Growth Center is a concrete current example of zonal metrics paired with an overall valid-coverage share [24], while GeoBrix already distinguishes raster-extent coverage from valid-pixel sparsity at a raster-to-grid layer [25]. The three SuRT support fields are not algebraically independent, and other geospatial software can be programmed to calculate comparable quantities. The SuRT claim is narrower: both per-polygon causal factors and their overall product are mandatory, semantically fixed and regression-validated in its output contract.

### 5.2. RQ2: scoped numerical agreement

Table 3 summarizes the source-pinned real-data checks.

**Table 3. Independent computational cross-checks.**

| Case | Configured/production result | Independent result | Agreement statement |
|---|---:|---:|---|
| Uganda CHIRPS 2023 | 1238.073160 mm | 1238.073144 mm | absolute difference 0.000016 mm; all three support fractions 1.0 |
| Nyarugenge ERA5-Land 2023 | 20.597411 °C | 20.597414 °C | approximately 0.000003 °C difference; complete reported coverage |
| Nyarugenge MOD13A3 v061 2023 | 0.56 NDVI | 0.55775352 before production rounding | agreement under declared two-decimal output contract; support-fraction differences <0.000051 |
| Rubavu HAND <=5 m | 26.133870170321% | 26.133870170236% | difference <1e-9 percentage points; complete reported coverage in the checked case |

The checks support computational reproducibility of the declared methods for these cases. They do not establish that the source products are unbiased measurements of local environmental conditions.

### 5.3. RQ3: external extension without core modification

The configuration and adapter suite returned 21 passed and 0 failed. The temporary provider fixture loaded from outside the repository, returned the declared prepared raster and provenance text, and required zero modifications to the built-in provider registry or generic R harmonizer. Invalid adapter shape and undeclared options were rejected.

This result supports the intended decoupling boundary. It does not establish that every future provider can be integrated without provider-specific engineering.

### 5.4. RQ4: bounded portability

The generic harmonizer passes projected arbitrary-geometry tests, source-derived Uganda-boundary tests and the Uganda CHIRPS configured case without Rwanda-specific changes to the core harmonizer. Core smoke tests run on Ubuntu, Windows and macOS. The stronger claim of full provider acquisition on all operating systems is intentionally withheld because the credentialed acquisition paths have not been established across that matrix.

### 5.5. RQ5: measured cost of mandatory support semantics

The support contract preserved the direct baseline mean in every paired run (`max_value_difference_vs_peer = 0`). Median timings and R-heap peak deltas are shown in Table 4.

**Table 4. Final five-repetition benchmark on the documented Windows workstation.**

| Workload | Direct mean median | SuRT contract median | Absolute time overhead | Direct R-heap peak delta | SuRT R-heap peak delta |
|---|---:|---:|---:|---:|---:|
| 10,000 cells / 16 polygons | 0.11 s | 0.14 s | +0.03 s | 22.7 MB | 26.8 MB |
| 90,000 cells / 64 polygons | 0.20 s | 0.24 s | +0.04 s | 88.9 MB | 97.6 MB |
| 360,000 cells / 144 polygons | 0.50 s | 0.57 s | +0.07 s | 144.7 MB | 150.7 MB |

These results quantify the tested cost rather than establish performance superiority. They are specific to the benchmark implementation, workload, dependency versions and machine.

The initial benchmark also revealed an inefficient per-feature equal-area intersection in raster-grid coverage calculation. Replacing it with rectangular grid-extent overlap extraction and a complete-coverage short circuit reduced the controlled large-fixture coverage path from approximately 19.3 s to 0.64 s without changing the support results; all zonal regression tests remained green. The final benchmark in Table 4 was run after this correction.

## 6. Relevance to climate-health and public-sector data workflows

Environmental covariates are commonly joined to administrative health data for studies of climate-sensitive disease, maternal and child health, nutrition, environmental exposure and service planning. The existence of DART, DHIS2 Climate & Health, Open Climate Service and health-oriented geostatistical software such as `mbg` demonstrates that this is already an active research and implementation area [6,8-10,18,20]. SuRT does not attempt to replace those systems.

Its practical role is lower in the stack. Once an appropriate raster is available, the harmonizer can create an administrative covariate while retaining explicit evidence about how much of each polygon intersects the raster grid and how much of that covered area remains finite after quality control. This distinction can matter when downstream analysts would otherwise receive identical-looking means, or even the same overall valid-support fraction, produced by different mechanisms of support loss.

For LMIC and African settings, the defensible benefit is portability and inspectability rather than a claim of being uniquely designed for constrained environments. The account-free verification path works on prepared local inputs without a proprietary cloud account; outputs and release files can be inspected and checksum-verified; provider-specific acquisition can remain local; and the core dependencies are open-source. Open Climate Service already demonstrates that self-hosted, country-scale climate infrastructure for African and Asian settings is an active field [18]. The benchmark provides one documented resource profile, but it is insufficient to label SuRT universally `lightweight` or `low-resource`.

Rwanda provides a relevant reference setting because climate and environmental data are already being integrated into national DHIS2-oriented health workflows [10]. SuRT's contribution is complementary: it focuses on an auditable covariate handoff and does not claim institutional endorsement, health-system deployment, forecasting capability, epidemiological modelling or direct DHIS2 integration.

## 7. Threats to validity and limitations

**Prior-art completeness.** The related-software search covers the closest systems identified during reviewer remediation and Array hardening, including current GDAL zonal-statistics capabilities, `spatcovar` 0.1.0, DART-Pipeline, Open Climate Service, `mbg`, Urban Growth Center, GeoBrix, QFlowCrate, Geospatial Agentic Services, ESDPKI, STAC validity metadata, valid-data footprint tooling and documented fail-closed raster-coverage checks. No literature or software search can prove that no other project implements the same integrated semantics. We therefore avoid `first`, `unique` and priority claims. The contribution is evaluated as an integrated contract, not inferred from the absence of equivalent primitives elsewhere.

**Support-field dependence.** The three reported support fields are intentionally redundant: `valid_data_fraction = raster_coverage_fraction × valid_within_raster_fraction`. Only two are algebraically independent. The overall fraction is emitted so downstream users receive total support directly and validators can check the invariant. RQ1 demonstrates information preserved by separating the two causes of support loss; it does not show that three independent quantities are required or that other software cannot expose them.

**Evaluation scope.** RQ1 and RQ3 are controlled software experiments. RQ2 contains scoped public-data calculations, not multi-site environmental validation. Uganda CHIRPS supplies one real second-country configuration case; ERA5-Land and MODIS checks are limited to Nyarugenge in 2023, and the HAND check to Rubavu and one public tile.

**Performance external validity.** RQ5 uses one workstation, one software stack and synthetic benchmark geometries. R-heap indicators are not operating-system RSS. The results quantify this implementation and must not be generalized to all machines or workloads.

**Provider generality.** The public adapter boundary is generic, but scientific preparation remains provider-specific. A new adapter can satisfy the software protocol while still being scientifically inappropriate if its QA, scale, units, temporal aggregation or interpretation are wrong. Software validation cannot remove that responsibility.

**Operating-system claim.** The core smoke matrix covers three operating systems, but the full reproducibility CI is Ubuntu-based and credentialed acquisition is not verified on every platform.

**Administrative aggregation.** Annual polygon summaries suppress temporal extremes, seasonality and within-unit heterogeneity. The software produces research covariates; it does not convert HAND into flood probability or turn environmental products into validated exposure or hazard estimates.

## 8. Reproducibility and availability

The public repository is `https://github.com/PrinceAudre/surt-virtual-rwanda-repro`.

The currently published release is v1.3.0, archived at `https://doi.org/10.5281/zenodo.21840177`. The release-family concept DOI is `https://doi.org/10.5281/zenodo.21671788`. The Array manuscript describes the unreleased v1.4.0 development target on branch `review/softwarex-resubmission-v1.4.0`. No v1.4.0 DOI is valid until the exact approved source tree is frozen and archived.

Account-free verification is orchestrated by:

```text
python python/run_all_checks.py
```

A release candidate additionally requires complete tracked-file checksum verification, independent release-contract validation, the Snakemake evidence DAG and the declared CI matrix. Array-specific benchmark evidence is tracked under `evidence/array/`. Source-pinned numerical evidence is tracked under `evidence/chirps/`, `evidence/era5land/`, `evidence/modis/` and `evidence/hand/`.

The software is distributed under the MIT License. Third-party environmental data retain their original provider terms and citations.

## 9. Conclusions

SuRT-GeoHarmonizer does not propose a new zonal-statistics algorithm. It addresses a narrower software-engineering problem: making a common raster-to-administrative handoff explicit enough that spatial support, transformation, provider extension, numerical agreement and release identity can be tested as one contract.

The evaluation shows why that contract can add information. Four administrative summaries with identical means collapsed to one mean-only signature. Adding only overall valid support yielded three signatures because finite-data loss and raster-grid extent loss can produce the same total support. Exposing the two causal factors plus their explicit product yielded four signatures while preserving an independently checkable invariant. Scoped CHIRPS, ERA5-Land, MODIS and HAND calculations agreed with independent implementations within declared tolerances. A provider was loaded from outside the repository without changes to the generic harmonizer or built-in registry. The core contract is exercised beyond Rwanda and across a bounded three-operating-system smoke matrix. Finally, the computational price of the added support fields was measured rather than hidden, with small absolute timing overheads in the tested benchmark and no change in paired means.

The resulting contribution is best understood as an auditable integration boundary that complements, rather than replaces, broader systems such as DART, Open Climate Service, DHIS2 Climate Tools, Google Earth Engine and established geospatial libraries. Release and submission remain contingent on exact-tree validation and final claim-to-evidence review.

## Declaration of competing interest

The author declares no known competing financial interests or personal relationships that could have appeared to influence this work.

## Funding

This work received no specific grant from public, commercial or not-for-profit funding agencies.

## Declaration of generative AI and AI-assisted technologies in the writing and software-development process

During development and manuscript preparation, the author used OpenAI ChatGPT and Codex and, during earlier development stages, Anthropic Claude for coding assistance, critical review and language editing. No named AI system is an acceptance or release gate. The author reviewed and edited the outputs, reran the reported checks, verified cited facts and source terms, and takes responsibility for the software and manuscript. These tools did not generate source environmental data or empirical measurements.

## References

[1] D. Baston, exactextractr: Fast Extraction from Raster Datasets using Polygons, R package. https://doi.org/10.32614/CRAN.package.exactextractr.

[2] K. Schwarzwald, K. Geil, xagg: A Python package to aggregate gridded data onto polygons, Journal of Open Source Software 9 (104) (2024) 7239. https://doi.org/10.21105/joss.07239.

[3] R. J. Hijmans, terra: Spatial Data Analysis, R package and documentation. https://rspatial.org/terra/.

[4] Open Source Geospatial Foundation, GDAL documentation, raster zonal statistics. https://gdal.org/en/stable/programs/gdal_raster_zonal_stats.html.

[5] N. Gorelick, M. Hancher, M. Dixon, S. Ilyushchenko, D. Thau, R. Moore, Google Earth Engine: planetary-scale geospatial analysis for everyone, Remote Sensing of Environment 202 (2017) 18-27. https://doi.org/10.1016/j.rse.2017.06.031.

[6] A. Dasgupta, I. Perez-Fernandez, T. Huynh, C. Mills, R. C. Nicholls, P. Sambaturu, M. Choisy, D. Wallom, T. Nguyen-Duy, R. P. D. Inward, J.-S. Brittain, S. Sparrow, M. U. G. Kraemer, Scalable, open-access and multidisciplinary data integration pipeline for climate-sensitive diseases, Wellcome Open Research 10 (2025) 467. https://doi.org/10.12688/wellcomeopenres.24774.3.

[7] T. P. Smith, M. Stemkovski, A. Koontz, W. D. Pearse, AREAdata: A worldwide climate dataset averaged across spatial units at different scales through time, Data in Brief 43 (2022) 108438. https://doi.org/10.1016/j.dib.2022.108438.

[8] DHIS2, Climate Data Integration with DHIS2, official project documentation. https://dhis2.org/climate/climate-data/ (accessed 4 October 2026).

[9] DHIS2 Climate Tools, official documentation. https://climate-tools.dhis2.org/ (accessed 4 October 2026).

[10] DHIS2, Climate & Health Country Profiles: Rwanda, official project documentation. https://dhis2.org/climate/country-profiles/ (accessed 4 October 2026).

[11] F. Mölder, K. P. Jablonski, B. Letcher, M. B. Hall, C. H. Tomkins-Tinch, V. Sochat, J. Forster, S. Lee, S. O. Twardziok, A. Kanitz, A. Wilm, M. Holtgrewe, S. Rahmann, S. Nahnsen, J. Köster, Sustainable data analysis with Snakemake, F1000Research 10 (2021) 33. https://doi.org/10.12688/f1000research.29032.2.

[12] A. D'Onofrio, E. Martelli, M. Alessandri, S. Bucatariu, S. G. Contaldo, M. L. Ratto, J. Tao, B. Nuvolari, I. Castellano, A. Loiacono, S. Bianchi, M. Arigoni, A. Bertero, E. Balmas, R. Chiarle, L. Alessandri, FairFlow: A transparency-first framework for verifiable and reproducible bioinformatics, Array 31 (2026) 101150. https://doi.org/10.1016/j.array.2026.101150.

[13] C. Funk, P. Peterson, M. Landsfeld, et al., The climate hazards infrared precipitation with stations: a new environmental record for monitoring extremes, Scientific Data 2 (2015) 150066. https://doi.org/10.1038/sdata.2015.66.

[14] J. Muñoz-Sabater, E. Dutra, A. Agustí-Panareda, et al., ERA5-Land: a state-of-the-art global reanalysis dataset for land applications, Earth System Science Data 13 (2021) 4349-4383. https://doi.org/10.5194/essd-13-4349-2021.

[15] K. Didan, MOD13A3 MODIS/Terra Vegetation Indices Monthly L3 Global 1 km SIN Grid V061, NASA EOSDIS Land Processes DAAC (2021). https://doi.org/10.5067/MODIS/MOD13A3.061.

[16] A. D. Nobre, L. A. Cuartas, M. Hodnett, et al., Height Above the Nearest Drainage: a hydrologically relevant new terrain model, Journal of Hydrology 404 (2011) 13-29. https://doi.org/10.1016/j.jhydrol.2011.03.051.

[17] E. Cebeci, spatcovar: Construct Spatial Covariates from Polygon Data, R package version 0.1.0 (2026). https://doi.org/10.32614/CRAN.package.spatcovar.

[18] DHIS2, Introducing Open Climate Service: Self-Hosted Climate Data Infrastructure for DHIS2 and Chap, 24 August 2026. https://dhis2.org/introducing-open-climate-service/ (accessed 4 October 2026).

[19] A. Rademaker, E. Koukouraki, B. Pondi, QFlowCrate: A QGIS Plugin for Workflow Documentation and Provenance Capture to Enhance Geoscientific Reproducibility, Journal of Open Research Software 14 (2026) 44. https://doi.org/10.5334/jors.704.

[20] N. Henry, B. Mayala, R. Burstein, N. Sadat, M. Richards, M. Collison, M. Cork, mbg: Model-Based Geostatistics, R package version 1.2.0 (2026). https://doi.org/10.32614/CRAN.package.mbg.

[21] SpatioTemporal Asset Catalog, Common Metadata, Statistics Object and `valid_percent`. https://github.com/radiantearth/stac-spec/blob/master/commons/common-metadata.md (accessed 4 October 2026).

[22] P. Hartzell, raster-footprint: create GeoJSON geometries that bound valid raster data, Python package version 0.3.0 (2026). https://pypi.org/project/raster-footprint/.

[23] OPTAIN, SWAT+ modelling protocol, section on `check_raster_coverage()` and minimum raster-data coverage by spatial object. https://www.optain.eu/sites/default/files/delivrables/OPTAIN%20D4.2%20-%20Modelling_Protocols.pdf (accessed 4 October 2026).

[24] Development Data Lab, Urban Growth Center: GHSL Built-up Zonal Statistics, documentation v0.3.0 (2026). https://cities.devdatalab.org/docs/datasets/ghsl-builtup (accessed 4 October 2026).

[25] Databricks Labs, GeoBrix raster-grid coverage modes and raster functions, release v0.5.1 documentation (2026). https://databrickslabs.github.io/geobrix/docs/release-notes/ (accessed 4 October 2026).

[26] Geospatial Agentic Services: a framework for interoperable geospatial intelligence, International Journal of Digital Earth (2026). https://doi.org/10.1080/19475683.2026.2738374.

[27] M. A. Sadiq, P. K. Langat, A. Neupane, Enterprise Spatial Data Provenance Knowledge Infrastructure, ISPRS International Journal of Geo-Information 15 (5) (2026) 182. https://doi.org/10.3390/ijgi15050182.