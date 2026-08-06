# SuRT-GeoHarmonizer: An auditable R and Python workflow for administrative-scale Earth-data harmonization and provenance labelling

**TUYISHIME AUDRE PRINCE**

Independent Researcher, Kigali, Rwanda

ORCID: 0009-0002-0799-3140

Corresponding author: TUYISHIME AUDRE PRINCE, priplee@gmail.com

Article type: Original Software Publication

## Abstract

Environmental analyses frequently combine rasters from providers that differ in access methods, coordinate systems, scale factors, no-data conventions, temporal support, and licence terms. These transformations are often distributed across scripts that are difficult to inspect or reuse. SuRT-GeoHarmonizer is an open R and Python command-line workflow that converts environmental rasters and polygon boundaries into consistent, provenance-labelled administrative-unit GeoJSON layers. Its provider-agnostic interface accepts arbitrary identifiers, transformation controls, output bounds, and a human-readable provenance statement. A Rwanda reference implementation prepares CHIRPS rainfall, ERA5-Land temperature, MODIS vegetation greenness, and Height Above Nearest Drainage terrain descriptors for 30 districts. Account-free verification exercises 48 explicit behavioural and contract outcomes covering transformations, arbitrary projected geometry, the generic interface, failure injection, schema enforcement, and corruption rejection. Independent public-data validation reproduced all 30 archived CHIRPS values after rounding; two extraction engines differed by at most 0.000136 mm. The software supports auditable preparation of research covariates and release artifacts. It does not infer hazards, forecasts, epidemiological effects, exposure, or operational recommendations.

**Keywords:** geospatial software; environmental data harmonization; data provenance; zonal statistics; reproducible research; GeoJSON

## 1. Motivation and significance

Earth-observation and environmental research increasingly depend on computational chains that combine observation, reanalysis, vegetation, and terrain products. Even a small administrative-unit dataset may require provider-specific authentication, file acquisition, masking, scaling, temporal aggregation, mosaicking, reprojection, polygon extraction, metadata recording, licence attribution, verification, and archival packaging. CHIRPS precipitation, ERA5-Land temperature, MODIS vegetation indices, and Height Above Nearest Drainage (HAND) illustrate this heterogeneity [1–4].

Mature tools solve important parts of the problem. Google Earth Engine provides catalogue-scale access and computation [5], MODIStsp automates MODIS preparation [6], and `exactextractr` performs efficient polygon extraction [7]. These tools do not, by themselves, define a compact release contract that combines provider-specific transformations, a common administrative schema, explicit provenance, fail-closed evidence status, negative tests, independent output validation, and immutable release records.

SuRT-GeoHarmonizer addresses that integration gap. Its scientific purpose is to make the preparation of administrative environmental covariates inspectable and reusable before those covariates enter downstream statistical, epidemiological, climate, ecological, or planning analyses. The software treats interpretation boundaries as part of the data product: a prepared covariate is not automatically a forecast, hazard probability, causal effect, exposure estimate, or recommendation.

The contribution is software architecture and executable release evidence rather than a new raster algorithm. Rwanda is the real-data reference implementation. Reuse outside Rwanda is supported through a generic raster and polygon interface and an end-to-end arbitrary-geometry example; scientific validation in a second country is not claimed.

## 2. Software description

### 2.1. Architecture

SuRT-GeoHarmonizer separates five concerns (Fig. 1):

1. **Acquisition.** Provider clients retrieve public or credential-controlled products into local, ignored caches.
2. **Transformation.** R modules apply source-specific masking, scaling, mosaicking, temporal aggregation, reprojection, and bounded-value checks.
3. **Administrative harmonization.** The generic interface calculates coverage-fraction-weighted polygon means and writes a restricted WGS84 GeoJSON schema.
4. **Evidence classification.** A fail-closed register treats unknown, incomplete, synthetic, or placeholder material as illustrative unless a documented method applied to real or public data is declared.
5. **Verification and release.** Controlled fixtures, deliberate failure injection, an independent Python validator, checksums, continuous integration, Git tags, and repository archives make specified behaviour and release identity inspectable.

The software uses R for geospatial processing and Python for provider access, orchestration, metadata checks, and a standard-library GeoJSON validator. `renv.lock` records the R dependency graph. Optional Python provider clients are separately pinned so the complete account-free pathway does not require network access or credentials.

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

The interface requires a raster and polygon file with declared coordinate reference systems, valid polygon geometry, and unique non-empty identifiers. Optional arguments select a raster layer, apply scale and offset conversion, mask values outside specified thresholds, round outputs, and enforce minimum or maximum bounds. Extraction geometry is transformed to the raster coordinate system, while output geometry is normalized to EPSG:4326.

The output contains only `unit_id`, the requested measurement property, `provenance`, and geometry. Processing stops when any administrative unit lacks a finite value, an identifier is duplicated, geometry is invalid, a coordinate system is missing, or an output violates a declared bound. The interface validates computational behaviour; users remain responsible for the scientific appropriateness of the source, period, variable, units, scaling, thresholds, and interpretation.

### 2.3. Rwanda reference builders

Four builders demonstrate provider-specific use:

- **Rainfall:** CHIRPS v2.0 annual precipitation. Negative no-data values are masked and district means are rounded to whole millimetres.
- **Temperature:** ERA5-Land monthly mean 2 m temperature. Twelve months are required, averaged, converted from kelvin to degrees Celsius, and aggregated.
- **Vegetation:** MODIS/Terra MOD13A3 v061 monthly NDVI. Fill and out-of-range values are masked, the 0.0001 scale is applied, same-month tiles are mosaicked, and monthly products are averaged.
- **Terrain:** Global 30 m HAND is thresholded at 5 m and expressed as the percentage of each polygon at or below the threshold.

The released data contain one feature for each of Rwanda's 30 districts. District geometry is derived from a World Bank CC BY 4.0 dataset. The code is MIT licensed; source-specific data terms are recorded in `NOTICE.md`.

## 3. Illustrative examples

### 3.1. Account-free arbitrary-region example

`R/test_generic_harmonizer.R` constructs a projected raster and three polygons identified as `ALPHA-01`, `BETA-02`, and `GAMMA-03`. It calls the same public interface documented for users and checks seven outcomes: feature count, identifier preservation, controlled means, allow-listed properties, WGS84 output, complete provenance, and consistency between the returned object and written file. The example demonstrates an end-to-end input and output contract without Rwanda names, provider accounts, private data, or network access.

A separate portability fixture exercises rainfall, temperature, HAND, and MODIS transformations against arbitrary identifiers and projected geometry. This supports function-level geometry and identifier independence but does not establish full scientific portability to every provider tile, geography, or administrative system.

### 3.2. Rwanda environmental layers

The reference implementation produces district rainfall, temperature, NDVI, and low-lying terrain layers (Fig. 2). For example, the Nyarugenge records contain 955 mm annual rainfall, 20.6 °C mean temperature, 0.55 mean NDVI, and a 22.1% HAND share at or below 5 m. The last value is a terrain descriptor, not observed flood extent or flood probability.

### 3.3. Verification and numerical reproduction

The one-command pathway is:

```text
python python/run_all_checks.py
```

It executes 48 explicit outcomes: 9 provenance assertions, 9 controlled environmental transformations, 6 geometry-agnostic transformation assertions, 7 generic-interface assertions, 7 deliberate transformation failures, 5 valid release checks, and 5 controlled corruption rejections. Failure tests cover missing raster coverage, incorrect temperature units, an inverted rainfall gradient, unscaled MODIS values, an incomplete MODIS year, all-no-data HAND input, and impossible percentages.

The independent Python validator does not reuse the R geospatial stack. It checks committed GeoJSON structure, identifiers, properties, finite values, provenance tokens, coordinates, feature order, and geometry identity, then requires rejection of corrupted copies.

CHIRPS has an additional public-data validation. The workflow independently downloads the 2023 annual raster and recomputes district means. All 30 archived whole-millimetre values reproduced exactly after rounding. The maximum difference between `exactextractr` and `terra::extract` was 0.000136 mm, and adding cell-area weights changed district means by at most 0.005127 mm. This establishes computational reproduction for that source, year, and geometry, not CHIRPS observational accuracy. ERA5-Land, MODIS, and HAND have not received equivalent independent numerical validation.

## 4. Impact

SuRT-GeoHarmonizer is intended for researchers who need transparent administrative covariates but do not want provider-specific implementation details dispersed across notebooks and undocumented scripts. Potential applications include climate-health studies, ecological analyses, agricultural monitoring, environmental exposure research, and public-sector data preparation. The generic interface can be used for any polygon-supported raster mean where the user can specify scientifically appropriate transformation and provenance information.

The software contributes four reusable practices. First, provider acquisition is separated from transformation and output contracts, allowing account-free review of core behaviour. Second, provenance is carried into each released feature rather than existing only in narrative documentation. Third, positive fixtures are paired with deliberate failures and independent release validation. Fourth, release metadata and checksums make it possible to identify the exact code and data artifact used in a study.

FAIR principles emphasize findability, accessibility, interoperability, and reuse [8]. W3C PROV and RO-Crate provide richer formal models for provenance and research objects [9,10]. SuRT-GeoHarmonizer does not claim conformance to those standards; it offers a lightweight implementation that can later be mapped to them. The repository includes machine-readable CFF and CodeMeta records, locked dependencies, a contribution policy, documented licences, and continuous integration.

The principal limitations are deliberate. Only Ubuntu Linux is continuously validated. ERA5-Land and MODIS acquisition require free provider accounts. Administrative annual means suppress seasonality, extremes, and within-unit heterogeneity. MODIS quality flags are not applied in the current reference builder. The HAND threshold has not been validated as a hazard indicator. The generic example is synthetic, and only CHIRPS has an independent public-data numerical cross-check.

## 5. Conclusions

SuRT-GeoHarmonizer packages heterogeneous environmental raster preparation as a reusable, provenance-labelled administrative-data workflow. A generic command-line interface, provider-specific reference builders, fail-closed evidence classification, account-free verification, deliberate failure tests, independent GeoJSON validation, and controlled release records make the software suitable for transparent research-covariate preparation. Its claims remain bounded to specified software behaviour and scoped numerical reproduction. Future development will add provider adapters, formal provenance exports, broader operating-system testing, MODIS quality filtering, and independent validation of additional reference layers.

## Declaration of competing interest

The author declares no known competing financial interests or personal relationships that could have appeared to influence this work.

## Funding

This work received no specific grant from public, commercial, or not-for-profit funding agencies.

## Data and software availability

The public repository is `https://github.com/PrinceAudre/surt-virtual-rwanda-repro`. The active SoftwareX candidate is version 1.3.0 on branch `codex/softwarex-submission-v1.3.0`. The immutable historical version 1.2.0 is archived at `https://doi.org/10.5281/zenodo.21744708`; the concept DOI is `https://doi.org/10.5281/zenodo.21671788`. The final SoftwareX submission will cite the version-specific archive created from the exact validated `v1.3.0` tag.

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
| C1 | Current code version | 1.3.0 |
| C2 | Permanent link to code/repository used for this code version | https://github.com/PrinceAudre/surt-virtual-rwanda-repro/tree/codex/softwarex-submission-v1.3.0 |
| C3 | Permanent link to reproducible capsule | Account-free reproduction is provided by the repository, `renv.lock`, GitHub Actions, and the final Zenodo version archive |
| C4 | Legal code licence | MIT License |
| C5 | Code versioning system used | Git |
| C6 | Software code languages, tools and services used | R, Python, terra, sf, exactextractr, jsonlite, GitHub Actions, Zenodo |
| C7 | Compilation requirements, operating environments and dependencies | R 4.6.0; Python 3; locked R packages in `renv.lock`; GDAL, GEOS, PROJ and UDUNITS; Ubuntu Linux continuously validated |
| C8 | Developer documentation/manual | README.md, REPRODUCIBILITY.md, DATA_DICTIONARY.md, NOTICE.md, CONTRIBUTING.md |
| C9 | Support email for questions | priplee@gmail.com |

## Figure captions

**Fig. 1.** SuRT-GeoHarmonizer architecture. Provider acquisition is separated from source-specific transformation, generic administrative harmonization, provenance classification, verification, and release archival.

**Fig. 2.** Rwanda reference implementation. District-level annual rainfall, mean temperature, mean NDVI, and HAND share at or below 5 m are descriptive environmental layers and are not validated hazards or operational outputs.
