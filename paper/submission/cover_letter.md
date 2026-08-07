7 August 2026

Editors-in-Chief
SoftwareX

Dear Editors,

Please consider the manuscript, **“SuRT-GeoHarmonizer: An auditable R and Python workflow for administrative-scale Earth-data harmonization and provenance labelling,”** for publication as an **Original Software Publication** in SoftwareX.

SuRT-GeoHarmonizer is an open command-line workflow that converts environmental rasters and polygon boundaries into consistent, provenance-labelled administrative-unit GeoJSON layers. Its principal contribution is the integration of a provider-agnostic harmonization interface with provider-specific reference builders, fail-closed evidence classification, controlled positive and negative tests, independent output-contract validation, and versioned release-integrity records.

The software is relevant to SoftwareX because it is publicly inspectable, reusable beyond its Rwanda reference implementation, and intended to support reproducible research across environmental science, climate-health, ecology, agriculture, exposure analysis, and other domains that use polygon-level raster summaries. A complete account-free pathway exercises 48 explicit behavioural and contract outcomes without private data, provider credentials, or network access. A separate public-data workflow independently reproduces the archived CHIRPS rainfall layer and cross-checks two extraction implementations.

The manuscript and repository maintain strict interpretation boundaries. The software prepares descriptive environmental covariates; it does not produce validated hazards, forecasts, epidemiological effects, exposure estimates, or operational recommendations. The paper also distinguishes controlled software verification, public-data numerical reproduction, and byte-level integrity rather than treating one as evidence of another.

The code is released under the MIT License. Bundled source-derived data and geometry are redistributed under documented source-specific terms, including CC BY 4.0, public-domain or CC0 terms, and the Copernicus Products licence. The repository contains no patient, surveillance, confidential operational, or private application data. The source, tests, documentation, machine-readable metadata, and release records are available at:

https://github.com/PrinceAudre/surt-virtual-rwanda-repro

The SoftwareX-facing release is version 1.3.0. Its version-specific Zenodo DOI is `10.5281/zenodo.21840177`, reserved for the exact validated `v1.3.0` archive and registered when that archive is published. The Zenodo concept DOI for the software series is `10.5281/zenodo.21671788`.

I confirm that this manuscript is original, is not under consideration elsewhere, and has not undergone external peer review. An earlier manuscript version was not advanced to peer review by another journal because its editorial scope did not align with the work. The present submission has been substantively rebuilt around the SoftwareX Original Software Publication format, reusable software interface, and open-software evidence expected by this journal.

I am the sole author and take responsibility for the software, source and licence statements, analysis, manuscript, and submission. I declare no competing interests and no specific funding for this work. OpenAI ChatGPT and Codex and Anthropic Claude were used for coding support, critical review, and language editing; I reviewed all outputs, verified the reported evidence, and remain responsible for the final content.

Thank you for considering this submission.

Sincerely,

TUYISHIME AUDRE PRINCE
Independent Researcher
Kigali, Rwanda
ORCID: 0009-0002-0799-3140
Email: priplee@gmail.com
