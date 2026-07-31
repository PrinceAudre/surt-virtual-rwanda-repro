# An auditable cross-provider workflow for district-scale Earth-data harmonization and provenance labelling: software design and a Rwanda implementation

**Tuyishime Audre Prince**

Kigali, Rwanda

ORCID: 0009-0002-0799-3140

Corresponding author: Tuyishime Audre Prince, priplee@gmail.com

Article type: Software article

## Abstract

Earth-observation workflows frequently combine products that differ in access mechanisms, file structures, coordinate systems, scale factors, temporal support, no-data conventions, and licence terms. Reproducibility is weakened when these transformations are distributed across undocumented scripts or when illustrative values can be mistaken for source-derived evidence. This software article presents an open R and Python workflow that harmonizes CHIRPS rainfall, ERA5-Land temperature, MODIS vegetation index, and Height Above Nearest Drainage terrain data into a common district-level GeoJSON contract. The Rwanda implementation contains one value for each of 30 districts and records source, period or threshold, provenance, and applicable terms. A fail-closed classification module labels unknown, incomplete, synthetic, or placeholder entries as illustrative unless a documented method on real or public data is declared. Verification combines nine provenance assertions, nine synthetic environmental-pipeline assertions, 41 SHA-256 integrity checks, a locked R environment, and continuous integration. The archived 2023 district ranges are 917-1,489 mm annual rainfall, 15.7-21.9 degrees Celsius mean temperature, and 0.49-0.71 mean NDVI; static district area represented by HAND values of 5 m or less ranges from 8.6% to 31.8%. The contribution is an auditable Earth-data release pattern rather than a new raster algorithm. It produces descriptive environmental layers, not validated hazards, forecasts, epidemiological effects, or operational recommendations.

**Keywords:** Earth science informatics; data provenance; geospatial workflow; zonal statistics; reproducible software; environmental data

## Introduction

Earth-system data are increasingly assembled from distributed observation and reanalysis products. Even a small administrative-unit dataset may require different acquisition clients, product-specific masking and scaling, temporal aggregation, coordinate transformation, polygon extraction, metadata recording, and licence attribution. CHIRPS precipitation, ERA5-Land reanalysis, MODIS vegetation indices, and Height Above Nearest Drainage (HAND) terrain data illustrate this heterogeneity (Didan 2021; Funk et al. 2015; Munoz-Sabater et al. 2021; Nobre et al. 2011). The informatics challenge is not limited to obtaining the files. It is maintaining a reviewable chain from provider product to interpretable and citable output.

District-scale environmental summaries are used in descriptive assessment, climate-sensitive health research, and early-warning analyses (Delight et al. 2025; Mategula et al. 2025; Pham et al. 2025). Rwanda-specific studies have examined climatic factors associated with malaria incidence and projected changes in malaria transmission suitability (Rubuga et al. 2024; Zong et al. 2024), while systems such as EPIDEMIA demonstrate how surveillance and environmental inputs may later be combined for outbreak detection and forecasting (Merkord et al. 2017). These downstream uses increase the importance of distinguishing prepared environmental context from forecasts, hazards, causal estimates, and synthetic demonstration content.

Mature tools solve important parts of the workflow. Google Earth Engine provides cloud-scale catalog access and geospatial computation (Gorelick et al. 2017). MODIStsp automates acquisition and preprocessing of MODIS land products (Busetto and Ranghetti 2016). The R package `exactextractr` provides efficient polygon extraction and zonal summaries (Baston 2025). These capabilities are complementary. They do not, by themselves, define a compact cross-provider release contract that standardizes administrative outputs, records per-file provenance and terms, fails closed when evidence declarations are incomplete, supplies an account-free reviewer fixture, and archives the exact software version with integrity checks.

FAIR principles emphasize rich metadata, provenance, and reuse (Wilkinson et al. 2016), and provenance-driven data-management systems demonstrate the value of traceable processing (Mitchell et al. 2022). The research question addressed here is whether a small open workflow can combine heterogeneous Earth-data products into a consistent district schema while making evidence status, software verification, and release integrity inspectable independently of a larger application.

The contribution is therefore an Earth science informatics design and reference implementation, not a new raster-processing algorithm. The released repository integrates provider-specific transformation, administrative aggregation, fail-closed evidence classification, explicit data terms, hermetic verification, continuous integration, and a versioned archive. Rwanda is used as the evaluated geographic implementation. The public artifact excludes the private parent dashboard, disease-side signals, patient or surveillance data, decision rules, and operational interfaces.

## Design and Implementation

### Software objectives and architecture

The repository integrates five functions that are commonly separated across scripts, notebooks, or platforms:

1. provider-specific acquisition and input handling;
2. reproducible transformation of rainfall, temperature, vegetation, and terrain products;
3. coverage-fraction-weighted aggregation into a common administrative GeoJSON schema;
4. fail-closed provenance labelling and per-file licence documentation; and
5. account-free verification plus release-integrity checking.

Figure 1 shows the software architecture. Source-specific modules isolate access, masking, scaling, mosaicking, reprojection, and temporal aggregation from the common district extraction and output contract. A parallel synthetic-fixture path exercises the transformation modules without provider credentials. Provenance classification and release-integrity controls govern how outputs are interpreted and preserved.

The workflow does not replace Google Earth Engine, MODIStsp, or `exactextractr`. Google Earth Engine is a cloud analysis platform; MODIStsp is specialized for MODIS acquisition and preprocessing; and `exactextractr` is used as the polygon-extraction engine. The additional contribution is the release-level integration around these capabilities: multiple providers, a common district schema, an explicit evidence-status contract, hermetic tests, per-file terms, checksums, and a Zenodo archive.

### Geographic reference implementation

The reference aggregation frame comprises Rwanda's 30 second-level administrative districts. District geometry is derived from the World Bank Rwanda Admin Boundaries and Villages dataset under Creative Commons Attribution 4.0. Released geometry is stored in EPSG:4326. The boundary file contains district name and geometry only.

The architecture is not intrinsically Rwanda-specific. A new implementation requires a polygon layer with a stable administrative identifier and source-specific configuration for the environmental products. Portability beyond Rwanda is a design claim based on separation of concerns; it has not yet been empirically demonstrated in another country and is treated as future validation.

### Environmental transformation modules

Three layers describe calendar year 2023 and one represents static terrain:

- **Rainfall:** CHIRPS version 2.0 annual precipitation (Funk et al. 2015). Negative no-data values are masked and the district mean is rounded to whole millimetres.
- **Temperature:** ERA5-Land 2 m air temperature (Munoz-Sabater et al. 2021). Twelve monthly-mean layers for 2023 are checked for completeness, averaged, converted from kelvin to degrees Celsius, and summarized by district.
- **Vegetation greenness:** MODIS/Terra MOD13A3 version 061 monthly 1 km NDVI (Didan 2021). Fill and out-of-range values are masked, the 0.0001 scale factor is applied, monthly tiles are mosaicked, and an annual mean is summarized by district. Product quality and reliability flags are not applied in this release.
- **Low-lying terrain share:** Global 30 m HAND, derived from Copernicus GLO-30, is thresholded at 5 m. The output is the percentage of district area at or below the relative-elevation threshold. It is not observed flooding or a validated flood-hazard probability. The terrain concept follows Nobre et al. (2011).

District values are calculated with `exactextractr` 0.10.1, using the fraction of each raster cell covered by a polygon as the aggregation weight (Baston 2025). For rasters in geographic coordinates this is coverage-fraction weighting, not exact surface-area weighting. Product no-data sentinels are masked before aggregation, and a build stops when any district lacks a valid value.

Each builder applies bounded-value and broad directional consistency gates intended to detect gross unit, coordinate-system, threshold, or inversion errors. For example, the released test checks that the western longitudinal third is cooler than the eastern third. These gates are software tripwires and are not substitutes for independent numerical validation.

### Provenance-labelling contract

The provenance module consumes a register row containing an identifier, display label, method, palette, evidence class, method class, and citation. The contract is:

- `source-derived` requires a documented method applied to real or public data;
- a placeholder method cannot be `source-derived`;
- unknown, incomplete, synthetic, and placeholder entries default to `illustrative`; and
- illustrative outputs receive an explanatory note.

This rule is fail closed: incomplete declarations are not promoted to source-derived status. The module validates declarations and presentation behaviour. It does not independently establish that a citation is correct, that every external application routes values through the module, or that a declared method was implemented faithfully outside the released repository.

### Input and output contract

The real builders accept a period or threshold plus optional paths for output, aggregation geometry, and local cache. Default outputs are written to `generated/`; provider downloads are cached under `cache/`. Both directories are excluded from version control.

Each released environmental output is a GeoJSON FeatureCollection with 30 district features. A feature contains the district identifier, one environmental value, geometry, and a provenance string naming the source, product, period or threshold, and applicable terms. `DATA_DICTIONARY.md` defines the fields, while `NOTICE.md` records attribution and licence information.

### Verification design

`renv.lock` records the R dependency graph. The archived release was prepared with R 4.6.0, `terra` 1.9.27, `sf` 1.1.1, `exactextractr` 0.10.1, and `jsonlite` 2.0.0. Python 3 is used by provider fetchers and by the cross-platform verification runner.

The account-free verification command is:

```text
python python/run_all_checks.py
```

It runs the nine-assertion provenance demonstration, a nine-assertion environmental fixture, and verification of files listed in `CHECKSUMS.sha256`. The fixture creates synthetic rasters in memory and exercises the released rainfall, temperature, NDVI, HAND, reprojection, mosaic, temporal-summary, zonal-extraction, and GeoJSON-writing paths. Its NDVI path uses two synthetic months and two same-month tiles in the MODIS sinusoidal coordinate system. The runner records step durations and execution-environment metadata in a machine-readable JSON summary.

The fixture verifies software behaviour, not the numerical accuracy of the archived 2023 source-derived values. GitHub Actions restores the locked environment, repeats the checks on a clean hosted runner, generates the manuscript figures directly from the archived GeoJSON files, and retains the figure bundle as a workflow artifact.

### Real-data operation

The four real builders can be invoked from any working directory:

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

The CHIRPS and HAND builders require network access. ERA5-Land and MODIS additionally require free Copernicus Climate Data Store and NASA Earthdata accounts. Credentials are read from provider-standard local files and are not stored in the repository.

### Use of generative AI

OpenAI ChatGPT and Codex tools and Anthropic Claude were used during July 2026 for coding assistance, repository-quality review, critical appraisal, and manuscript drafting and editing. The author directed these uses, inspected proposed changes against the repository and cited primary sources, reran the reported checks, and remains accountable for the software and manuscript. No AI tool generated the provider data, the archived district values, or an analytical result reported as empirical evidence.

## Results

### Prepared district layers

Every environmental output contains one feature for each of Rwanda's 30 districts. Table 1 summarizes the released values and Figure 2 shows their spatial distribution. The western longitudinal third was cooler than the eastern third (17.5 versus 21.1 degrees Celsius) and had a smaller low-lying terrain share (14.6% versus 22.8%). These comparisons passed the released directional gates; they are not comparisons with an independent reference dataset.

For a concrete record-level example, the released Nyarugenge features contain annual rainfall of 955 mm, mean temperature of 20.6 degrees Celsius, mean NDVI of 0.55, and a low-lying terrain share of 22.1%. The last value means that 22.1% of the district polygon is represented by HAND values of 5 m or less. It must not be interpreted as observed flood extent, flood probability, population exposure, or risk.

Figure 3 standardizes values within each layer to compare district profiles despite different units. The profile is descriptive and is not a composite environmental, hazard, or health-risk index.

### Verification results

The provenance demonstration passes nine assertions covering register structure, rejection of source-derived placeholder combinations, default illustrative treatment of synthetic and unknown identifiers, explanatory-note behaviour, and palette and quantile helper behaviour.

The environmental fixture passes nine assertions covering expected zonal means, bounded and directional gates, the HAND threshold calculation, the complete multi-month and multi-tile MODIS transformation to EPSG:4326, and creation of an inspectable GeoJSON. The release runner verifies 41 SHA-256 file digests in the archived v1.1.1 package. The journal-refinement branch adds machine-readable timing and figure generation without changing the archived environmental values.

Table 2 distinguishes the workflow from adjacent tools, while Table 3 maps the principal software claims to released evidence. This claim-to-evidence structure makes the article assessable without access to the unreleased parent prototype.

### Example uses and interpretation boundary

A researcher preparing administrative environmental covariates can run the builders or read the archived layers, retain the provenance string and per-file terms, and perform downstream analysis separately. A supported statement is: "The prepared 2023 annual-rainfall layer contains 955 mm for Nyarugenge." Unsupported statements include claims about disease causation, future weather, flood probability, resource allocation, or intervention effectiveness.

A developer preparing a demonstration that mixes empirical context with synthetic indicators can route registered values through the provenance module. Source-derived entries retain that label only when the required declarations are complete; unknown or synthetic entries remain illustrative and receive a visible note.

## Discussion

The principal contribution is an integrated and auditable Earth-data workflow rather than a novel numerical algorithm. The software combines multi-provider preprocessing, administrative aggregation, standardized outputs, explicit data terms, fail-closed provenance labelling, a locked environment, an account-free fixture, continuous integration, and an immutable research archive. This combination addresses acquisition, processing, interchange, interpretation, and preservation as one informatics problem.

The design also separates software verification from scientific validation. The tests establish that specified transformations, classification rules, output schemas, and integrity checks behave as expected on controlled inputs. They do not establish that provider products are error-free, that the selected HAND threshold represents hazard, or that the prepared values are appropriate for a particular model. Independent spot checks, uncertainty assessment, and sensitivity analyses remain necessary before substantive inference.

The Rwanda implementation demonstrates a complete 30-district release but not cross-country portability. The source-specific modules, common output schema, and geometry interface were designed to support other administrative frames. A stronger portability evaluation would rerun the workflow in at least one country with different geometry complexity, tile coverage, and provider-access conditions, then compare code changes, execution time, missingness, and output consistency.

The release has further limitations. Annual district summaries suppress seasonality, extremes, and within-district heterogeneity. MODIS quality flags are not applied. Coverage-fraction weighting in geographic coordinates differs from true surface-area weighting. Provider-dependent builds require accounts and network access, so only the fixture pathway is fully account-free. The archived district values have not undergone independent numerical validation against a second processing implementation. Table 4 consolidates these limitations and their consequences.

Future work should add product-quality flags, monthly and seasonal summaries, uncertainty and data-quality fields, selected independent value comparisons, equal-area sensitivity analysis, cross-platform real-data reruns, and a second-country portability study. These additions would strengthen scientific validation while preserving the core provenance and release contract.

## Conclusions

The released workflow converts four heterogeneous Earth-data products into standardized, provenance-labelled layers for Rwanda's 30 districts and packages the process as a testable, versioned research artifact. Its contribution is the integration of source-specific processing, administrative aggregation, fail-closed evidence classification, account-free verification, and release integrity. The reference implementation is suitable for transparent preparation of descriptive environmental inputs and for applications that must distinguish source-derived evidence from illustrative content. It is not an epidemiological model, forecasting platform, validated hazard model, or operational decision system.

## Availability and Requirements

- **Project name:** SuRT-Virtual Rwanda reproducibility artifact
- **Project home page:** https://github.com/PrinceAudre/surt-virtual-rwanda-repro
- **Archived version:** 1.1.1, https://doi.org/10.5281/zenodo.21677162
- **Operating systems:** Linux, Windows, or macOS for the account-free workflow; real-data provider clients are subject to their own platform requirements
- **Programming languages:** R 4.6.0 and Python 3
- **Core dependencies:** `terra`, `sf`, `exactextractr`, and `jsonlite`, with versions recorded in `renv.lock`
- **Hardware:** no specialized hardware is required for the account-free verification workflow
- **Other requirements:** internet access for real-data acquisition; free Climate Data Store and NASA Earthdata accounts for ERA5-Land and MODIS rebuilds
- **Licence:** MIT for code; data retain the per-file terms documented in `NOTICE.md`
- **Restrictions on non-academic use:** none for the MIT-licensed code; users must comply with source-data terms

## Statements and Declarations

### Ethics approval and consent

No human participants, animals, patient records, personal data, confidential records, or real surveillance data were used. The artifact contains openly available environmental products and synthetic software-test fixtures. Ethical approval and consent were therefore not required.

### Funding

No grants supported this work.

### Competing interests

The author has undertaken contractual research coordination work for the Clinton Health Access Initiative. The software and manuscript were developed and are presented in the author's independent capacity and do not imply institutional sponsorship or endorsement.

### Author contributions

Tuyishime Audre Prince: Conceptualization, Data Curation, Methodology, Software, Validation, Visualization, Project Administration, Writing - Original Draft, and Writing - Review and Editing.

### Data availability

Prepared outputs and the exact software release are archived in Zenodo version 1.1.1 (Tuyishime 2026). The archive contains district geometry and four environmental GeoJSON layers. `NOTICE.md` supplies per-file attribution and licence information, `DATA_DICTIONARY.md` defines fields, and `CHECKSUMS.sha256` supplies integrity values. No disease data are associated with the article.

ERA5-Land is third-party data under the Copernicus Products licence. A reader can obtain it through the same route as the author by creating a free Climate Data Store account, accepting the product terms, configuring the official `cdsapi` client, and running `python/fetch_era5land_temperature.py`. The corresponding transformation is implemented in `R/build_relief_climate_temperature.R`.

## References

Baston D (2025) exactextractr: fast extraction from raster datasets using polygons. R package version 0.10.1. https://doi.org/10.32614/CRAN.package.exactextractr

Busetto L, Ranghetti L (2016) MODIStsp: an R package for automatic preprocessing of MODIS Land Products time series. Comput Geosci 97:40-48. https://doi.org/10.1016/j.cageo.2016.08.020

Delight EA, Brunn AA, Ruiz F et al (2025) Gaps and opportunities for data systems and economics to support priority setting for climate-sensitive infectious diseases in sub-Saharan Africa: a rapid scoping review. PLOS Glob Public Health 5:e0003814. https://doi.org/10.1371/journal.pgph.0003814

Didan K (2021) MODIS/Terra Vegetation Indices Monthly L3 Global 1 km SIN Grid V061 [Dataset]. NASA EOSDIS Land Processes Distributed Active Archive Center. https://doi.org/10.5067/MODIS/MOD13A3.061

Funk C, Peterson P, Landsfeld M et al (2015) The climate hazards infrared precipitation with stations - a new environmental record for monitoring extremes. Sci Data 2:150066. https://doi.org/10.1038/sdata.2015.66

Gorelick N, Hancher M, Dixon M et al (2017) Google Earth Engine: planetary-scale geospatial analysis for everyone. Remote Sens Environ 202:18-27. https://doi.org/10.1016/j.rse.2017.06.031

Mategula D, Gichuki J, Barnes KI et al (2025) Advancing early warning systems for malaria: progress, challenges, and future directions - a scoping review. PLOS Glob Public Health 5:e0003751. https://doi.org/10.1371/journal.pgph.0003751

Merkord CL, Liu Y, Mihretie A et al (2017) Integrating malaria surveillance with climate data for outbreak detection and forecasting: the EPIDEMIA system. Malar J 16:89. https://doi.org/10.1186/s12936-017-1735-x

Mitchell SN et al (2022) FAIR data pipeline: provenance-driven data management for traceable scientific workflows. Philos Trans R Soc A 380:20210300. https://doi.org/10.1098/rsta.2021.0300

Munoz-Sabater J, Dutra E, Agusti-Panareda A et al (2021) ERA5-Land: a state-of-the-art global reanalysis dataset for land applications. Earth Syst Sci Data 13:4349-4383. https://doi.org/10.5194/essd-13-4349-2021

Nobre AD, Cuartas LA, Hodnett M et al (2011) Height Above the Nearest Drainage - a hydrologically relevant new terrain model. J Hydrol 404:13-29. https://doi.org/10.1016/j.jhydrol.2011.03.051

Pham CT, Nguyen HT, Le HHTC et al (2025) Challenges and strategies for the development and implementation of climate-informed early warning systems for vector-borne diseases: a systematic review. Trop Med Int Health 31:10-21. https://doi.org/10.1111/tmi.70045

Rubuga FK, Ahmed A, Siddig E et al (2024) Potential impact of climatic factors on malaria in Rwanda between 2012 and 2021: a time-series analysis. Malar J 23:274. https://doi.org/10.1186/s12936-024-05097-5

Tuyishime AP (2026) SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.1.1. Zenodo [Software]. https://doi.org/10.5281/zenodo.21677162

Wilkinson MD, Dumontier M, Aalbersberg IJ et al (2016) The FAIR Guiding Principles for scientific data management and stewardship. Sci Data 3:160018. https://doi.org/10.1038/sdata.2016.18

Zong L, Ngarukiyimana JP, Yang Y et al (2024) Malaria transmission risk is projected to increase in the highlands of Western and Northern Rwanda. Commun Earth Environ 5:559. https://doi.org/10.1038/s43247-024-01717-9

## Tables

### Table 1 Per-district summaries across Rwanda's 30 districts

| Layer | Field | Minimum | Maximum | Mean | Temporal basis |
|---|---|---:|---:|---:|---|
| Rainfall | `annual_rainfall_mm` | 917 | 1,489 | 1,163 | CHIRPS v2.0 annual total, 2023 |
| Temperature | `mean_temp_c` | 15.7 | 21.9 | 19.4 | ERA5-Land mean of 12 monthly means, 2023 |
| Vegetation greenness | `mean_ndvi` | 0.49 | 0.71 | 0.61 | MODIS MOD13A3 v061 mean of 12 monthly products, 2023 |
| Low-lying terrain share | `low_lying_share_pct` | 8.6 | 31.8 | 18.0 | HAND <=5 m, static terrain |

### Table 2 Relationship to adjacent geospatial tools

| Tool or platform | Primary role | Relationship to this workflow |
|---|---|---|
| Google Earth Engine | Cloud-scale geospatial catalogue and computation | Alternative execution environment for large analyses; does not define this repository's district-output, provenance, archive, and integrity contract |
| MODIStsp | Automated MODIS download and preprocessing | More specialized and feature-rich for MODIS; this workflow integrates MODIS with CHIRPS, ERA5-Land, and HAND in one administrative release |
| `exactextractr` | Efficient polygon extraction and zonal summaries | Core dependency used for district aggregation; this workflow adds source handling, transformations, provenance classification, outputs, tests, and archive metadata |
| Released workflow | Cross-provider Earth-data preparation and evidence labelling | Provides the integrated release contract evaluated in this article |

### Table 3 Claim-to-evidence mapping

| Software claim | Released evidence | Verification |
|---|---|---|
| Unknown or incomplete entries default to illustrative | `R/provenance_value_class.R` | Nine-assertion `R/demo_value_class.R` |
| Environmental transformations and zonal summaries execute without provider accounts on controlled inputs | Transformation modules and synthetic in-memory rasters | Nine-assertion `R/test_fixture_pipeline.R` |
| Each prepared environmental layer covers all 30 districts | Four environmental GeoJSON files | Feature-count and schema checks |
| Reported Nyarugenge values are present | Four environmental GeoJSON files | Direct field lookup |
| Release files have fixed integrity values | `CHECKSUMS.sha256` | `python/run_all_checks.py` |
| R dependencies are versioned | `renv.lock` and `environment.txt` | Clean-environment restore and continuous integration |

### Table 4 Principal limitations and interpretation

| Limitation | Consequence |
|---|---|
| Annual district summaries | Seasonality, extremes, and within-district variation are not represented |
| MODIS quality flags not applied | Residual low-quality observations may contribute to district means |
| HAND <=5 m is a selected terrain threshold | The output is not observed flooding, probability, or validated hazard |
| Coverage-fraction weighting in geographic coordinates | Weights are not identical to true surface-area weights |
| Directional consistency gates | They detect gross errors but do not validate exact values |
| Fixture inputs are synthetic | The account-free test verifies code paths, not source-product accuracy |
| Provider-dependent rebuilds require accounts and network access | Only the fixture pathway is fully account-free |
| One-country reference implementation | Portability beyond Rwanda has not been empirically demonstrated |
| No independent numerical validation | Prepared values require context-specific validation before substantive inference |

## Figure captions

**Fig. 1** Cross-provider Earth-data preparation and auditable release contract. Provider-specific environmental products pass through documented masking, scaling, temporal aggregation, district aggregation, provenance classification, and release-integrity controls. The synthetic fixture exercises the transformation paths without provider accounts; it does not validate the source products or reported 2023 district values

**Fig. 2** Spatial distribution of the four released district-level environmental layers for Rwanda. (a) CHIRPS annual rainfall for 2023, in millimetres; (b) ERA5-Land mean 2 m air temperature for 2023, in degrees Celsius; (c) MODIS MOD13A3 mean NDVI for 2023; and (d) percentage of district area represented by HAND values of 5 m or less. The HAND layer is a static relative-elevation descriptor and must not be interpreted as observed flooding or flood probability

**Fig. 3** Standardized district profiles across the four released environmental layers. Values are expressed as within-layer z scores to permit comparison despite different physical units. District ordering is based on the first principal component of the four standardized layers. The plot is descriptive and does not represent an epidemiological risk score, hazard index, or causal model

## Software Files

The exact v1.1.1 software files are available from the GitHub repository and Zenodo archive cited above. The principal directories and files are:

- `R/`: provider transformation functions, real-data builders, provenance classification, and synthetic fixture tests;
- `python/`: provider fetch clients and the cross-platform verification runner;
- `data/`: district geometry and four prepared environmental GeoJSON layers;
- `renv.lock` and `environment.txt`: dependency and execution-environment records;
- `NOTICE.md` and `DATA_DICTIONARY.md`: source terms, attribution, and field definitions;
- `CHECKSUMS.sha256`: release-integrity manifest; and
- `.github/workflows/reproducibility.yml`: clean-environment verification and figure-generation workflow.
