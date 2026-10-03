# SuRT-GeoHarmonizer: An auditable R and Python workflow for administrative-scale Earth-data harmonization and provenance labelling

**TUYISHIME AUDRE PRINCE**

Independent Researcher, Kigali, Rwanda

ORCID: 0009-0002-0799-3140

Corresponding author: TUYISHIME AUDRE PRINCE, priplee@gmail.com

Article type: Original Software Publication

## Abstract

Environmental analyses frequently combine rasters that differ in access methods, coordinate systems, scale factors, no-data conventions, temporal support, quality controls, and licence terms. SuRT-GeoHarmonizer is an open R and Python workflow that converts environmental rasters and polygon boundaries into provenance-labelled administrative-unit GeoJSON. The v1.4 reviewer-remediation code adds surface-area-weighted zonal aggregation, separate raster-footprint and finite-data coverage fields, a fail-closed declarative JSON job contract, a provider-adapter boundary, and a Snakemake evidence workflow. A Rwanda reference implementation contains CHIRPS rainfall, ERA5-Land temperature, MODIS vegetation greenness, and Height Above Nearest Drainage terrain builders for 30 districts. Account-free verification dynamically exercises transformations, configuration, arbitrary projected geometry, deliberate failures, release contracts, and a source-derived Uganda boundary paired with a deterministic synthetic raster. That Uganda case demonstrates cross-country geometry and identifier portability, not scientific validation of an environmental product for Uganda. Published CHIRPS validation reproduced all 30 archived district values after rounding, with a maximum cross-engine difference of 0.000136 mm. The software supports auditable preparation of research covariates while explicitly excluding hazard, forecast, epidemiological, exposure, and operational interpretations.

**Keywords:** geospatial software; environmental data harmonization; data provenance; zonal statistics; reproducible research; GeoJSON

## 1. Motivation and significance

Earth-observation and environmental research increasingly depend on computational chains that combine observation, reanalysis, vegetation, and terrain products. Even a small administrative-unit dataset may require provider-specific authentication, file acquisition, masking, scaling, quality filtering, temporal aggregation, mosaicking, reprojection, polygon extraction, metadata recording, licence attribution, verification, and archival packaging. CHIRPS precipitation, ERA5-Land temperature, MODIS vegetation indices, and Height Above Nearest Drainage (HAND) illustrate this heterogeneity [1–4].

Mature tools solve important parts of the problem. Google Earth Engine provides catalogue-scale access and computation [5], MODIStsp automates MODIS preparation [6], and `exactextractr` performs efficient polygon extraction [7]. These tools do not, by themselves, define a compact release contract that combines provider-specific transformations, a common administrative schema, explicit provenance, fail-closed configuration and evidence status, negative tests, independent output validation, and immutable release records.

SuRT-GeoHarmonizer addresses that integration gap. Its purpose is to make preparation of administrative environmental covariates inspectable and reusable before those covariates enter downstream statistical, epidemiological, climate, ecological, or planning analyses. A prepared covariate is not automatically a forecast, hazard probability, causal effect, exposure estimate, or recommendation.

The contribution is software architecture and executable release evidence rather than a new raster algorithm. Rwanda is the real-data reference implementation. Reuse outside Rwanda is supported through a generic raster and polygon interface, a declarative configuration contract, an adapter extension boundary, controlled arbitrary-geometry tests, and a real Uganda boundary portability gate. Scientific validation in a second country is not claimed.

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

`config/harmonization-job.schema.json` defines schema version 1.0 and rejects unknown top-level and nested fields. `python/run_configured_harmonization.py` validates the configuration and adapter before mapping its declared controls to the generic R harmonizer. The bundled `local_raster` adapter accepts an already prepared raster and rejects undeclared provider-specific QA. External providers can implement the same adapter protocol without modifying the generic R engine.

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

`R/test_second_country_portability.R` adds a source-derived Uganda national boundary to the portability evidence. It pairs that real non-Rwanda geometry with a deterministic synthetic raster, invokes the same generic harmonizer, and checks identifier preservation, geometry preservation, coverage, bounded output, and provenance. The result supports geometry and identifier portability across a real second-country boundary. It is not source-derived environmental evidence for Uganda and does not establish scientific portability of provider products.

### 3.2. Rwanda environmental layers

The published reference release contains district rainfall, temperature, NDVI, and low-lying terrain layers (Fig. 2). For example, the archived Nyarugenge records contain 955 mm annual rainfall, 20.6 °C mean temperature, 0.55 mean NDVI, and a 22.1% HAND share at or below 5 m. These are descriptive reference artifacts. The HAND value is not observed flood extent or flood probability, and the archived v1.3 values must not be represented as automatically recalculated v1.4 outputs.

### 3.3. Verification and numerical reproduction

The one-command development pathway is:

```text
python python/run_all_checks.py
```

The runner derives outcome counts from executable output rather than a manually maintained assertion total. It covers provenance classification, controlled environmental transformations, projected portability, the Uganda-boundary gate, the generic interface, configuration and adapter validation, area weighting and coverage, ERA5 annual statistics, MODIS QA, HAND denominator behaviour, deliberate failures, release-contract checks, and remediation metadata. A frozen candidate additionally runs `python python/run_all_checks.py --verify-manifest`. The Snakemake DAG is executed independently in continuous integration.

CHIRPS has a published public-data validation baseline. Reacquisition of the 2023 annual raster reproduced all 30 archived whole-millimetre district values after rounding. The maximum `exactextractr` versus `terra::extract` difference was 0.000136 mm, and adding cell-area weights changed district means by at most 0.005127 mm. This establishes computational reproduction for that source, year, and Rwanda geometry, not CHIRPS observational accuracy. Equivalent independent v1.4 numerical validation for ERA5-Land, MODIS, and HAND remains a release gate.

## 4. Impact

SuRT-GeoHarmonizer is intended for researchers who need transparent administrative covariates but do not want provider-specific implementation details dispersed across notebooks and undocumented scripts. Potential applications include climate-health studies, ecological analyses, agricultural monitoring, environmental exposure research, and public-sector data preparation. The generic interface can be used for polygon-supported raster means when the user supplies scientifically appropriate transformation and provenance information.

The software contributes four reusable practices. First, provider preparation is separated from the generic harmonization contract, and the adapter boundary permits additional providers without changing the R engine. Second, declarative configuration and a workflow DAG make the execution contract machine-readable and testable. Third, positive fixtures are paired with deliberate failures, real-boundary portability evidence, and independent release validation. Fourth, provenance, metadata, checksums, and versioned archives make the released artifact identifiable.

FAIR principles emphasize findability, accessibility, interoperability, and reuse [8]. W3C PROV and RO-Crate provide richer formal models for provenance and research objects [9,10]. SuRT-GeoHarmonizer does not claim conformance to those standards; it provides lightweight human-readable provenance and machine-readable software metadata that could later be mapped to them.

Limitations remain explicit. Hosted continuous integration currently validates Ubuntu Linux only. The built-in adapter accepts a prepared local raster rather than implementing production acquisition and QA for every provider. ERA5-Land and MODIS rebuilds require provider accounts. The Uganda portability case uses a real boundary but a synthetic signal. Independent v1.4 numerical validation is still required for ERA5-Land, MODIS, and HAND. Administrative annual summaries suppress seasonality, extremes, and within-unit heterogeneity. MODIS QA filtering changes spatial and temporal support, so coverage is part of the result. HAND at or below 5 m is a static terrain descriptor, not a validated hazard indicator.

## 5. Conclusions

SuRT-GeoHarmonizer packages heterogeneous raster preparation as an auditable administrative-data workflow. The reviewer-remediation code now combines a generic command-line interface, explicit surface-area and coverage semantics, a declarative JSON contract, a provider-adapter boundary, Snakemake orchestration evidence, fail-closed classification, account-free verification, real-boundary portability testing, independent GeoJSON validation, and controlled release records. Claims remain bounded to specified software behaviour and scoped numerical reproduction. Remaining release work concerns independent validation of revised real-data products, any reviewer-required source-derived second-country product case, supported-platform evidence, final manuscript and response-ledger review, and exact release freezing.

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

## Current code version

| Nr. | Code metadata description | Metadata |
|---|---|---|
| C1 | Current published code version | 1.3.0; v1.4.0 is the unreleased reviewer-remediation target |
| C2 | Permanent link to published code version | https://github.com/PrinceAudre/surt-virtual-rwanda-repro/tree/v1.3.0 |
| C3 | Permanent link to published reproducible capsule | https://doi.org/10.5281/zenodo.21840177 |
| C4 | Legal code licence | MIT License |
| C5 | Code versioning system used | Git |
| C6 | Software code languages, tools and services used | R, Python, Snakemake, terra, sf, exactextractr, jsonlite, GitHub Actions, Zenodo |
| C7 | Compilation requirements, operating environments and dependencies | R 4.6.0; Python 3; locked R packages in `renv.lock`; GDAL, GEOS, PROJ and UDUNITS; Ubuntu Linux continuously validated |
| C8 | Developer documentation/manual | README.md, REPRODUCIBILITY.md, DATA_DICTIONARY.md, NOTICE.md, CONTRIBUTING.md |
| C9 | Support email for questions | priplee@gmail.com |

## Figure captions

**Fig. 1.** SuRT-GeoHarmonizer architecture. Provider preparation is separated from declarative configuration and adapters, source-specific transformation, surface-area-weighted administrative harmonization, provenance controls, executable verification, and release archival.

**Fig. 2.** Published v1.3 Rwanda reference implementation. District-level annual rainfall, mean temperature, mean NDVI, and HAND share at or below 5 m are descriptive environmental layers and are not validated hazards or operational outputs.
