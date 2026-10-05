# DRAFT FOR v1.4.0 RELEASE FREEZE

> **DO NOT SUBMIT YET.** Remove this notice only after the exact v1.4.0 release commit has passed the final manifest, review, rendering, tag, GitHub release, and Zenodo DOI gates. The final letter must state the exact v1.4.0 version DOI.

Editors
Array

Dear Editors,

Please consider the transferred and substantially strengthened manuscript, **"SuRT-GeoHarmonizer: A contract-first workflow for verifiable raster-to-administrative data harmonization,"** for publication in **Array**.

The manuscript was previously evaluated by SoftwareX as `SOFTX-D-26-01014` and received external peer review on 2 October 2026. Elsevier subsequently offered an Article Transfer, which I accepted for Array. The present package retains that review history while rebuilding the manuscript around a narrower and more defensible contribution, updated prior-art analysis, explicit research questions, and stronger software-evaluation evidence.

SuRT-GeoHarmonizer is an open R and Python workflow for converting environmental rasters and polygon boundaries into provenance-labelled administrative-unit outputs under an explicit software contract. The workflow separates rectangular raster-grid support from finite and quality-accepted support, emits their overall product as an invariant-checked field, validates declarative jobs fail closed, tests an out-of-tree provider-adapter boundary, independently cross-checks numerical outputs, and binds release claims to exact tracked-file integrity controls.

The manuscript does **not** claim a new zonal-statistics algorithm. Mature tools such as exactextractr, terra, GDAL, xagg, and spatcovar already provide core extraction and coverage capabilities. The revised related-work analysis also treats DART-Pipeline/geoglue, DHIS2 climate tooling, stagg, Climate-CAFE and other adjacent systems as established prior art. The contribution claimed here is therefore the evaluated integration and assurance contract around a bounded raster-to-administrative handoff, not priority over the underlying geospatial operations.

The evaluation addresses five research questions. Controlled fixtures test the information value of decomposed support semantics; source-pinned CHIRPS, ERA5-Land, MODIS and HAND cases are checked against independent calculations; an external provider module is loaded without modifying the generic harmonizer or built-in registry; the same core contract is exercised across Rwanda and Uganda geometry and on Ubuntu, Windows and macOS under a bounded portability claim; and the mandatory support contract is benchmarked against a direct area-weighted mean using the same geospatial primitives.

The repository is public and released under the MIT License:

https://github.com/PrinceAudre/surt-virtual-rwanda-repro

The reviewer-remediated release is version 1.4.0, assigned Zenodo version DOI `10.5281/zenodo.23162055`. The previous v1.3.0 release, DOI `10.5281/zenodo.21840177`, remains immutable history. Before final submission, the exact DOI-bearing v1.4.0 tree will be manifest-verified, tagged, released on GitHub, archived in Zenodo, and checked to confirm that the DOI resolves to that exact release.

My affiliation has changed since the earlier SoftwareX submission. I am now affiliated with the School of Public Health, College of Medicine and Health Sciences, University of Rwanda. Development of the earlier software release predates this affiliation, and no institutional endorsement of the software is claimed.

I confirm that the manuscript is not under simultaneous consideration elsewhere. I am the sole author and take responsibility for the software, analyses, source and licence statements, evidence, manuscript, and submission. I declare no competing interests and no specific funding for this work.

As disclosed in the manuscript, OpenAI ChatGPT and Codex and Anthropic Claude were used during earlier development for coding assistance, critical review, and language editing. I reviewed and edited all outputs, reran the reported checks, verified the reported evidence and citations, and remain responsible for the final content. These tools did not generate source data or empirical results.

Thank you for considering this transferred manuscript.

Sincerely,

TUYISHIME AUDRE PRINCE
School of Public Health
College of Medicine and Health Sciences
University of Rwanda
Kigali, Rwanda
ORCID: 0009-0002-0799-3140
Email: priplee@gmail.com
