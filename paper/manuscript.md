# A reproducible R workflow for district-level environmental layers with fail-closed provenance labelling: a Rwanda implementation

**Tuyishime Audre Prince**

Independent researcher, Kigali, Rwanda

ORCID: 0009-0002-0799-3140

Corresponding author: Tuyishime Audre Prince, priplee@gmail.com

Article type: Software Tool Article

## Abstract

**Background:** Climate-sensitive health research commonly requires environmental products to be acquired from different providers, transformed from product-specific formats, summarized to administrative units, and documented well enough for later audit. Existing platforms and packages solve important parts of this process, but the complete path from source acquisition to an archived, provenance-labelled district dataset is often assembled ad hoc.

**Methods:** We developed an open, repository-based workflow for Rwanda's 30 districts. The workflow prepares annual rainfall, mean temperature, mean Normalized Difference Vegetation Index (NDVI), and a static low-lying terrain share from CHIRPS, ERA5-Land, MODIS, and Height Above Nearest Drainage (HAND) products. It combines product-specific transformations, coverage-fraction-weighted zonal extraction, standardized GeoJSON output, explicit source and licence metadata, and a fail-closed provenance contract that labels unknown, incomplete, synthetic, or placeholder entries as illustrative. A hermetic synthetic fixture exercises the released transformation paths without private files or provider credentials.

**Results:** The archived release contains one value for each of Rwanda's 30 districts in every environmental layer. The 2023 district ranges are 917-1,489 mm annual rainfall, 15.7-21.9 degrees Celsius mean temperature, and 0.49-0.71 mean NDVI; the static share of district area with HAND of 5 m or less is 8.6%-31.8%. The release passes nine provenance assertions, nine environmental-fixture assertions, and 41 SHA-256 integrity checks in continuous integration.

**Conclusions:** The workflow provides a compact, inspectable route from heterogeneous environmental products to provenance-labelled district outputs. Its contribution is the integration of multi-provider preprocessing, administrative aggregation, fail-closed evidence classification, account-free software verification, and a versioned research archive. It produces descriptive environmental layers, not epidemiological effects, forecasts, hazard probabilities, or operational recommendations.

**Keywords:** environmental data preparation; data provenance; zonal statistics; geospatial software; reproducible research; Rwanda; R

## Introduction

Rainfall, temperature, vegetation, and terrain are frequently used as environmental covariates in climate-sensitive health research and early-warning analyses [1-3]. Rwanda-specific studies have examined climatic factors associated with malaria incidence and projected changes in malaria transmission suitability [4,5]. Systems such as EPIDEMIA demonstrate how surveillance and environmental inputs may later be combined for outbreak detection and forecasting [6]. Before such modelling can be credible, however, environmental inputs must be acquired, transformed, summarized, and documented consistently.

Mature tools already address major parts of this problem. Google Earth Engine provides cloud-based, planetary-scale geospatial analysis [7]. MODIStsp automates downloading and preprocessing of MODIS products [8]. The R package `exactextractr` provides efficient polygon-based extraction and zonal summaries [9]. These tools are complementary rather than interchangeable. They do not, by themselves, define a small cross-provider release contract that standardizes district outputs, records per-file provenance and licence terms, prevents unknown values from being presented as source-derived, supplies an account-free reviewer fixture, and archives the exact software version with integrity checks.

The practical gap addressed here is therefore not a new raster algorithm. It is a reproducible assembly pattern for research teams that need a reviewable chain from heterogeneous products to administrative-unit layers, while keeping illustrative values visibly distinct from source-derived evidence. FAIR principles emphasize rich metadata and reuse [10], and provenance-driven workflow systems demonstrate the value of traceable processing [11]. The present workflow applies those principles in a deliberately compact R and Python repository that a reviewer can inspect, test, and cite.

The released workflow originated as the environmental-data and provenance layer of a larger private prototype. The public artifact is self-contained and excludes the private dashboard, disease-side signals, operational interfaces, patient data, surveillance data, and decision rules. This article evaluates only the released software and its prepared environmental outputs.

## Methods

### Software design and contribution

The repository integrates five functions that are commonly separated across scripts or platforms:

1. provider-specific acquisition and input handling;
2. reproducible transformation of rainfall, temperature, NDVI, and HAND products;
3. district-level aggregation into a common GeoJSON schema;
4. fail-closed provenance labelling and per-file licence documentation; and
5. account-free software verification plus release-integrity checks.

The first three functions create descriptive environmental layers. The fourth governs interpretation: a value is accepted as `source-derived` only when its register entry declares a documented method applied to real or public data. Any unknown, incomplete, synthetic, or placeholder entry is labelled illustrative. The fifth makes the core transformation and classification paths assessable without requiring a reviewer to possess provider credentials.

The workflow does not replace Google Earth Engine, MODIStsp, or `exactextractr`. Google Earth Engine is a large cloud analysis platform; MODIStsp is specialized for MODIS acquisition and preprocessing; and `exactextractr` is used here as the zonal-extraction engine. The additional contribution is the release-level integration around these capabilities: multiple environmental providers, a common district schema, an explicit interpretation contract, hermetic tests, per-file terms, fixed checksums, and a Zenodo archive.

### Geographic frame

The aggregation frame comprises Rwanda's 30 second-level administrative districts. District geometry is derived from the World Bank Rwanda Admin Boundaries and Villages dataset under Creative Commons Attribution 4.0. All released geometry is stored in EPSG:4326. The boundary file contains district name and geometry only.

### Environmental transformations

Three layers describe calendar year 2023 and one represents static terrain:

- **Rainfall:** CHIRPS version 2.0 annual precipitation [12]. Negative no-data values are masked. The district mean is rounded to whole millimetres.
- **Temperature:** ERA5-Land 2 m air temperature [13]. Twelve monthly-mean layers for 2023 are checked for completeness, averaged, converted from kelvin to degrees Celsius, and summarized by district.
- **Vegetation greenness:** MODIS/Terra MOD13A3 version 061 monthly 1 km NDVI [14]. Fill and out-of-range values are masked, the 0.0001 scale factor is applied, monthly tiles are mosaicked, and an annual mean is summarized by district. Product quality and reliability flags are not applied in this release.
- **Low-lying terrain share:** Global 30 m HAND, derived from Copernicus GLO-30, is thresholded at 5 m. The output is the percentage of district area at or below that relative-elevation threshold. It is not observed flooding or a validated flood-hazard probability. The terrain concept follows Nobre et al. [15].

District values are calculated with `exactextractr`, using the fraction of each raster cell covered by a district polygon as the aggregation weight. For rasters in geographic coordinates this is coverage-fraction weighting, not exact surface-area weighting. Product no-data sentinels are masked before aggregation, and a build stops when any district lacks a valid value.

Each builder applies bounded-value and broad directional consistency gates intended to detect gross unit, coordinate-system, threshold, or inversion errors. For example, the released test checks that the western longitudinal third is cooler than the eastern third. These gates are software tripwires; they are not substitutes for independent numerical validation.

### Provenance-labelling contract

The provenance module consumes a register row containing an identifier, display label, method, palette, evidence class, method class, and citation. The contract is:

- `source-derived` requires a documented method applied to real or public data;
- a placeholder method cannot be `source-derived`;
- unknown, incomplete, synthetic, and placeholder entries default to `illustrative`; and
- illustrative outputs receive an explanatory note.

This is a fail-closed classification rule. The module validates declarations and presentation behaviour. It does not independently verify whether a citation is correct, whether every external application routes values through the module, or whether the declared method was implemented faithfully outside the released repository.

### Input and output contract

The real builders accept a period or threshold plus optional paths for output, aggregation geometry, and local cache. The default outputs are written to `generated/`; provider downloads are cached under `cache/`. Both directories are excluded from version control.

Each released environmental output is a GeoJSON FeatureCollection with 30 district features. A feature contains the district identifier, one environmental value, geometry, and a provenance string naming the source, product, period or threshold, and applicable terms. `DATA_DICTIONARY.md` defines the fields, while `NOTICE.md` records attribution and licence information.

### Reproducibility and verification

`renv.lock` records the R dependency graph. The archived release was prepared with R 4.6.0, `terra` 1.9.27, `sf` 1.1.1, `exactextractr` 0.10.1, and `jsonlite` 2.0.0. Python 3 is used by provider fetchers and by the cross-platform verification runner. No specialized hardware is required.

The account-free verification command is:

```text
python python/run_all_checks.py
```

It runs the nine-assertion provenance demonstration, a nine-assertion environmental fixture, and verification of all files listed in `CHECKSUMS.sha256`. The fixture creates synthetic rasters in memory and exercises the released rainfall, temperature, NDVI, HAND, reprojection, mosaic, temporal-summary, zonal-extraction, and GeoJSON-writing paths. Its NDVI path uses two synthetic months and two same-month tiles in the MODIS sinusoidal coordinate system.

The fixture verifies software behaviour, not the numerical accuracy of the archived 2023 source-derived values. GitHub Actions restores the locked environment and repeats the same account-free command on a clean hosted runner.

### Real-data operation

The four real builders can be invoked from any working directory:

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

The CHIRPS and HAND builders require network access. ERA5-Land and MODIS additionally require free Copernicus Climate Data Store and NASA Earthdata accounts. Credentials are read from provider-standard local files and are not stored in the repository.

## Results

### Prepared district layers

Each environmental output contains one feature for every district. Table 1 summarizes the released values. The western longitudinal third was cooler than the eastern third (17.5 versus 21.1 degrees Celsius) and had a smaller low-lying terrain share (14.6% versus 22.8%). These comparisons passed the released directional gates.

For a concrete output example, the released Nyarugenge records contain annual rainfall of 955 mm, mean temperature of 20.6 degrees Celsius, mean NDVI of 0.55, and a low-lying terrain share of 22.1%. The last value means that 22.1% of the district polygon is represented by HAND values of 5 m or less. It must not be interpreted as observed flood extent, flood probability, or exposure.

### Verification results

The provenance demonstration passes nine assertions covering register structure, rejection of source-derived placeholder combinations, default illustrative treatment of synthetic and unknown identifiers, explanatory-note behaviour, and palette and quantile helper behaviour.

The environmental fixture passes nine assertions covering expected zonal means, bounded and directional gates, the HAND threshold calculation, the complete multi-month and multi-tile MODIS transformation to EPSG:4326, and creation of an inspectable GeoJSON. The release runner also verifies 41 SHA-256 file digests.

Table 2 distinguishes the workflow from adjacent tools, while Table 3 maps the principal software claims to released evidence. This claim-to-evidence structure is intended to make the article assessable without relying on the unreleased parent prototype.

## Use cases

### Reproducible preparation of research covariates

A public-health analyst needs annual district-level environmental context for a descriptive analysis or as candidate covariates in a later model. The analyst runs the builders or reads the archived layers, obtains a standardized value per district, and retains the provenance string and per-file terms. Subsequent epidemiological modelling remains a separate analytical step with its own design, validation, and ethics requirements.

A supported statement is: "Nyarugenge's prepared 2023 annual-rainfall layer contains 955 mm." Unsupported statements include claims about disease causation, future weather, flood risk, resource allocation, or intervention effectiveness.

### Audit-safe demonstrations and prototypes

A developer is preparing a dashboard or teaching example that mixes real environmental context with synthetic demonstration indicators. The developer routes registered values through the provenance module. Source-derived entries retain that label only when the required declarations are complete; unknown or synthetic entries remain illustrative and receive a visible note. This reduces the risk that placeholder values are mistaken for empirical evidence during demonstrations.

## Discussion

The workflow's main contribution is integration rather than a new numerical algorithm. It combines multi-provider preprocessing, district aggregation, standardized outputs, explicit data terms, fail-closed provenance labelling, a locked environment, an account-free fixture, continuous integration, and an immutable research archive. This combination is useful where a research team needs a compact artifact that can be inspected and cited independently of a larger application.

The design also makes the boundary between verification and validation explicit. The tests establish that specified transformations, classification rules, output schemas, and integrity checks behave as expected on controlled inputs. They do not establish that the environmental products are error-free, that the selected HAND threshold represents hazard, or that the prepared values are appropriate for a particular epidemiological model. Independent spot checks and sensitivity analyses should be added when the layers are used for substantive inference.

The present release has additional limitations. Annual district summaries suppress seasonality, extremes, and within-district heterogeneity. MODIS quality flags are not applied. Coverage-fraction weighting in geographic coordinates differs from true area weighting. Provider-dependent builds require accounts and network access, so only the fixture pathway is fully account-free. Table 4 summarizes these limitations and the corresponding interpretation.

Future development should add product-quality flags, seasonal and monthly summaries, uncertainty and data-quality fields, selected external-value comparisons, and an independent rerun of the provider-dependent pathway. These additions would strengthen data validation without changing the core provenance and release contract.

## Conclusions

The released workflow converts four heterogeneous environmental products into standardized, provenance-labelled layers for Rwanda's 30 districts and packages the process as a testable, versioned research artifact. It is suited to transparent preparation of descriptive environmental inputs and to applications that must distinguish source-derived evidence from illustrative content. It is not an epidemiological model, forecasting platform, hazard model, or operational decision system.

## Ethics and consent

No human participants, animals, patient records, personal data, confidential records, or real surveillance data were used. The public artifact contains openly available environmental products and synthetic software-test fixtures. Ethical approval and consent were therefore not required.

## Data availability

Prepared outputs and the exact software release are archived in Zenodo version 1.1.1 [16]. The archive contains:

- `relief_districts.geojson`: World Bank district geometry, CC BY 4.0;
- `relief_climate_rainfall.geojson`: CHIRPS version 2.0 annual precipitation, public domain/CC0;
- `relief_climate_temp.geojson`: ERA5-Land monthly-mean temperature, Copernicus Products licence;
- `relief_climate_ndvi.geojson`: MODIS MOD13A3 version 061 annual-mean NDVI, CC0; and
- `relief_low_lying_hand.geojson`: Global 30 m HAND threshold share, CC0.

GeoJSON is an open format. `NOTICE.md` supplies per-file attribution and licence information, `DATA_DICTIONARY.md` defines fields, and `CHECKSUMS.sha256` supplies integrity values. No disease data are associated with the article.

ERA5-Land is third-party data under the Copernicus Products licence. A reader can obtain it through the same route as the author by creating a free Climate Data Store account, accepting the product terms, configuring the official `cdsapi` client, and running `python/fetch_era5land_temperature.py`. The corresponding transformation is implemented in `R/build_relief_climate_temperature.R`.

## Software availability

Software available from: https://github.com/PrinceAudre/surt-virtual-rwanda-repro

Source code available from: https://github.com/PrinceAudre/surt-virtual-rwanda-repro

Archived source code: Tuyishime AP. SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.1.1. Zenodo. 2026. https://doi.org/10.5281/zenodo.21677162 [Software] [16].

Licence: MIT for code. Data retain the per-file terms listed in the Data availability section and `NOTICE.md`.

## Author contributions

Tuyishime Audre Prince: Conceptualization, Data Curation, Methodology, Software, Validation, Visualization, Project Administration, Writing - Original Draft, and Writing - Review and Editing.

## Competing interests

The author has undertaken contractual research coordination work for the Clinton Health Access Initiative. The software and manuscript are presented in the author's independent capacity and do not imply institutional sponsorship or endorsement.

## Grant information

The author declared that no grants were involved in supporting this work.

## Acknowledgments

Generative AI tools were used for coding assistance, repository-quality checks, critical appraisal, and language editing. The author directed these uses, reviewed the outputs against the released files and primary sources, reran the reported checks, and accepts responsibility for the article. No AI tool generated the source environmental products or the reported district values.

## References

1. Mategula D, Gichuki J, Barnes KI, Giorgi E, Terlouw DJ. Advancing early warning systems for malaria: progress, challenges, and future directions - a scoping review. PLOS Global Public Health. 2025;5:e0003751. doi:10.1371/journal.pgph.0003751.
2. Delight EA, Brunn AA, Ruiz F, et al. Gaps and opportunities for data systems and economics to support priority setting for climate-sensitive infectious diseases in sub-Saharan Africa: a rapid scoping review. PLOS Global Public Health. 2025;5:e0003814. doi:10.1371/journal.pgph.0003814.
3. Pham CT, Nguyen HT, Le HHTC, et al. Challenges and strategies for the development and implementation of climate-informed early warning systems for vector-borne diseases: a systematic review. Tropical Medicine & International Health. 2025;31:10-21. doi:10.1111/tmi.70045.
4. Rubuga FK, Ahmed A, Siddig E, et al. Potential impact of climatic factors on malaria in Rwanda between 2012 and 2021: a time-series analysis. Malaria Journal. 2024;23:274. doi:10.1186/s12936-024-05097-5.
5. Zong L, Ngarukiyimana JP, Yang Y, et al. Malaria transmission risk is projected to increase in the highlands of Western and Northern Rwanda. Communications Earth & Environment. 2024;5:559. doi:10.1038/s43247-024-01717-9.
6. Merkord CL, Liu Y, Mihretie A, et al. Integrating malaria surveillance with climate data for outbreak detection and forecasting: the EPIDEMIA system. Malaria Journal. 2017;16:89. doi:10.1186/s12936-017-1735-x.
7. Gorelick N, Hancher M, Dixon M, Ilyushchenko S, Thau D, Moore R. Google Earth Engine: planetary-scale geospatial analysis for everyone. Remote Sensing of Environment. 2017;202:18-27. doi:10.1016/j.rse.2017.06.031.
8. Busetto L, Ranghetti L. MODIStsp: an R package for automatic preprocessing of MODIS Land Products time series. Computers & Geosciences. 2016;97:40-48. doi:10.1016/j.cageo.2016.08.020.
9. Baston D. exactextractr: fast extraction from raster datasets using polygons. R package version 0.10.1. doi:10.32614/CRAN.package.exactextractr.
10. Wilkinson MD, Dumontier M, Aalbersberg IJ, et al. The FAIR Guiding Principles for scientific data management and stewardship. Scientific Data. 2016;3:160018. doi:10.1038/sdata.2016.18.
11. Mitchell SN, et al. FAIR data pipeline: provenance-driven data management for traceable scientific workflows. Philosophical Transactions of the Royal Society A. 2022;380:20210300. doi:10.1098/rsta.2021.0300.
12. Funk C, Peterson P, Landsfeld M, Pedreros D, Verdin J, Shukla S, et al. The climate hazards infrared precipitation with stations - a new environmental record for monitoring extremes. Scientific Data. 2015;2:150066. doi:10.1038/sdata.2015.66.
13. Munoz-Sabater J, Dutra E, Agusti-Panareda A, Albergel C, Arduini G, Balsamo G, et al. ERA5-Land: a state-of-the-art global reanalysis dataset for land applications. Earth System Science Data. 2021;13:4349-4383. doi:10.5194/essd-13-4349-2021.
14. Didan K. MODIS/Terra Vegetation Indices Monthly L3 Global 1 km SIN Grid V061 [Dataset]. NASA EOSDIS Land Processes Distributed Active Archive Center; 2021. doi:10.5067/MODIS/MOD13A3.061.
15. Nobre AD, Cuartas LA, Hodnett M, Renno CD, Rodrigues G, Silveira A, et al. Height Above the Nearest Drainage - a hydrologically relevant new terrain model. Journal of Hydrology. 2011;404:13-29. doi:10.1016/j.jhydrol.2011.03.051.
16. Tuyishime AP. SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.1.1. Zenodo. 2026. doi:10.5281/zenodo.21677162 [Software].

## Tables

### Table 1. Per-district summaries across Rwanda's 30 districts

| Layer | Field | Minimum | Maximum | Mean | Temporal basis |
|---|---|---:|---:|---:|---|
| Rainfall | `annual_rainfall_mm` | 917 | 1,489 | 1,163 | CHIRPS v2.0 annual total, 2023 |
| Temperature | `mean_temp_c` | 15.7 | 21.9 | 19.4 | ERA5-Land mean of 12 monthly means, 2023 |
| Vegetation greenness | `mean_ndvi` | 0.49 | 0.71 | 0.61 | MODIS MOD13A3 v061 mean of 12 monthly products, 2023 |
| Low-lying terrain share | `low_lying_share_pct` | 8.6 | 31.8 | 18.0 | HAND <=5 m, static terrain |

### Table 2. Relationship to adjacent geospatial tools

| Tool or platform | Primary role | Relationship to this workflow |
|---|---|---|
| Google Earth Engine | Cloud-scale geospatial catalog and computation | Alternative execution environment for large analyses; does not define this repository's district-output, provenance, archive, and integrity contract |
| MODIStsp | Automated MODIS download and preprocessing | More specialized and feature-rich for MODIS; this workflow integrates MODIS with CHIRPS, ERA5-Land, and HAND in one district release |
| `exactextractr` | Efficient polygon extraction and zonal summaries | Core dependency used for district aggregation; this workflow adds source handling, transformations, provenance classification, outputs, tests, and archive metadata |
| Released workflow | Cross-provider district preparation and evidence labelling | Provides the integrated release contract evaluated in this article |

### Table 3. Claim-to-evidence mapping

| Software claim | Released evidence | Verification |
|---|---|---|
| Unknown or incomplete entries default to illustrative | `R/provenance_value_class.R` | Nine-assertion `R/demo_value_class.R` |
| Environmental transformations and zonal summaries execute without provider accounts on controlled inputs | Transformation modules and synthetic in-memory rasters | Nine-assertion `R/test_fixture_pipeline.R` |
| Each prepared environmental layer covers all 30 districts | Four environmental GeoJSON files | Feature-count and schema checks |
| Reported Nyarugenge values are present | Four environmental GeoJSON files | Direct field lookup |
| Release files have fixed integrity values | `CHECKSUMS.sha256` | `python/run_all_checks.py` |
| R dependencies are versioned | `renv.lock` and `environment.txt` | Clean-environment restore and continuous integration |

### Table 4. Principal limitations and interpretation

| Limitation | Consequence |
|---|---|
| Annual district summaries | Seasonality, extremes, and within-district variation are not represented |
| MODIS quality flags not applied | Residual low-quality observations may contribute to district means |
| HAND <=5 m is a selected terrain threshold | The output is not observed flooding, probability, or validated hazard |
| Coverage-fraction weighting in geographic coordinates | Weights are not identical to true surface-area weights |
| Directional consistency gates | They detect gross errors but do not validate exact values |
| Fixture inputs are synthetic | The account-free test verifies code paths, not source-product accuracy |
| Provider-dependent rebuilds require accounts and network access | Only the fixture pathway is fully account-free |
| No independent numerical validation | Prepared values require context-specific validation before substantive inference |
