# An auditable cross-provider workflow for district-scale Earth-data harmonization and provenance labelling: software design and a Rwanda implementation

**Tuyishime Audre Prince**

Kigali, Rwanda

ORCID: 0009-0002-0799-3140

Corresponding author: Tuyishime Audre Prince, priplee@gmail.com

Article type: Software article

## Abstract

Earth-observation workflows frequently combine products that differ in access mechanisms, file structures, coordinate systems, scale factors, temporal support, no-data conventions, and licence terms. Reproducibility is weakened when these transformations are distributed across undocumented scripts or when illustrative values can be mistaken for source-derived evidence. This software article presents an open R and Python workflow that harmonizes CHIRPS rainfall, ERA5-Land temperature, MODIS vegetation index, and Height Above Nearest Drainage terrain data into a common district-level GeoJSON contract. The Rwanda implementation contains one value for each of 30 districts and records source, period or threshold, provenance, and applicable terms. A fail-closed classification module treats unknown, incomplete, synthetic, or placeholder entries as illustrative unless a documented method on real or public data is declared. Account-free verification comprises 41 explicit outcomes spanning transformation correctness, projected non-Rwanda geometry, deliberate failure injection, release-schema enforcement, and corruption rejection. A separate public-data validation independently reacquired CHIRPS 2023: all 30 archived district values reproduced exactly after rounding, two extraction engines differed by at most 0.000136 mm, and cell-area weighting changed means by at most 0.005127 mm. The remaining environmental layers have not received equivalent independent numerical validation. The contribution is an auditable Earth-data release pattern rather than a new raster algorithm. It produces descriptive environmental layers, not validated hazards, forecasts, epidemiological effects, or operational recommendations.

**Keywords:** Earth science informatics; data provenance; geospatial workflow; zonal statistics; reproducible software; environmental data

## Introduction

Earth-system analysis increasingly depends on computational chains that combine distributed observation, reanalysis, and terrain products. Even a small administrative-unit dataset may require provider-specific acquisition, masking, scaling, temporal aggregation, mosaicking, coordinate transformation, polygon extraction, metadata recording, licence attribution, verification, and archival packaging. CHIRPS precipitation, ERA5-Land reanalysis, MODIS vegetation indices, and Height Above Nearest Drainage (HAND) terrain data illustrate this heterogeneity (Didan 2021; Funk et al. 2015; Muñoz-Sabater et al. 2021; Nobre et al. 2011). The informatics problem is not limited to obtaining files. It is preserving a reviewable chain from source product to interpretable, citable, and reusable output.

Computational workflows can improve traceability and reuse, but portability and reproducibility depend on explicit interfaces, execution evidence, and preserved provenance rather than workflow automation alone (Kale et al. 2023). FAIR principles similarly emphasize metadata, provenance, and reuse (Wilkinson et al. 2016), while provenance-driven data-management systems and research-object packaging show how software, data, methods, identifiers, and relationships can be preserved as an assessable artifact (Mitchell et al. 2022; Soiland-Reyes et al. 2022). W3C PROV provides a formal model for interoperable provenance representation, although the present release does not claim PROV-O conformance (Lebo et al. 2013).

Mature geospatial tools solve important parts of the processing problem. Google Earth Engine provides cloud-scale catalogue access and geospatial computation (Gorelick et al. 2017). MODIStsp automates acquisition and preprocessing of MODIS land products (Busetto and Ranghetti 2016). The R package `exactextractr` provides efficient polygon extraction and zonal summaries (Baston 2025). These capabilities are complementary. They do not, by themselves, define this repository's compact cross-provider release contract: a common administrative schema, per-file source and licence metadata, fail-closed evidence classification, account-free reviewer fixtures, deliberate failure tests, independent release-contract validation, clean continuous integration, and an immutable research archive.

District environmental summaries may later be used in climate-sensitive health research, surveillance, or early-warning analyses, including Rwanda-specific work on malaria and climate (Zong et al. 2024). Such downstream uses make interpretation boundaries consequential. A prepared environmental covariate is not a forecast, hazard probability, causal effect, exposure estimate, or operational recommendation.

The research question addressed here is whether a small open workflow can harmonize heterogeneous Earth-data products into a consistent district schema while making transformation behaviour, evidence status, numerical reproducibility, and release integrity inspectable independently of a larger application. The contribution is an Earth science informatics design and reference implementation, not a new raster-processing algorithm. The public artifact integrates provider-specific transformation, administrative aggregation, fail-closed provenance labelling, explicit data terms, positive and negative tests, a geometry-agnostic portability fixture, public-data numerical validation, continuous integration, and versioned archival practice. Rwanda is the real-data reference implementation. Portability is claimed only at the function-interface level demonstrated with arbitrary identifiers and projected synthetic geometry; end-to-end deployment in a second country has not been evaluated. The artifact excludes the private parent dashboard, disease-side signals, patient or surveillance data, decision rules, and operational interfaces.

## Design and Implementation

### Software objectives and architecture

The repository integrates six functions that are commonly separated across scripts, notebooks, platforms, or release records:

1. provider-specific acquisition and input handling;
2. reproducible transformation of rainfall, temperature, vegetation, and terrain products;
3. coverage-fraction-weighted aggregation into a common administrative GeoJSON schema;
4. fail-closed provenance labelling and per-file licence documentation;
5. account-free positive, negative, portability, and release-contract verification; and
6. scoped public-data numerical validation plus release-integrity checking.

Figure 1 shows the architecture. Source-specific modules isolate access, masking, scaling, mosaicking, reprojection, and temporal aggregation from the common polygon-extraction and output contract. Synthetic fixtures exercise transformation paths without provider credentials. Separate failure-injection and release-contract validators test whether malformed inputs or outputs are rejected rather than silently accepted. A public-data validation path independently reacquires CHIRPS and compares the archived values with two extraction implementations and an area-weighting sensitivity calculation.

The workflow does not replace Google Earth Engine, MODIStsp, `exactextractr`, Common Workflow Language tooling, or research-object standards. Its contribution is the release-level integration around these capabilities: multiple providers, a common district schema, an explicit evidence-status contract, account-free executable evidence, per-file terms, fixed integrity values, and an archived version. Table 2 summarizes the relationship between these adjacent tools or standards and the present workflow.

### Geographic reference implementation and portability boundary

The real-data aggregation frame comprises Rwanda's 30 second-level administrative districts. District geometry is derived from the World Bank Rwanda Admin Boundaries and Villages dataset under Creative Commons Attribution 4.0. Released geometry is stored in EPSG:4326 and contains district name and geometry only.

The generic transformation functions do not require Rwanda district names. A separate portability fixture uses arbitrary identifiers (`ALPHA-01`, `BETA-02`, and `GAMMA-03`) and three projected polygons in EPSG:3857. It verifies rainfall, temperature, HAND, and MODIS transformations against non-Rwanda identifiers and geometry without invoking Rwanda-specific directional gates. This supports interface and geometry independence at the function level. It does not demonstrate end-to-end portability in a second country, where different provider tiles, geometry complexity, network conditions, and local validation requirements may require additional configuration and evaluation.

### Environmental transformation modules

Three layers describe calendar year 2023 and one represents static terrain:

- **Rainfall:** CHIRPS version 2.0 annual precipitation (Funk et al. 2015). Negative no-data values are masked, coverage-fraction-weighted district means are calculated, and released values are rounded to whole millimetres.
- **Temperature:** ERA5-Land 2 m air temperature (Muñoz-Sabater et al. 2021). Twelve monthly-mean layers for 2023 are checked for completeness, averaged, converted from kelvin to degrees Celsius, and summarized by district.
- **Vegetation greenness:** MODIS/Terra MOD13A3 version 061 monthly 1 km NDVI (Didan 2021). Fill and out-of-range values are masked, the 0.0001 scale factor is applied, same-month tiles are mosaicked, and the 12 monthly products are averaged before district extraction. Product quality and reliability flags are not applied in this release.
- **Low-lying terrain share:** Global 30 m HAND, derived from Copernicus GLO-30, is thresholded at 5 m. The output is the percentage of district area represented by HAND values at or below the threshold. It is not observed flooding or a validated flood-hazard probability. The terrain concept follows Nobre et al. (2011).

District values are calculated with `exactextractr` 0.10.1, using the fraction of each raster cell covered by a polygon as the aggregation weight (Baston 2025). Product no-data sentinels are masked before extraction, and a build stops when any administrative unit lacks a valid value.

Each real-data builder applies bounded-value and broad directional consistency gates intended to detect gross unit, coordinate-system, threshold, or inversion errors. For example, the Rwanda temperature gate checks that the western longitudinal third is cooler than the eastern third. These are software tripwires, not substitutes for independent numerical or scientific validation.

### Provenance-labelling contract

The provenance module consumes a register row containing an identifier, display label, method, palette, evidence class, method class, and citation. The contract is:

- `source-derived` requires a documented method applied to real or public data;
- a placeholder method cannot be `source-derived`;
- unknown, incomplete, synthetic, and placeholder entries default to `illustrative`; and
- illustrative outputs receive an explanatory note.

Figure 3 separates the implementation into three independent controls. First, `surt_method_register_ok()` validates the required register structure, legal vocabularies, and the prohibition on combining `source-derived` evidence with a `placeholder` method. Second, `surt_output_is_illustrative()` applies the fail-closed display rule independently: an output remains illustrative unless its identifier is present and its `evidence_class` is exactly `source-derived`; this function does not inspect `method_class` or independently verify that real or public data were used. Third, `surt_illustrative_note()` selects one wording for a documented method on synthetic data and another for synthetic, placeholder, unknown, or incomplete material. The module validates declarations and presentation behaviour. It does not independently establish that a citation is correct, that every external application routes values through the module, or that a declared method was implemented faithfully outside the released repository. Provenance is recorded as human-readable file and feature metadata; the current release does not claim PROV-O or RO-Crate conformance.

### Input and output contract

The real builders accept a period or threshold plus optional paths for output, aggregation geometry, and local cache. Default outputs are written to `generated/`; provider downloads are cached under `cache/`. Both directories are excluded from version control.

Each environmental output is a GeoJSON FeatureCollection with 30 district features. A feature contains the district identifier, one environmental value, geometry, and a provenance string naming the source, product, period or threshold, and applicable terms. `DATA_DICTIONARY.md` defines the fields, while `NOTICE.md` records attribution and licence information.

An independent Python validator uses only the standard library and therefore does not reuse the R geospatial stack that produced the files. It checks the five archived GeoJSON files for FeatureCollection structure, declared or implicit WGS84 coordinates, 30 unique identifiers, exact property schemas, finite bounded values, required provenance tokens, identical district order, and byte-normalized geometry identity across layers. It then corrupts in-memory copies and requires rejection of a duplicate district, missing provenance, impossible value, substituted geometry, and undeclared property.

### Verification design

`renv.lock` records the R dependency graph. The published base release was prepared with R 4.6.0, `terra` 1.9.27, `sf` 1.1.1, `exactextractr` 0.10.1, and `jsonlite` 2.0.0. Python 3 is used by provider fetchers, the cross-platform verification runner, the independent release-contract validator, and the checksum-manifest builder.

The account-free verification command is:

```text
python python/run_all_checks.py
```

The runner executes 41 explicit outcomes in six groups:

- nine provenance-labelling assertions;
- nine controlled environmental-transformation assertions;
- six geometry-agnostic portability assertions;
- seven transformation failure-injection assertions;
- five valid release-layer contract checks; and
- five deliberate release-corruption rejections.

Table 3 maps the principal software claims to the corresponding release evidence and verification mechanism.

The environmental fixture creates synthetic rasters in memory and exercises rainfall, temperature, NDVI, HAND, reprojection, mosaicking, temporal aggregation, zonal extraction, and GeoJSON writing. Its NDVI path uses two synthetic months and two same-month tiles in the MODIS sinusoidal coordinate system. Failure injection tests absent raster coverage, unconverted kelvin values, an inverted rainfall gradient, unscaled MODIS digital numbers, an incomplete MODIS year, all-no-data HAND input, and impossible HAND percentages. The runner records step durations and execution-environment metadata in machine-readable JSON.

For version 1.2.0, `CHECKSUMS.sha256` is generated with `python/build_checksum_manifest.py --all-tracked --write` and covers every tracked file except the manifest itself. The runner requires `--all-tracked --check` to reproduce that exact scope and then verifies every listed digest. `CHECKSUMS.scope` is retained as a historical development-scope record. The committed manifest corresponds to the DOI-bearing release tree. A checksum establishes byte integrity, not scientific validity.

GitHub Actions restores the locked environment, repeats the account-free checks on a clean hosted runner, generates manuscript figures from the GeoJSON files, and retains the evidence bundle.

### Public-data numerical validation

The CHIRPS layer has an additional account-free validation workflow. It independently downloads the public CHIRPS v2.0 annual 2023 GeoTIFF, reads the archived district geometry, and recomputes district means with `exactextractr`, the release method. It then performs an implementation cross-check with `terra::extract` using exact polygon-cell fractions. Finally, it applies a latitude-varying cell-area raster as an additional weight to quantify sensitivity to the use of coverage fractions in geographic coordinates.

The prespecified acceptance gates require all 30 archived whole-millimetre values to equal the rounded recomputation and the maximum cross-implementation difference to remain at or below 2 mm. Machine-readable district results, summary metrics, and the source-raster SHA-256 digest are retained as a workflow artifact. This validates computational reproduction of the CHIRPS layer, not the observational accuracy of CHIRPS itself. Equivalent independent numerical validation has not yet been completed for ERA5-Land, MODIS, or HAND.

### Real-data operation

The four real-data builders can be invoked from any working directory:

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

The CHIRPS and HAND builders require network access. ERA5-Land and MODIS additionally require free Copernicus Climate Data Store and NASA Earthdata accounts. Credentials are read from provider-standard local files and are not stored in the repository. The public rainfall validation is run with:

```text
Rscript R/validate_chirps_rainfall.R 2023
```

### Use of generative AI

OpenAI ChatGPT and Codex tools and Anthropic Claude were used during July 2026 for coding assistance, repository-quality review, critical appraisal, and manuscript drafting and editing. The author directed these uses, inspected proposed changes against the repository and cited sources, reran the reported checks, and remains accountable for the software and manuscript. No AI tool generated the provider data, the archived district values, or an analytical result reported as empirical evidence.

## Results

### Prepared district layers

Every environmental output contains one feature for each of Rwanda's 30 districts. Table 1 summarizes the released values and Figure 2 shows their spatial distribution. The western longitudinal third was cooler than the eastern third (17.5 versus 21.1 degrees Celsius) and had a smaller low-lying terrain share (14.6% versus 22.8%). These comparisons passed the released directional gates; they are not comparisons with an independent reference dataset.

For a record-level example, the Nyarugenge features contain annual rainfall of 955 mm, mean temperature of 20.6 degrees Celsius, mean NDVI of 0.55, and a low-lying terrain share of 22.1%. The last value means that 22.1% of the district polygon is represented by HAND values of 5 m or less. It must not be interpreted as observed flood extent, flood probability, population exposure, or risk.

Supplementary Figure S1 standardizes values within each layer to compare district profiles despite different units. The profile is descriptive and is not a composite environmental, hazard, or health-risk index.

### Account-free verification and release-contract results

All 41 explicit verification outcomes passed on the clean hosted runner. The positive fixtures established expected transformations on controlled inputs. The projected portability fixture completed with arbitrary administrative identifiers and non-Rwanda geometry. Each deliberately malformed transformation failed for the intended reason. The independent validator accepted all five archived GeoJSON files and rejected all five corrupted copies. The checksum builder confirmed that the complete all-tracked manifest matched the frozen repository scope, and every listed digest was verified.

These outcomes support claims about specified software behaviour, schema enforcement, failure handling, and listed-file integrity. They do not establish source-product accuracy, scientific validity of the HAND threshold, cross-country real-data portability, or suitability for a downstream model.

### CHIRPS numerical validation

The public CHIRPS validation reacquired the 2023 annual GeoTIFF and reproduced all 30 archived rainfall values exactly after rounding to whole millimetres. The maximum absolute difference between the `terra` and `exactextractr` district means was 0.000136 mm, with a root mean square difference of 0.000064 mm. Adding cell-area weights changed district means by at most 0.005127 mm, with a root mean square difference of 0.002385 mm.

For this source raster, year, geography, and geometry, the implementation cross-check and area-weighting sensitivity were negligible relative to the released whole-millimetre precision. These results do not establish the observational accuracy of CHIRPS, and they cannot be generalized to other products, spatial resolutions, latitudes, or administrative frames without testing.

### Example uses and interpretation boundary

A researcher preparing administrative environmental covariates can run the builders or read an archived candidate release, retain the provenance string and per-file terms, and perform downstream analysis separately. A supported statement is: “The prepared 2023 annual-rainfall layer contains 955 mm for Nyarugenge.” Unsupported statements include claims about disease causation, future weather, flood probability, population exposure, resource allocation, or intervention effectiveness.

A developer preparing a demonstration that mixes empirical context with synthetic indicators can route registered values through the provenance module. Source-derived entries retain that label only when the required declarations are complete; unknown or synthetic entries remain illustrative and receive a visible note.

## Discussion

The principal contribution is an integrated and auditable Earth-data workflow rather than a novel numerical algorithm. The software combines multi-provider preprocessing, administrative aggregation, standardized outputs, explicit source terms, fail-closed provenance labelling, positive and negative tests, geometry-agnostic function checks, independent release-contract validation, scoped public-data numerical validation, continuous integration, and versioned archival practice. This combination treats acquisition, transformation, interchange, interpretation, verification, and preservation as one informatics problem.

The evaluation follows an evidence hierarchy. Controlled fixtures establish transformation behaviour; negative tests establish failure handling; the projected fixture probes generic geometry interfaces; the independent Python validator checks the released contract without reusing the R stack; checksums establish listed-file integrity; and the CHIRPS workflow adds a second extraction implementation and an area-weighting sensitivity calculation on public source data. No single layer of evidence is presented as sufficient for every claim.

The CHIRPS results close one concrete numerical-reproducibility gap. They show that the archived rounded values are reproducible from the public annual raster and that two extraction engines and two weighting treatments give effectively identical district means at the release precision. The validation remains methodologically scoped. Both engines used the same source raster and district geometry, so agreement does not validate the source product. ERA5-Land, MODIS, and HAND still require equivalent independent checks, and HAND additionally requires application-specific validation before any hazard interpretation.

The portability fixture narrows another claim. It demonstrates that the core functions operate with arbitrary identifiers and projected non-Rwanda polygons. It does not demonstrate an end-to-end deployment in another country. A stronger portability study would use at least one second national administrative frame with different geometry complexity and tile coverage, then report required code changes, provider-access behaviour, execution time, missingness, and numerical consistency.

The design is related to broader provenance and research-object approaches but remains intentionally lightweight. Human-readable provenance strings, file-level documentation, checksums, machine-readable test summaries, and a versioned archive improve inspectability. They do not constitute a formal provenance graph or a standards-conformant research object. Future packaging could adopt PROV-O, RO-Crate, or Workflow Run RO-Crate where the additional semantic and interoperability benefits justify the maintenance burden (Lebo et al. 2013; Soiland-Reyes et al. 2022).

The release has further limitations. Annual district summaries suppress seasonality, extremes, and within-district heterogeneity. MODIS quality flags are not applied. Environmental values are point estimates without uncertainty or quality fields. Provider-dependent rebuilds require accounts and network access. The real-data implementation covers one country and one reference year. Only the CHIRPS layer currently has independent public-data computational validation. Version 1.2.0 extends the published v1.1.1 base archive and is archived at DOI 10.5281/zenodo.21744708 under Git tag `v1.2.0`. Table 4 consolidates these limitations and their interpretation consequences.

Future work should add MODIS quality filtering, monthly and seasonal summaries, uncertainty and data-quality fields, independent ERA5-Land, MODIS, and HAND comparisons, cross-platform real-data rebuilds, a second-country portability study, and standards-based research-object metadata. These additions would strengthen scientific validation and machine-actionable reuse without changing the core release contract.

## Conclusions

The workflow converts four heterogeneous Earth-data products into standardized, provenance-labelled layers for Rwanda's 30 districts and packages the process as a testable research artifact. Its contribution is the integration of source-specific processing, administrative aggregation, fail-closed evidence classification, positive and negative verification, release-contract enforcement, scoped numerical validation, and integrity controls. The CHIRPS layer reproduces exactly at the archived precision and shows negligible cross-engine and area-weighting differences for the tested case. The other source-derived layers retain explicit validation limits. The reference implementation is suitable for transparent preparation of descriptive environmental inputs and for applications that must distinguish source-derived evidence from illustrative content. It is not an epidemiological model, forecasting platform, validated hazard model, or operational decision system.

## Availability and Requirements

- **Project name:** SuRT-Virtual Rwanda reproducibility artifact
- **Project home page:** https://github.com/PrinceAudre/surt-virtual-rwanda-repro
- **Published base archive:** version 1.1.1, https://doi.org/10.5281/zenodo.21677162
- **Release archive:** version 1.2.0, https://doi.org/10.5281/zenodo.21744708, Git tag `v1.2.0`
- **Operating systems:** Linux, Windows, or macOS for the account-free workflow; real-data provider clients are subject to their own platform requirements
- **Programming languages:** R 4.6.0 and Python 3
- **Core dependencies:** `terra`, `sf`, `exactextractr`, and `jsonlite`, with versions recorded in `renv.lock`
- **Hardware:** no specialized hardware is required for account-free verification
- **Other requirements:** internet access for real-data acquisition; free Climate Data Store and NASA Earthdata accounts for ERA5-Land and MODIS rebuilds
- **Licence:** MIT for code; data retain the per-file terms documented in `NOTICE.md`
- **Restrictions on non-academic use:** none for the MIT-licensed code; users must comply with source-data terms

The version 1.2.0 source tree, manuscript, metadata, figures, and complete tracked-file checksum manifest are synchronized to the immutable archive DOI 10.5281/zenodo.21744708 and Git tag `v1.2.0`. Journal submission uses this exact archived version.

## Statements and Declarations

### Ethics approval and consent

No human participants, animals, patient records, personal data, confidential records, or real surveillance data were used. The artifact contains openly available environmental products and synthetic software-test fixtures. Ethical approval and consent were therefore not required.

### Funding

No grants supported this work.

### Competing interests

The author has undertaken contractual research coordination work for the Clinton Health Access Initiative. The software and manuscript were developed and are presented in the author's independent capacity and do not imply institutional sponsorship or endorsement.

### Author contributions

Tuyishime Audre Prince: Conceptualization, Data Curation, Methodology, Software, Validation, Visualization, Project Administration, Writing – Original Draft, and Writing – Review and Editing.

### Data and software availability

The complete version 1.2.0 outputs, software, validators, numerical-validation workflow, figures, integrity metadata, and journal-packaging files are archived at Zenodo DOI 10.5281/zenodo.21744708 (Tuyishime 2026). The earlier version 1.1.1 archive remains the historical base at DOI 10.5281/zenodo.21677162.

The repository contains district geometry and four environmental GeoJSON layers. `NOTICE.md` supplies per-file attribution and licence information, `DATA_DICTIONARY.md` defines fields, and `CHECKSUMS.sha256` supplies the complete all-tracked integrity contract; `CHECKSUMS.scope` is retained only as a historical development-scope record. No disease data are associated with the article.

ERA5-Land is third-party data under the Copernicus Products licence. A reader can obtain it through the same route as the author by creating a free Climate Data Store account, accepting the product terms, configuring the official `cdsapi` client, and running `python/fetch_era5land_temperature.py`. The corresponding transformation is implemented in `R/build_relief_climate_temperature.R`.

## References

Baston D (2025) exactextractr: fast extraction from raster datasets using polygons. R package version 0.10.1. https://doi.org/10.32614/CRAN.package.exactextractr

Busetto L, Ranghetti L (2016) MODIStsp: an R package for automatic preprocessing of MODIS Land Products time series. Comput Geosci 97:40–48. https://doi.org/10.1016/j.cageo.2016.08.020

Didan K (2021) MODIS/Terra Vegetation Indices Monthly L3 Global 1 km SIN Grid V061 [Dataset]. NASA EOSDIS Land Processes Distributed Active Archive Center. https://doi.org/10.5067/MODIS/MOD13A3.061

Funk C, Peterson P, Landsfeld M et al (2015) The climate hazards infrared precipitation with stations – a new environmental record for monitoring extremes. Sci Data 2:150066. https://doi.org/10.1038/sdata.2015.66

Gorelick N, Hancher M, Dixon M et al (2017) Google Earth Engine: planetary-scale geospatial analysis for everyone. Remote Sens Environ 202:18–27. https://doi.org/10.1016/j.rse.2017.06.031

Kale A, Sun Z, Ma X (2023) Utility of the Python package Geoweaver_cwl for improving workflow reusability: an illustration with multidisciplinary use cases. Earth Sci Inform 16:2955–2961. https://doi.org/10.1007/s12145-023-01045-0

Lebo T, Sahoo S, McGuinness D (eds) (2013) PROV-O: The PROV Ontology. W3C Recommendation, 30 April 2013. https://www.w3.org/TR/prov-o/

Mitchell SN, Lahiff A, Cummings N et al (2022) FAIR data pipeline: provenance-driven data management for traceable scientific workflows. Philos Trans R Soc A 380(2233):20210300. https://doi.org/10.1098/rsta.2021.0300

Muñoz-Sabater J, Dutra E, Agustí-Panareda A et al (2021) ERA5-Land: a state-of-the-art global reanalysis dataset for land applications. Earth Syst Sci Data 13:4349–4383. https://doi.org/10.5194/essd-13-4349-2021

Nobre AD, Cuartas LA, Hodnett M et al (2011) Height Above the Nearest Drainage – a hydrologically relevant new terrain model. J Hydrol 404:13–29. https://doi.org/10.1016/j.jhydrol.2011.03.051

Soiland-Reyes S, Sefton P, Crosas M et al (2022) Packaging research artefacts with RO-Crate. Data Sci 5(2):97–138. https://doi.org/10.3233/DS-210053

Tuyishime AP (2026) SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.2.0. Zenodo [Software]. https://doi.org/10.5281/zenodo.21744708

Wilkinson MD, Dumontier M, Aalbersberg IJ et al (2016) The FAIR Guiding Principles for scientific data management and stewardship. Sci Data 3:160018. https://doi.org/10.1038/sdata.2016.18

Zong L, Ngarukiyimana JP, Yang Y et al (2024) Malaria transmission risk is projected to increase in the highlands of Western and Northern Rwanda. Commun Earth Environ 5:559. https://doi.org/10.1038/s43247-024-01717-9

## Tables

### Table 1 Per-district summaries across Rwanda's 30 districts

| Layer | Field | Minimum | Maximum | Mean | Temporal basis |
|---|---|---:|---:|---:|---|
| Rainfall | `annual_rainfall_mm` | 917 | 1,489 | 1,163 | CHIRPS v2.0 annual total, 2023 |
| Temperature | `mean_temp_c` | 15.7 | 21.9 | 19.4 | ERA5-Land mean of 12 monthly means, 2023 |
| Vegetation greenness | `mean_ndvi` | 0.49 | 0.71 | 0.61 | MODIS MOD13A3 v061 mean of 12 monthly products, 2023 |
| Low-lying terrain share | `low_lying_share_pct` | 8.6 | 31.8 | 18.0 | HAND ≤5 m, static terrain |

### Table 2 Relationship to adjacent tools and standards

| Tool or standard | Primary role | Relationship to this workflow |
|---|---|---|
| Google Earth Engine | Cloud-scale geospatial catalogue and computation | Alternative execution environment for large analyses; does not define this repository's district-output, evidence-status, archive, and integrity contract |
| MODIStsp | Automated MODIS acquisition and preprocessing | More specialized and feature-rich for MODIS; this workflow integrates MODIS with CHIRPS, ERA5-Land, and HAND in one administrative release |
| `exactextractr` | Efficient polygon extraction and zonal summaries | Core dependency used for district aggregation; this workflow adds source handling, transformations, evidence classification, tests, outputs, and archive metadata |
| Geoweaver_cwl / CWL | Workflow description, portability, and reuse | Demonstrates standardized workflow representation; the present artifact uses explicit scripts and CI rather than claiming CWL conformance |
| PROV-O and RO-Crate | Formal provenance representation and research-artifact packaging | Inform future machine-actionable packaging; the present candidate records lightweight provenance and does not claim standards conformance |
| Released workflow | Cross-provider Earth-data preparation and evidence labelling | Provides the integrated release contract and multi-layer evaluation described in this article |

### Table 3 Claim-to-evidence mapping

| Software claim | Release evidence | Verification |
|---|---|---|
| Unknown or incomplete entries default to illustrative | `R/provenance_value_class.R` | Nine assertions in `R/demo_value_class.R` |
| Environmental transformations execute on controlled inputs | Transformation modules and in-memory rasters | Nine assertions in `R/test_fixture_pipeline.R` |
| Core transformations do not require Rwanda identifiers or geographic coordinates | Projected arbitrary-identifier fixture | Six assertions in `R/test_portability_fixture.R` |
| Malformed transformation inputs are rejected | Seven injected error conditions | `R/test_failure_modes.R` |
| Five GeoJSON layers follow one exact district contract | Independent Python standard-library validator | Five valid-layer checks in `python/validate_release_contract.py` |
| Schema drift and corrupted release content are rejected | Five corrupted in-memory copies | Five rejection checks in `python/validate_release_contract.py` |
| Archived CHIRPS district values are computationally reproducible | Public CHIRPS 2023 GeoTIFF and archived geometry | 30/30 rounded matches in `R/validate_chirps_rainfall.R` |
| CHIRPS extraction is stable across engines and area weighting | `exactextractr`, `terra`, and cell-area weights | Maximum differences of 0.000136 mm and 0.005127 mm |
| Complete release manifest matches the tracked-file scope | `CHECKSUMS.sha256` and manifest builder | `python/build_checksum_manifest.py --all-tracked --check` |
| Every release file has its recorded digest | `CHECKSUMS.sha256` | SHA-256 verification in `python/run_all_checks.py` |
| R dependencies are versioned | `renv.lock` and `environment.txt` | Clean-environment restore and continuous integration |

### Table 4 Principal limitations and interpretation

| Limitation | Consequence |
|---|---|
| Annual district summaries | Seasonality, extremes, and within-district variation are not represented |
| MODIS quality flags not applied | Residual low-quality observations may contribute to district means |
| HAND ≤5 m is a selected terrain threshold | The output is not observed flooding, probability, or validated hazard |
| Point estimates lack uncertainty and quality fields | Downstream users must evaluate product and aggregation uncertainty separately |
| Directional consistency gates | They detect gross errors but do not validate exact values |
| Real-data implementation covers one country | Function-level geometry portability does not establish second-country deployment portability |
| Independent public-data validation covers CHIRPS only | ERA5-Land, MODIS, and HAND require equivalent checks before stronger numerical claims |
| Provider-dependent rebuilds require accounts and network access | Only the fixtures, contract checks, and CHIRPS validation are fully account-free |
| Lightweight provenance is not PROV-O or RO-Crate conformant | Machine-actionable interoperability remains limited |
| Version 1.2.0 extends the published v1.1.1 base | Reuse and submission must cite the immutable version DOI 10.5281/zenodo.21744708 and exact tag `v1.2.0` |

## Figure captions

**Fig. 1** Cross-provider Earth-data preparation and auditable release contract. Provider-specific products pass through documented acquisition, masking, scaling, temporal aggregation, administrative aggregation, provenance classification, and release-integrity controls. Synthetic fixtures exercise transformation and failure paths without provider accounts. The public CHIRPS pathway provides a scoped numerical reproduction and sensitivity analysis; it does not validate the source product itself

**Fig. 2** Spatial distribution of four district-level environmental layers for Rwanda. (a) CHIRPS annual rainfall for 2023, in millimetres; (b) ERA5-Land mean 2 m air temperature for 2023, in degrees Celsius; (c) MODIS MOD13A3 mean NDVI for 2023; and (d) percentage of district area represented by HAND values of 5 m or less. The HAND layer is a static relative-elevation descriptor and must not be interpreted as observed flooding or flood probability

**Fig. 3** Three independent provenance controls implemented in `R/provenance_value_class.R`. Register validation checks required fields and legal vocabularies and rejects `source-derived` combined with `placeholder`. Display classification is fail closed: an output is illustrative unless its identifier is present and its `evidence_class` is exactly `source-derived`; this step does not inspect `method_class` or independently verify real-data use. Illustrative-note selection uses one wording for a documented method on synthetic data and another for synthetic, placeholder, unknown, or incomplete material. Register validity is not shown as a prerequisite for the display or note functions because the functions can be called independently.

**Supplementary Fig. S1** Standardized district profiles across the four environmental layers. Values are expressed as within-layer z scores to permit comparison despite different physical units. District ordering is based on the first principal component of the four standardized layers. The plot is descriptive and does not represent an epidemiological risk score, hazard index, or causal model

## Software Files

Version 1.2.0 contains the base software and district outputs together with the validators, numerical-validation workflow, figure pipeline, machine-readable evidence summaries, manifest builder, and submission records described in this manuscript. The release is archived at https://doi.org/10.5281/zenodo.21744708 and identified by Git tag `v1.2.0`.

Principal directories and files are:

- `R/`: provider transformation functions, real-data builders, provenance classification, positive fixtures, portability fixture, failure-injection tests, CHIRPS numerical validation, and manuscript-figure generation;
- `python/`: provider fetch clients, cross-platform verification runner, independent GeoJSON release-contract validator, and checksum-manifest builder;
- `data/`: district geometry and four environmental GeoJSON layers;
- `renv.lock` and `environment.txt`: dependency and execution-environment records;
- `NOTICE.md` and `DATA_DICTIONARY.md`: source terms, attribution, and field definitions;
- `CHECKSUMS.sha256`: complete all-tracked integrity manifest; `CHECKSUMS.scope`: historical development-scope record;
- `.github/workflows/reproducibility.yml`: clean account-free verification and figure-generation workflow;
- `.github/workflows/public-data-validation.yml`: public CHIRPS reproduction and sensitivity workflow; and
- `paper/`: manuscript, journal-targeting record, dual-agent review ledger, editorial-readiness record, reviewer dossier, historical records, and figure-accessibility instructions.
