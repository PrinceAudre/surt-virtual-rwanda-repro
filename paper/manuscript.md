# An R pipeline for district-level environmental layers and provenance labelling: a Rwanda proof of concept

**Tuyishime Audre Prince**

Health Systems, Clinton Health Access Initiative, Kigali, Rwanda

ORCID: 0009-0002-0799-3140

Corresponding author: Tuyishime Audre Prince, priplee@gmail.com

Article type: Software Tool Article

## Abstract

**Background:** Environmental products used in climate-sensitive health research must be fetched, transformed, aggregated to administrative units, and documented. These upstream steps are often difficult to inspect or reproduce, while synthetic demonstration values can be mistaken for source-derived evidence.

**Methods:** We developed two open components and demonstrated them for Rwanda's 30 districts. An R pipeline prepares annual rainfall, mean temperature, mean Normalized Difference Vegetation Index, and a static low-lying terrain share from CHIRPS, ERA5-Land, MODIS, and Height Above Nearest Drainage products. Raster values are summarized with coverage-fraction-weighted zonal statistics. A provenance-labelling module accepts a register row as source-derived only when it declares a documented method on real or public data; otherwise it labels the output illustrative. An account-free synthetic-fixture pipeline exercises the released transformations without private files or data-provider credentials.

**Results:** Each released environmental layer contains all 30 districts. The 2023 ranges are 917-1,489 mm annual rainfall, 15.7-21.9 degrees Celsius mean temperature, and 0.49-0.71 mean Normalized Difference Vegetation Index; the static share of district area with Height Above Nearest Drainage of 5 m or less is 8.6%-31.8%. The provenance demonstration passes nine assertions and the fixture pipeline passes eight. The release includes repository-relative builders, an R dependency lockfile, continuous-integration configuration, per-file provenance and licensing, and SHA-256 checksums.

**Conclusions:** The components provide a small, testable foundation for environmental-data preparation and provenance labelling. They do not compute disease relationships, forecasts, hazards, or operational recommendations. Independent numerical validation of the released district values remains future work.

**Keywords:** environmental data preparation; data provenance; zonal statistics; geospatial software; reproducible research; Rwanda; synthetic data

## Introduction

Rainfall, temperature, and vegetation measures are frequently used as environmental covariates in climate-sensitive health studies and early-warning research [1-3]. Rwanda-specific work has examined climatic factors associated with malaria incidence and projected changes in malaria transmission suitability [4,5]. Operational forecasting systems in the region, including EPIDEMIA, combine surveillance and environmental inputs to support outbreak analysis [6]. These examples establish the importance of environmental inputs, but the present work does not reproduce or compete with an epidemiological forecasting system.

A practical problem occurs before modelling: environmental data must be obtained from different providers, transformed from product-specific formats, aggregated to administrative units, and accompanied by sufficient provenance for a reader to understand what each value represents. Poorly documented preparation makes later analysis difficult to audit. It also becomes easy for values created only to demonstrate an interface to be mistaken for source-derived evidence. FAIR data principles emphasize rich provenance and reusable metadata [7], while the FAIR Data Pipeline illustrates provenance-driven workflow management [8].

This Software Tool Article presents two narrowly scoped components. The first prepares four district-level environmental layers. The second applies a fail-closed provenance label: an output is illustrative unless its register entry explicitly declares a documented method applied to real or public data. The components were extracted from a larger private prototype that also contains an unreleased dashboard and clearly labelled synthetic disease-side signals. The public release contains no disease data, patient data, surveillance data, forecast, or operational decision rule.

The contribution is therefore upstream engineering: a reviewable data-preparation pathway, explicit source and licence metadata, and a tested labelling contract that prevents unknown or placeholder entries from silently appearing source-derived.

## Methods

### Implementation

#### Scope and design

The released software consists of:

1. R builders and transformation functions for four environmental layers;
2. Python fetch clients for the two sources that require provider accounts;
3. a provenance-labelling module and illustrative two-row example register;
4. an account-free fixture pipeline;
5. the five released GeoJSON files, an R dependency lockfile, documentation, and SHA-256 checksums.

The private interactive application, its full methodology register, its synthetic disease signals, and its operational-adjacent interfaces are outside the release and outside the claims of this article.

The data flow has four stages. Source products are fetched into a local cache; product-specific scale factors, fill values, temporal summaries, and coordinate systems are handled; values are aggregated to district polygons; and the resulting GeoJSON contains only the district identifier, value, geometry, and provenance string. A separate flow sends a declared register row to the labelling module, which returns either `source-derived` or `illustrative`.

#### Geographic frame

The aggregation frame comprises Rwanda's 30 second-level administrative districts. District geometry comes from the World Bank Rwanda Admin Boundaries and Villages dataset under Creative Commons Attribution 4.0. All output geometry is stored in EPSG:4326. The released boundary file contains the district name and geometry only.

#### Environmental transformations

Three layers describe calendar year 2023, and one is static terrain:

- **Rainfall:** CHIRPS version 2.0 annual precipitation [9]. Negative no-data values are masked and the district mean is rounded to whole millimetres.
- **Temperature:** ERA5-Land 2 m air temperature [10]. The 12 monthly-mean layers for 2023 are checked for completeness, averaged, converted from kelvin to degrees Celsius, and summarized by district.
- **Vegetation greenness:** MODIS/Terra MOD13A3 version 061 monthly 1 km Normalized Difference Vegetation Index [11]. Fill and out-of-range values are masked, the 0.0001 scale factor is applied, monthly tiles are mosaicked, and the annual mean is summarized by district. Product quality and reliability flags are not applied.
- **Low-lying terrain share:** the Global 30 m Height Above Nearest Drainage product, derived from Copernicus GLO-30, is thresholded at 5 m. The output is the percentage of district area at or below that threshold. It is a static relative-elevation descriptor, not observed flooding or a validated flood-hazard model. The terrain method follows Nobre et al. [12].

District values are calculated with `exactextractr`, using the fraction of each raster cell covered by a polygon as the aggregation weight. For geographic rasters this is coverage-fraction weighting, not true surface-area weighting. Product no-data sentinels are masked before aggregation, and a build stops if any district lacks a valid value.

Each builder also applies bounded-value and directional consistency checks designed to detect gross unit, coordinate-system, threshold, or inversion errors. These checks include western districts being cooler than eastern districts and having a smaller low-lying share. They are software tripwires based on expected broad geography, not independent validation of numerical accuracy.

#### Provenance-labelling contract

The provenance module consumes a register whose rows declare an identifier, display label, method, palette, evidence class, method class, and citation. Its contract is:

- a row is `source-derived` only when it declares a documented method on real or public data;
- a placeholder method cannot be `source-derived`;
- an unknown, incomplete, synthetic, or placeholder entry is `illustrative`;
- an illustrative entry receives a visible explanatory note.

The module validates declarations; it does not independently verify that a citation is correct, that code implements the declared method, or that every value in another application is routed through the module.

#### Reproducibility design

The release uses repository-relative default paths. Real builders accept explicit output, district-geometry, and cache paths. `renv.lock` records the R dependency graph. The account-free command runs the nine-assertion provenance demonstration, an eight-assertion environmental fixture pipeline, and SHA-256 verification. The fixture creates synthetic rasters in memory and exercises the released rainfall, temperature, vegetation, and Height Above Nearest Drainage transformations over three synthetic polygons. It is a software test and does not regenerate or validate the released 2023 values.

GitHub Actions is configured to restore the locked environment and run the same account-free command on a clean hosted runner. Rebuilding the real ERA5-Land and MODIS layers additionally requires free Copernicus Climate Data Store and NASA Earthdata accounts. Credentials are read from provider-standard local files and are not stored in the repository.

### Operation

#### System requirements

The archived release was prepared with R 4.6.0, `terra` 1.9.27, `sf` 1.1.1, `exactextractr` 0.10.1, and `jsonlite` 2.0.0. Python 3 is used by the optional provider fetchers and the cross-platform verification runner. No specialized hardware is required.

#### Account-free quick start

After cloning the repository and restoring `renv.lock`, the complete account-free check is:

```text
python python/run_all_checks.py
```

This produces `generated/fixture_pipeline_output.geojson` and exits non-zero if any assertion or release checksum fails.

#### Real-data builds

The four real builders can be invoked from any working directory:

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

Default outputs are written to `generated/`, while source downloads are cached under `cache/`. Both directories are excluded from version control. Each script documents optional positional arguments for a different output, aggregation geometry, or cache location.

## Results

### Released environmental layers

Each environmental output contains one feature for every district. The observed district ranges and means are reported in Table 1. The western longitudinal third was cooler than the eastern third (17.5 versus 21.1 degrees Celsius) and had a smaller low-lying share (14.6% versus 22.8%). These directional results passed the released consistency gates; they are not comparisons with an independent reference dataset.

For a concrete output example, the released Nyarugenge records report annual rainfall of 955 mm, mean temperature of 20.6 degrees Celsius, mean Normalized Difference Vegetation Index of 0.55, and low-lying share of 22.1%. Each file also contains a provenance string naming the source, product, period, and licence. The low-lying value means that 22.1% of the district polygon is represented by Height Above Nearest Drainage values of 5 m or less; it must not be interpreted as observed flood extent or probability.

### Provenance and fixture checks

The provenance demonstration passes nine assertions: the example register is well formed; a source-derived-plus-placeholder combination is rejected; the source-derived environmental entry is not illustrative; a synthetic entry and an unknown identifier are illustrative; explanatory-note behaviour is correct; and the palette and quantile helpers handle ordinary and degenerate inputs.

The fixture pipeline passes eight assertions across the environmental transformations. It checks expected zonal means, broad directional gates, the Height Above Nearest Drainage threshold calculation, the MODIS scale transformation, and creation of an inspectable GeoJSON. Table 2 maps each principal engineering claim to its released evidence.

## Use case

A public-health analyst preparing a descriptive district briefing wants annual environmental context while ensuring that synthetic demonstration indicators remain distinguishable from source-derived environmental values. The analyst runs the builders or reads the archived layers, receives a provenance-tagged value per district, and routes any additional registered output through the labelling module.

The expected output supports statements such as "Nyarugenge's district-level 2023 annual rainfall in this prepared layer is 955 mm." It does not support a statement about disease risk, future weather, resource allocation, or causal effects, because the software computes none of those quantities.

## Discussion and conclusions

The strongest result is not a new epidemiological finding. It is the alignment of a narrow claim with a testable public artifact. The release provides product-specific transformations, district-level outputs, explicit provenance and licence mappings, a fail-closed labelling contract, a locked R environment, and an account-free check that a reviewer can execute without the private application or provider credentials.

The scope constraints are equally important. Single-year annual means remove seasonality and within-district variation. MODIS quality flags are not applied. The 5 m Height Above Nearest Drainage threshold is an explicit design choice and not a validated hazard threshold. Coverage-fraction weighting does not exactly equal surface-area weighting. Directional consistency gates detect gross errors but do not establish numerical accuracy. Table 3 consolidates these limitations and their implications.

The released district values have not undergone independent numerical validation, and bit-for-bit agreement of the provider-dependent real builds across operating systems has not been demonstrated. Future work should add product quality flags, seasonal summaries, uncertainty and data-quality metadata, selected external-value checks, and independent reruns of the provider-dependent pathway.

Within those limits, the release is a reusable proof of concept for transparent environmental-layer preparation and provenance labelling. It is not a validated climate-health platform, forecast, or operational tool.

## Ethics and consent

No human participants, animals, patient records, personal data, confidential records, or real surveillance data were used. The public artifact contains openly available environmental data and synthetic software-test fixtures. Ethical approval and consent were therefore not required.

## Data availability

Underlying data and prepared outputs are archived with version 1.1.0 of the software [13]. The archive contains:

- `relief_districts.geojson`: World Bank district geometry, CC BY 4.0;
- `relief_climate_rainfall.geojson`: CHIRPS version 2.0 annual precipitation, public domain/CC0;
- `relief_climate_temp.geojson`: ERA5-Land monthly-mean temperature, Copernicus Products licence;
- `relief_climate_ndvi.geojson`: MODIS MOD13A3 version 061 annual-mean Normalized Difference Vegetation Index, CC0;
- `relief_low_lying_hand.geojson`: Global 30 m Height Above Nearest Drainage threshold share, CC0.

GeoJSON is an open format. `NOTICE.md` supplies per-file attribution and licence information, `DATA_DICTIONARY.md` defines the fields, and `CHECKSUMS.sha256` supplies file-integrity values. No disease data are associated with the article.

The ERA5-Land source is third-party data under the Copernicus Products licence. A reader can obtain it by the same route as the author: create a free Copernicus Climate Data Store account, accept the product terms, configure the official `cdsapi` client, and run `python/fetch_era5land_temperature.py`. The exact transformation is in `R/build_relief_climate_temperature.R`.

## Software availability

Software available from: https://github.com/PrinceAudre/surt-virtual-rwanda-repro

Source code available from: https://github.com/PrinceAudre/surt-virtual-rwanda-repro

Archived source code at time of publication: Tuyishime AP. SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.1.0. Zenodo. 2026. https://doi.org/10.5281/zenodo.21674910 [Software] [13].

Licence: MIT for code. Data retain the per-file terms listed in the Data availability section and `NOTICE.md`.

## Author contributions

Tuyishime Audre Prince: Conceptualization, Data Curation, Methodology, Software, Visualization, Project Administration, Writing - Original Draft, and Writing - Review and Editing.

## Competing interests

The author is employed by the Clinton Health Access Initiative. No other competing interests were disclosed. The article and software do not claim institutional endorsement.

## Grant information

The author declared that no grants were involved in supporting this work.

## Acknowledgments

OpenAI Codex (GPT-5, accessed July 2026) was used for coding assistance, repository-quality checks, and manuscript drafting and editing. Anthropic Claude Opus 4.8 Max (accessed July 2026) was used to conduct a critical appraisal of an earlier manuscript draft. The author directed these uses, reviewed the outputs against the released files and primary sources, reran the reported software checks, and takes responsibility for the article. No AI tool was used to generate research data, data values, tables, images, or figures.

## References

1. Mategula D, Gichuki J, Barnes KI, Giorgi E, Terlouw DJ. Advancing early warning systems for malaria: progress, challenges, and future directions - a scoping review. PLOS Global Public Health. 2025;5:e0003751. doi:10.1371/journal.pgph.0003751.
2. Delight EA, Brunn AA, Ruiz F, et al. Gaps and opportunities for data systems and economics to support priority setting for climate-sensitive infectious diseases in sub-Saharan Africa: a rapid scoping review. PLOS Global Public Health. 2025;5:e0003814. doi:10.1371/journal.pgph.0003814.
3. Pham CT, Nguyen HT, Le HHTC, et al. Challenges and strategies for the development and implementation of climate-informed early warning systems for vector-borne diseases: a systematic review. Tropical Medicine & International Health. 2025;31:10-21. doi:10.1111/tmi.70045.
4. Rubuga FK, Ahmed A, Siddig E, et al. Potential impact of climatic factors on malaria in Rwanda between 2012 and 2021: a time-series analysis. Malaria Journal. 2024;23:274. doi:10.1186/s12936-024-05097-5.
5. Zong L, Ngarukiyimana JP, Yang Y, et al. Malaria transmission risk is projected to increase in the highlands of Western and Northern Rwanda. Communications Earth & Environment. 2024;5:559. doi:10.1038/s43247-024-01717-9.
6. Merkord CL, Liu Y, Mihretie A, et al. Integrating malaria surveillance with climate data for outbreak detection and forecasting: the EPIDEMIA system. Malaria Journal. 2017;16:89. doi:10.1186/s12936-017-1735-x.
7. Wilkinson MD, Dumontier M, Aalbersberg IJ, et al. The FAIR Guiding Principles for scientific data management and stewardship. Scientific Data. 2016;3:160018. doi:10.1038/sdata.2016.18.
8. Mitchell SN, et al. FAIR data pipeline: provenance-driven data management for traceable scientific workflows. Philosophical Transactions of the Royal Society A. 2022;380:20210300. doi:10.1098/rsta.2021.0300.
9. Funk C, Peterson P, Landsfeld M, Pedreros D, Verdin J, Shukla S, et al. The climate hazards infrared precipitation with stations - a new environmental record for monitoring extremes. Scientific Data. 2015;2:150066. doi:10.1038/sdata.2015.66.
10. Munoz-Sabater J, Dutra E, Agusti-Panareda A, Albergel C, Arduini G, Balsamo G, et al. ERA5-Land: a state-of-the-art global reanalysis dataset for land applications. Earth System Science Data. 2021;13:4349-4383. doi:10.5194/essd-13-4349-2021.
11. Didan K. MODIS/Terra Vegetation Indices Monthly L3 Global 1 km SIN Grid V061 [Dataset]. NASA EOSDIS Land Processes Distributed Active Archive Center; 2021. doi:10.5067/MODIS/MOD13A3.061.
12. Nobre AD, Cuartas LA, Hodnett M, Renno CD, Rodrigues G, Silveira A, et al. Height Above the Nearest Drainage - a hydrologically relevant new terrain model. Journal of Hydrology. 2011;404:13-29. doi:10.1016/j.jhydrol.2011.03.051.
13. Tuyishime AP. SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.1.0. Zenodo. 2026. doi:10.5281/zenodo.21674910 [Software].

## Tables

### Table 1. Per-district summaries across Rwanda's 30 districts

| Layer | Field | Minimum | Maximum | Mean | Temporal basis |
|---|---|---:|---:|---:|---|
| Rainfall | `annual_rainfall_mm` | 917 | 1,489 | 1,163 | CHIRPS v2.0 annual total, 2023 |
| Temperature | `mean_temp_c` | 15.7 | 21.9 | 19.4 | ERA5-Land mean of 12 monthly means, 2023 |
| Vegetation greenness | `mean_ndvi` | 0.49 | 0.71 | 0.61 | MODIS MOD13A3 v061 mean of 12 monthly products, 2023 |
| Low-lying terrain share | `low_lying_share_pct` | 8.6 | 31.8 | 18.0 | HAND <=5 m, static terrain |

### Table 2. Claim-to-evidence mapping

| Engineering claim | Released evidence | Test or inspection |
|---|---|---|
| Unknown or incomplete entries default to illustrative | `R/provenance_value_class.R` | Nine-assertion `R/demo_value_class.R` |
| Product transforms and zonal summaries run without provider accounts | Transformation modules and synthetic in-memory rasters | Eight-assertion `R/test_fixture_pipeline.R` |
| Every prepared environmental file covers 30 districts | Four environmental GeoJSON files | Feature-count and schema checks in the release QA |
| Reported Nyarugenge values are present in the release | Four environmental GeoJSON files | Direct field lookup |
| Release files have fixed integrity values | `CHECKSUMS.sha256` | `python/run_all_checks.py` |
| R dependencies are versioned | `renv.lock` and `environment.txt` | Clean-environment restore and check command |

### Table 3. Principal limitations and interpretation

| Limitation | Consequence |
|---|---|
| Annual district summaries | Seasonality, extremes, and within-district variation are not represented |
| MODIS quality flags not applied | Residual low-quality observations may contribute to district means |
| HAND <=5 m is a selected terrain threshold | The output is not observed flooding, probability, or validated hazard |
| Coverage-fraction weighting in geographic coordinates | Weights are not identical to true surface-area weights |
| Directional consistency gates | They detect gross errors but do not validate exact values |
| Fixture inputs are synthetic | The account-free test verifies code paths, not the released source-derived values |
| Provider-dependent rebuilds require accounts and network access | Only the fixture pathway is fully account-free |
| No independent numerical validation | Prepared district values should not be treated as validated reference measurements |
