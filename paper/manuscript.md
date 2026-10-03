# SuRT-GeoHarmonizer: An auditable R and Python workflow for administrative-scale Earth-data harmonization and provenance labelling

**TUYISHIME AUDRE PRINCE**

School of Public Health, College of Medicine and Health Sciences, University of Rwanda, Kigali, Rwanda

ORCID: 0009-0002-0799-3140

Corresponding author: TUYISHIME AUDRE PRINCE, priplee@gmail.com

Article type: Original Software Publication

## Abstract

Environmental analyses frequently combine rasters that differ in access methods, coordinate systems, scale factors, no-data conventions, temporal support, quality controls, and licence terms. SuRT-GeoHarmonizer is an open R and Python workflow that converts environmental rasters and polygon boundaries into provenance-labelled administrative-unit GeoJSON. The v1.4 reviewer-remediation code adds surface-area-weighted zonal aggregation, separate raster-footprint and finite-data coverage fields, a fail-closed declarative JSON job contract, a provider-adapter boundary, and a Snakemake evidence workflow. A Rwanda reference implementation contains CHIRPS rainfall, ERA5-Land temperature, MODIS vegetation greenness, and Height Above Nearest Drainage terrain builders for 30 districts. Account-free verification dynamically exercises transformations, configuration, arbitrary projected geometry, deliberate failures, and release contracts. Reuse is demonstrated in Uganda in two distinct ways: a real boundary with a deterministic synthetic signal tests geometry and identifier portability, while a source-derived 2023 CHIRPS raster and the same Uganda boundary run through the generic configured workflow. The latter produced 1,238.073160 mm with complete reported raster and valid-data coverage and differed from an independent `terra` area-weighted calculation by 0.000016 mm. The software supports auditable preparation of research covariates while explicitly excluding hazard, forecast, epidemiological, exposure, and operational interpretations.

**Keywords:** geospatial software; environmental data harmonization; data provenance; zonal statistics; reproducible research; GeoJSON

## 1. Motivation and significance

Earth-observation and environmental research increasingly depend on computational chains that combine observation, reanalysis, vegetation, and terrain products. Even a small administrative-unit dataset may require provider-specific authentication, file acquisition, masking, scaling, quality filtering, temporal aggregation, mosaicking, reprojection, polygon extraction, metadata recording, licence attribution, verification, and archival packaging. CHIRPS precipitation, ERA5-Land temperature, MODIS vegetation indices, and Height Above Nearest Drainage (HAND) illustrate this heterogeneity [1–4].

Mature tools solve important parts of the problem. Google Earth Engine provides catalogue-scale access and computation [5], MODIStsp automates MODIS preparation [6], and `exactextractr` performs efficient polygon extraction [7]. Table 1 compares documented primary scope rather than theoretical composability: "user-defined" means a capability can be constructed by the user but is not a fixed contract of the named tool. SuRT-GeoHarmonizer does not replace these tools or claim novelty for their underlying algorithms; its contribution is an integrated administrative-data and release-evidence contract.

**Table 1. Functional scope relevant to the reviewer-requested comparison.**

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
| Account-free verification path | Cloud access required for service use | Offline processing possible after acquisition | Yes | Yes |
| Provider extension boundary | Platform/data-catalogue model | MODIS-specific | Raster-agnostic extraction | Adapter contract |
| Workflow orchestration | Platform task model/user workflow | Processing workflow | Function-level | Snakemake evidence DAG |

SuRT-GeoHarmonizer addresses a narrower integration problem than end-to-end domain pipelines. DART-Pipeline, for example, integrates epidemiological, socioeconomic, climatic, and environmental data for climate-sensitive-disease analysis and performs configurable administrative aggregation [11]. SuRT does not reproduce that broader function. Its scope is the raster-to-administrative release boundary: explicit surface-area and coverage semantics, fail-closed job configuration, restricted provenance-labelled GeoJSON output, negative tests, independent output-contract validation, source-pinned numerical cross-checks, and exact release-integrity controls. This boundary can complement broader analytical pipelines. It does not claim novelty for zonal-statistics or cell-area algorithms.

The contribution is software architecture and executable release evidence rather than a new raster algorithm. Rwanda is the primary reference implementation. Reuse outside Rwanda is demonstrated through a generic raster and polygon interface, a declarative configuration contract, an adapter extension boundary, controlled arbitrary-geometry tests, a real Uganda-boundary portability gate, and a source-derived Uganda CHIRPS case. The Uganda CHIRPS case is computational cross-validation of one public environmental product, not validation of CHIRPS observational accuracy or evidence that every provider and geography is scientifically interchangeable.

## 2. Software description

### 2.1. Architecture

SuRT-GeoHarmonizer separates five concerns (Fig. 1):

1. **Provider preparation.** Source-specific clients and builders acquire or prepare products outside the generic harmonizer.
2. **Declarative configuration and adapters.** A JSON Schema fixes the job contract for provider input, boundaries, variables, transformations, aggregation, QA, output, and provenance. A Python adapter protocol exposes a built-in `local_raster` adapter and an external `module:factory` extension mechanism.
3. **Administrative harmonization.** The R interface validates raster and polygon inputs, applies declared raw-value masking and scale or offset conversion, computes finite-cell polygon summaries, and writes a restricted WGS84 GeoJSON schema.
4. **Evidence classification.** A fail-closed register treats unknown, incomplete, synthetic, or placeholder material as illustrative unless a documented method applied to real or public data is declared.
5. **Verification and release.** Controlled fixtures, a Snakemake evidence DAG, deliberate failure injection, independent Python validation, checksums, continuous integration, Git tags, and archives make specified behaviour and release identity inspectable.

R handles geospatial processing. Python handles configuration, adapters, provider access, orchestration support, metadata checks, and independent GeoJSON validation. `renv.lock` records the R dependency graph. Optional provider clients are separately pinned so the core account-free pathway does not require network access or credentials.

### 2.2. Generic interface

The public entry point is:

```text
Rscript R/harmonize_admin_raster.R \
  --raster input.tif \
  --boundaries units.geojson \
  --id-field admin_code \
  --value-name environmental_mean \
  --output output.geojson \
  --provenance "Source, product, period, method and applicable terms"
```

The interface requires declared coordinate reference systems, valid polygon or multipolygon geometry, and unique non-empty identifiers. It can select a raster layer, mask raw values, apply scale and offset conversion, round outputs, enforce value bounds, and require a minimum overall valid-data fraction.

For each polygon, finite raster contributions are weighted by polygon-cell overlap fraction multiplied by raster-cell surface area in square metres. The output is normalized to EPSG:4326 and contains `unit_id`, the requested measurement property, `raster_coverage_fraction`, `valid_within_raster_fraction`, `valid_data_fraction`, `provenance`, and geometry. Processing fails closed when required geometry, coordinate systems, identifiers, raster support, finite values, or declared bounds are invalid. The interface validates computational behaviour, not scientific appropriateness of a selected product, period, threshold, scale, unit conversion, coverage threshold, or interpretation.

### 2.3. Declarative workflow contract

`config/harmonization-job.schema.json` defines schema version 1.0 and rejects unknown top-level and nested fields. `python/run_configured_harmonization.py` validates the configuration and adapter before mapping its declared controls to the generic R harmonizer. The bundled `local_raster` adapter accepts an already prepared raster and rejects undeclared provider-specific QA. External providers can implement the same adapter protocol without modifying the generic R engine. The external loading boundary is exercised account-free by loading a fixture `module:factory` adapter that is absent from the built-in registry, preparing a declared raster, preserving adapter-supplied provenance, and rejecting malformed plugin objects and undeclared options.

The `Snakefile` provides a deterministic account-free evidence DAG. It prepares a controlled multilayer raster and polygon fixture, validates the configuration, transforms the controlled raster, runs configured harmonization, validates the output, and writes machine-readable workflow evidence. This verifies orchestration and interface boundaries; the controlled raster is synthetic and is not real-product validation.

### 2.4. Rwanda reference builders

Four builders demonstrate provider-specific transformations:

- **Rainfall:** CHIRPS v2.0 annual precipitation, with negative fill or no-data values masked and surface-area-weighted district means.
- **Temperature:** ERA5-Land monthly mean 2 m temperature, requiring 12 months and using a calendar-day-weighted annual mean, including leap-year handling, before kelvin-to-Celsius conversion and spatial aggregation.
- **Vegetation:** MODIS/Terra MOD13A3 v061 monthly NDVI with documented scaling, pixel-reliability filtering, and a minimum valid-month fraction for annual cells. The v1.4 production default accepts reliability rank 0 only.
- **Terrain:** Global 30 m HAND expressed as the percentage of valid HAND-covered polygon area at or below 5 m; negative sentinels are excluded from the denominator.

The published v1.3 data contain one feature for each of Rwanda's 30 districts. District geometry is derived from a World Bank CC BY 4.0 dataset. Revised v1.4 builder outputs remain development artifacts until independent validation and release approval. Source-specific terms are recorded in `NOTICE.md`.

## 3. Illustrative examples

### 3.1. Portability and account-free workflow evidence

`R/test_generic_harmonizer.R` constructs a projected synthetic raster and three arbitrary polygon units, then exercises the public interface, coverage fields, masking, scaling, bounds, schema, and failure behaviour. A separate transformation fixture exercises rainfall, temperature, HAND, and MODIS functions against projected non-Rwanda geometry and arbitrary identifiers.

`R/test_second_country_portability.R` adds a source-derived Uganda national boundary to the portability evidence. It pairs that real non-Rwanda geometry with a deterministic synthetic raster, invokes the same generic harmonizer, and checks identifier preservation, geometry preservation, coverage, bounded output, and provenance. This remains a software portability test.

A separate source-derived case uses the same Uganda boundary with the public CHIRPS v2.0 annual 2023 raster. `config/uganda-chirps-2023.json` passes the raster and boundary through the same declarative `local_raster` adapter and generic harmonizer used by other configured jobs. `R/validate_uganda_chirps_case.R` independently recomputes the surface-area-weighted national mean with `terra` exact cell fractions and cell areas. The configured result was 1,238.073160 mm, the independent result was 1,238.073144 mm, and the absolute difference was 0.000016 mm. Raster-footprint, within-raster finite-data, and overall valid-data fractions were all 1.0. This demonstrates an account-free source-derived second-country environmental case without Rwanda-specific harmonizer edits; it does not validate CHIRPS observational accuracy.

### 3.2. Rwanda environmental layers

The published reference release contains district rainfall, temperature, NDVI, and low-lying terrain layers (Fig. 2). For example, the archived Nyarugenge records contain 955 mm annual rainfall, 20.6 °C mean temperature, 0.55 mean NDVI, and a 22.1% HAND share at or below 5 m. These are descriptive reference artifacts. The HAND value is not observed flood extent or flood probability, and the archived v1.3 values must not be represented as automatically recalculated v1.4 outputs.

### 3.3. Verification and numerical reproduction

The one-command development pathway is:

```text
python python/run_all_checks.py
```

The runner derives outcome counts from executable output rather than a manually maintained assertion total. It covers provenance classification, controlled environmental transformations, projected portability, the Uganda-boundary gate, the generic interface, configuration and adapter validation, area weighting and coverage, ERA5 annual statistics, MODIS QA, HAND denominator behaviour, deliberate failures, release-contract checks, and remediation metadata. A frozen candidate additionally runs `python python/run_all_checks.py --verify-manifest`. The Snakemake DAG is executed independently in continuous integration.

CHIRPS has two public-data numerical checks. For Rwanda, reacquisition of the 2023 annual raster reproduced all 30 archived whole-millimetre district values after rounding. The maximum `exactextractr` versus `terra::extract` difference was 0.000136 mm, and adding cell-area weights changed district means by at most 0.005127 mm. For Uganda, the configured source-derived case produced 1,238.073160 mm and an independent `terra` area-weighted calculation produced 1,238.073144 mm, an absolute difference of 0.000016 mm, with all three reported coverage fractions equal to 1.0. Scoped real-data cross-checks also passed for the revised provider-specific methods. Nyarugenge ERA5-Land produced 20.597411 °C versus 20.597414 °C independently, with complete reported coverage. Nyarugenge MOD13A3 reported 0.56 annual NDVI, while the independent pre-rounding estimate was 0.55775352; they agree under the declared two-decimal output contract, and the valid-area and valid-month fractions differed by less than 0.000051. Rubavu HAND at or below 5 m was 26.133870% in both implementations to six decimal places, with complete reported coverage. These are computational cross-checks of specified cases, not validation of CHIRPS, ERA5-Land, MODIS, or HAND observational accuracy.

## 4. Impact

SuRT-GeoHarmonizer is intended for researchers who need transparent administrative covariates but do not want provider-specific implementation details dispersed across notebooks and undocumented scripts. Potential applications include climate-health studies, ecological analyses, agricultural monitoring, environmental exposure research, and public-sector data preparation. The generic interface can be used for polygon-supported raster means when the user supplies scientifically appropriate transformation and provenance information.

Concrete reuse evidence now includes the source-derived Uganda CHIRPS case: the Rwanda-independent configuration used the same adapter and generic harmonizer, retained complete reported coverage, and agreed with an independent `terra` area-weighted calculation within 0.000016 mm. The software contributes four reusable practices. First, provider preparation is separated from the generic harmonization contract, and the adapter boundary permits additional providers without changing the R engine. Second, declarative configuration and a workflow DAG make the execution contract machine-readable and testable. Third, positive fixtures are paired with deliberate failures, real-boundary portability evidence, and independent release validation. Fourth, provenance, metadata, checksums, and versioned archives make the released artifact identifiable.

FAIR principles emphasize findability, accessibility, interoperability, and reuse [8]. W3C PROV and RO-Crate provide richer formal models for provenance and research objects [9,10]. SuRT-GeoHarmonizer does not claim conformance to those standards; it provides lightweight human-readable provenance and machine-readable software metadata that could later be mapped to them.

Limitations remain explicit. Full reproducibility continuous integration is Ubuntu-based, while a separate core smoke matrix passes on Ubuntu 24.04, Windows 2025, and macOS 14. The matrix does not establish cross-platform execution of every credentialed provider acquisition path. The built-in adapter accepts a prepared local raster rather than implementing production acquisition and QA for every provider, and ERA5-Land and MODIS rebuilds require provider accounts. The Uganda evidence comprises a synthetic-signal portability gate plus one source-derived CHIRPS national case; it does not establish universal provider or geographic validity. The ERA5-Land and MODIS checks are limited to Nyarugenge in 2023, and the HAND check is limited to one public tile and Rubavu district. Administrative annual summaries suppress seasonality, extremes, and within-unit heterogeneity. MODIS QA filtering changes spatial and temporal support, so coverage is part of the result. HAND at or below 5 m is a static terrain descriptor, not a validated hazard indicator.

## 5. Conclusions

SuRT-GeoHarmonizer packages heterogeneous raster preparation as an auditable administrative-data workflow. The reviewer-remediation code now combines a generic command-line interface, explicit surface-area and coverage semantics, a declarative JSON contract, a provider-adapter boundary, Snakemake orchestration evidence, fail-closed classification, account-free verification, real-boundary portability testing, source-derived Uganda CHIRPS reuse, scoped independent real-data cross-checks, three-platform core smoke evidence, independent GeoJSON validation, and controlled release records. Claims remain bounded to specified software behaviour and scoped numerical reproduction. Remaining release work concerns final manuscript and response-ledger review, exact release freezing, version metadata and archival DOI synchronization, and final rendered-package inspection.

## Declaration of competing interest

The author declares no known competing financial interests or personal relationships that could have appeared to influence this work.

## Funding

This work received no specific grant from public, commercial, or not-for-profit funding agencies.

## Data and software availability

The public repository is `https://github.com/PrinceAudre/surt-virtual-rwanda-repro`. The current published software release is version 1.3.0, archived at `https://doi.org/10.5281/zenodo.21840177`. Version 1.4.0 is an unreleased reviewer-remediation target on branch `review/softwarex-resubmission-v1.4.0`; no v1.4.0 version DOI is valid until the exact approved release commit is frozen. The immutable historical version 1.2.0 is archived at `https://doi.org/10.5281/zenodo.21744708`; the release-family concept DOI is `https://doi.org/10.5281/zenodo.21671788`.

## Declaration of generative AI and AI-assisted technologies in the writing process

During preparation, the author used OpenAI ChatGPT and Codex and Anthropic Claude for coding assistance, critical review, and language editing. The author reviewed and edited all outputs, reran the reported checks, verified cited facts and licences, and takes full responsibility for the software and manuscript. These tools did not generate source data or empirical results.

## References

[1] C. Funk, P. Peterson, M. Landsfeld, et al., The climate hazards infrared precipitation with stations: a new environmental record for monitoring extremes, Scientific Data 2 (2015) 150066. https://doi.org/10.1038/sdata.2015.66.

[2] J. Muñoz-Sabater, E. Dutra, A. Agustí-Panareda, et al., ERA5-Land: a state-of-the-art global reanalysis dataset for land applications, Earth System Science Data 13 (2021) 4349–4383. https://doi.org/10.5194/essd-13-4349-2021.

[3] K. Didan, MOD13A3 MODIS/Terra Vegetation Indices Monthly L3 Global 1 km SIN Grid V061, NASA EOSDIS Land Processes DAAC (2021). https://doi.org/10.5067/MODIS/MOD13A3.061.

[4] A.D. Nobre, L.A. Cuartas, M. Hodnett, et al., Height Above the Nearest Drainage: a hydrologically relevant new terrain model, Journal of Hydrology 404 (2011) 13–29. https://doi.org/10.1016/j.jhydrol.2011.03.051.

[5] N. Gorelick, M. Hancher, M. Dixon, et al., Google Earth Engine: planetary-scale geospatial analysis for everyone, Remote Sensing of Environment 202 (2017) 18–27. https://doi.org/10.1016/j.rse.2017.06.031.

[6] L. Busetto, L. Ranghetti, MODIStsp: an R package for automatic preprocessing of MODIS Land Products time series, Computers & Geosciences 97 (2016) 40–48. https://doi.org/10.1016/j.cageo.2016.08.020.

[7] D. Baston, exactextractr: Fast Extraction from Raster Datasets using Polygons, R package (2025). https://doi.org/10.32614/CRAN.package.exactextractr.

[8] M.D. Wilkinson, M. Dumontier, I.J. Aalbersberg, et al., The FAIR Guiding Principles for scientific data management and stewardship, Scientific Data 3 (2016) 160018. https://doi.org/10.1038/sdata.2016.18.

[9] T. Lebo, S. Sahoo, D. McGuinness (Eds.), PROV-O: The PROV Ontology, W3C Recommendation (2013).

[10] S. Soiland-Reyes, P. Sefton, M. Crosas, et al., Packaging research artefacts with RO-Crate, Data Science 5 (2022) 97–138. https://doi.org/10.3233/DS-210053.

[11] A. Dasgupta, I. Perez-Fernandez, T. Huynh, et al., Scalable, open-access and multidisciplinary data integration pipeline for climate-sensitive diseases, Wellcome Open Research 10 (2025) 467. https://doi.org/10.12688/wellcomeopenres.24774.3.

## Current code version

| Nr. | Code metadata description | Metadata |
|---|---|---|
| C1 | Current published code version | 1.3.0; v1.4.0 is the unreleased reviewer-remediation target |
| C2 | Permanent link to published code version | https://github.com/PrinceAudre/surt-virtual-rwanda-repro/tree/v1.3.0 |
| C3 | Permanent link to published reproducible capsule | https://doi.org/10.5281/zenodo.21840177 |
| C4 | Legal code licence | MIT License |
| C5 | Code versioning system used | Git |
| C6 | Software code languages, tools and services used | R, Python, Snakemake, terra, sf, exactextractr, jsonlite, GitHub Actions, Zenodo |
| C7 | Compilation requirements, operating environments and dependencies | R 4.6.0; Python 3; locked R packages in `renv.lock`; GDAL, GEOS, PROJ and UDUNITS; full reproducibility CI on Ubuntu; core smoke CI on Ubuntu 24.04, Windows 2025, and macOS 14 |
| C8 | Developer documentation/manual | README.md, REPRODUCIBILITY.md, DATA_DICTIONARY.md, NOTICE.md, CONTRIBUTING.md, docs/CONFIGURATION_AND_ADAPTERS.md |
| C9 | Support email for questions | priplee@gmail.com |

## Figure captions

**Fig. 1.** SuRT-GeoHarmonizer architecture. Provider preparation is separated from declarative configuration and adapters, source-specific transformation, surface-area-weighted administrative harmonization, provenance controls, executable verification, and release archival.

**Fig. 2.** Published v1.3 Rwanda reference implementation. District-level annual rainfall, mean temperature, mean NDVI, and HAND share at or below 5 m are descriptive environmental layers and are not validated hazards or operational outputs.
