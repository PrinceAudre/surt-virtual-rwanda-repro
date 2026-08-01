# Earth Science Informatics submission-readiness record

## Status

**Release-gated, not ready for submission.** The scientific, manuscript, reference, software-verification, public-CHIRPS-validation, and figure-review gates are closed. The candidate must still receive a frozen semantic version, complete tracked-file checksum manifest, exact Git tag, immutable Zenodo version DOI, final Springer DOCX/PDF package, and author-only sign-offs before submission.

The prior F1000Research readiness record is preserved at `paper/archive/F1000_EDITORIAL_READINESS_2026-07-31.md` and is not part of the active submission package.

## Submission identity

- **Target journal:** Earth Science Informatics
- **Article type:** Software article
- **Working title:** *An auditable cross-provider workflow for district-scale Earth-data harmonization and provenance labelling: software design and a Rwanda implementation*
- **Author:** Tuyishime Audre Prince
- **Location treatment:** Kigali, Rwanda, used as the truthful unaffiliated city and country unless the author identifies a current affiliation that accurately represents the circumstances of the work
- **ORCID:** 0009-0002-0799-3140
- **Corresponding email:** priplee@gmail.com
- **Working branch:** `codex/earth-science-informatics-refinement-v1.3.0`
- **Draft pull request:** #7
- **Closed review baseline:** `952fda78611358416706202ec15f811072961c4b`

## Scientific and editorial gates

| Gate | Required evidence | Current status |
|---|---|---|
| Contribution is an Earth-science informatics artifact rather than a conventional regional GIS application | Introduction, comparison table, architecture figure, explicit non-claims | Closed; dual-agent review accepted framing |
| Core transformation functions behave as specified | Nine-assertion environmental fixture | Passed in clean CI |
| Provenance classification fails closed | Nine-assertion provenance demonstration | Passed in clean CI |
| Generic transformations are not hard-coded to Rwanda names or coordinates | Six-assertion projected, arbitrary-identifier portability fixture | Passed; real cross-country portability remains explicitly unproven |
| Malformed inputs and unsafe states are rejected | Seven transformation failure-injection assertions | Passed in clean CI |
| Archived GeoJSON files satisfy a common release contract | Five layer-contract checks covering schema, identifiers, values, provenance, CRS, order, and exact geometry identity | Passed in clean CI |
| Deliberate release corruption is rejected | Duplicate identifier, missing provenance, impossible value, geometry substitution, and undeclared-field tests | Passed in clean CI |
| At least one public source-derived layer receives independent numerical scrutiny | CHIRPS reproduction, `terra` versus `exactextractr`, and cell-area sensitivity workflow | Passed; evidence artifact inspected; scope remains limited to CHIRPS |
| Every principal manuscript claim maps to inspectable evidence or an explicit limitation | Claim-to-evidence table and dual-agent ledger | Closed for current candidate text |
| Verification is not misrepresented as scientific, hazard, epidemiological, or operational validation | Methods, Discussion, limitations table, conclusion | Closed for current candidate text; repeat after DOI substitution |
| References and cross-references are structurally complete | Primary-source reference audit and executable manuscript audit | Passed |
| Figures are semantically accurate, accessible, and journal-formatted | Canonical EPS/SVG/TIFF render, alternative text, dual-agent review, pixel inspection | Closed at `952fda7` |

## Journal-structure gates

The active manuscript retains the journal's Software article structure:

- Abstract
- Introduction
- Design and Implementation
- Results
- Discussion
- Conclusions
- Availability and Requirements
- Software Files
- Declarations
- References

The abstract is within the 150 to 250 word range, the manuscript uses six unique keywords, references follow a consistent author-year style, and the executable manuscript audit passes. All software, data, and repository identifiers must still be synchronized to the exact immutable candidate version submitted.

## Figure gate closure

The current canonical figure set is accepted for release-freeze preparation:

1. Figure 1 is caption-free vector line art showing the production workflow and independent evidence paths.
2. Figure 2 is a 600 dpi four-panel TIFF with numeric intervals and Cividis mapping; individual maps are retained as SVG and EPS.
3. Figure 3 is caption-free SVG/EPS line art representing the three independently callable provenance controls branch by branch.
4. Supplementary Figure S1 is a 600 dpi TIFF and EPS profile chart using Okabe-Ito colours, distinct point symbols, and distinct line types.
5. Figure 3's final `Return empty string` box has exact zero polygon overlap with the adjacent decision diamond.
6. Supplementary Figure S1's zero reference line is clipped to the plot region; overflow is enabled only for the external legend.
7. Alternative text and accessibility checks are recorded in `paper/figures/ALT_TEXT.md`.
8. Canonical files were generated by CI and visually inspected at final head `952fda7`.

Any change to figure-generating code after the release freeze reopens this gate and requires a new canonical render and inspection.

## Candidate-release gates

The published v1.1.1 archive, DOI `10.5281/zenodo.21677162`, predates the journal-candidate validators, figures, timing metadata, and public-data validation. It cannot be presented as containing those additions.

Before submission:

1. Obtain author approval to freeze the candidate source tree and select the new semantic version.
2. Update `DESCRIPTION`, `CITATION.cff`, `CHANGELOG.md`, README, manuscript, and release-facing file names to the same version.
3. Generate a complete all-tracked checksum manifest with `python/build_checksum_manifest.py --all-tracked --write`.
4. Run all account-free verification, candidate-metadata, manuscript-audit, figure-generation, and public-data-validation workflows on the exact release commit.
5. Tag the exact release commit on GitHub.
6. Create the corresponding Zenodo version under the existing concept record and obtain its immutable version DOI.
7. Replace the published-base version and DOI references in release-facing manuscript and metadata fields with the new immutable version and DOI, while retaining historical-base statements only where contextually required.
8. Confirm that the DOI archive contains every file cited as software, data, figure source, validation evidence, or supplementary material in the manuscript.
9. Re-run link, checksum, citation, metadata, and manuscript consistency audits after DOI insertion.
10. Record the exact submission commit, tag, GitHub release, Zenodo version, version DOI, checksum digest, and CI run identifiers.

No placeholder DOI or anticipated version number may appear in the submission.

## Submission-package cleanup

- Preserve declined F1000 material only under `paper/archive/` or with an explicit archival label.
- Retain the Earth Science Informatics-specific reviewer dossier and conflict-screening notes.
- Ensure the active `paper/submission/` directory contains only the final Earth Science Informatics manuscript and required supplementary files.
- Remove stale branch names, development versions, old DOI references, assertion counts, journal names, and submission instructions from release-facing documents.
- Confirm that no private parent-application code, disease data, credentials, or operational materials are included.

## Word-document and accessibility gates

The final Word file is built only after the release and DOI gates close. It must then pass all of the following:

- editable text and tables, not screenshots;
- correct heading hierarchy;
- title page with exact author metadata;
- abstract and keywords within journal limits;
- figures placed near first substantive mention or in the journal-accepted location;
- captions complete and consistent with figure files;
- table headings and notes understandable without body-text reconstruction;
- hanging-indent author-year references with complete DOI or stable links where available;
- no comments, tracked changes, hidden text, stale field codes, or broken cross-references;
- meaningful image alternative text;
- page-by-page visual inspection in DOCX and PDF rendering;
- final spell check and terminology consistency audit;
- exact agreement among Word metadata, manuscript text, Git tag, GitHub release, Zenodo version, and DOI.

## Declarations and author-only sign-offs

The author must personally verify:

1. Legal author-name order and spelling.
2. ORCID and corresponding email.
3. Truthful affiliation or unaffiliated city-country treatment.
4. Funding statement.
5. Competing-interest statement, including whether contractual CHAI work is relevant and whether any organisation sponsored or endorsed this artifact.
6. Author-contribution statement.
7. Ethics statement and confirmation that the released work uses no human-participant or patient data.
8. Data and code licensing statements.
9. Generative-AI disclosure.
10. Suggested-reviewer conflicts and current contact details.
11. Approval of the exact final manuscript, figures, supplementary files, release tag, checksum manifest, GitHub release, and Zenodo record.

## Dual-agent review closure

Claude and Codex completed the scientific, manuscript, reference, provenance, accessibility, and figure review cycle at `952fda78611358416706202ec15f811072961c4b`. Claude independently confirmed that the provenance implementation remained untouched, the final Figure 3 geometry has exact zero overlap, the manuscript and metadata audits pass, and Figure 3 plus Supplementary Figure S1 are submission-grade. Earlier Claude `handoff/` and `handoff2/` patches are superseded and must not be reapplied.

A new review cycle is required only if the release-freeze pass changes scientific claims, software behaviour, reference content, or figure generation. Mechanical version and DOI substitutions require exact-head audit confirmation but do not reopen settled design decisions unless they introduce a discrepancy.
