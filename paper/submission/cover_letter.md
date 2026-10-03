# DRAFT FOR v1.4.0 RELEASE FREEZE

> **DO NOT SUBMIT YET.** Remove this draft notice only after the exact v1.4.0 release commit has passed the final manifest, review, rendering, tag, GitHub release, and Zenodo DOI gates. The final letter must state the exact v1.4.0 version DOI.

Editors-in-Chief
SoftwareX

Dear Editors,

Please consider the substantially revised manuscript, **“SuRT-GeoHarmonizer: An auditable R and Python workflow for administrative-scale Earth-data harmonization and provenance labelling,”** for renewed consideration as an **Original Software Publication** in SoftwareX.

This work was previously evaluated under SoftwareX manuscript `SOFTX-D-26-01014` and received external peer review on 2 October 2026. The present version is a substantive technical rebuild responding to those reviews. The point-by-point response maps each reviewer concern to code changes, tests, manuscript revisions, continuous-integration evidence, and source-pinned numerical validation records.

SuRT-GeoHarmonizer is an open R and Python command-line workflow that converts environmental rasters and polygon boundaries into provenance-labelled administrative-unit GeoJSON. The revised software now separates raster-footprint coverage, finite-data coverage, and overall valid-data coverage; weights zonal contributions by polygon overlap and raster-cell surface area; exposes a fail-closed declarative JSON job contract and provider-adapter boundary; and includes a Snakemake evidence workflow with deliberate positive and negative tests.

The revision also adds direct evidence of reuse and independent numerical cross-checking. A source-derived Uganda CHIRPS 2023 case runs through the same configuration-driven generic workflow used by the reference implementation and agrees with an independent `terra` area-weighted calculation within 0.000016 mm, with complete reported coverage. Scoped source-pinned real-data checks also cover ERA5-Land temperature, MODIS/Terra MOD13A3 NDVI with pixel-reliability filtering, and HAND terrain-share calculations. These checks establish computational agreement for the stated cases and are not presented as validation of source-product observational accuracy.

The full reproducibility workflow is continuously exercised on Ubuntu. A separate dependency-light core smoke matrix passes on Ubuntu 24.04, Windows 2025, and macOS 14. The manuscript explicitly distinguishes this operating-system evidence from geographic portability and does not claim that credentialed provider acquisition has been exercised on every platform.

The software contribution is an integrated administrative-data and release-evidence contract rather than a new raster algorithm. The revised manuscript therefore compares SuRT-GeoHarmonizer with Google Earth Engine, MODIStsp, and `exactextractr` at the level of documented primary scope and built-in workflow contracts, without portraying those established tools as deficient.

The code is released under the MIT License. Source-derived data and geometry are redistributed only under documented source-specific terms. The repository contains no patient, surveillance, confidential operational, or private application data. Provider credentials remain external to the repository.

Public repository:

https://github.com/PrinceAudre/surt-virtual-rwanda-repro

The current immutable public baseline is version 1.3.0, DOI `10.5281/zenodo.21840177`. The reviewer-remediated version 1.4.0 is not yet released. Before this letter is submitted, the exact approved v1.4.0 commit will be frozen, validated with the complete tracked-file checksum manifest, tagged, archived in Zenodo, and assigned its own version-specific DOI. The final letter must replace this development statement with that exact release identity.

I confirm that the manuscript is not under simultaneous consideration elsewhere. I am the sole author and take responsibility for the software, source and licence statements, analyses, manuscript, and submission. I declare no competing interests and no specific funding for this work.

As disclosed in the manuscript, OpenAI ChatGPT and Codex and Anthropic Claude were used for coding assistance, critical review, and language editing. I reviewed and edited all outputs, reran the reported checks, verified the reported evidence and citations, and remain responsible for the final content. These tools did not generate source data or empirical results.

Thank you for considering the revised work.

Sincerely,

TUYISHIME AUDRE PRINCE
Independent Researcher
Kigali, Rwanda
ORCID: 0009-0002-0799-3140
Email: priplee@gmail.com
