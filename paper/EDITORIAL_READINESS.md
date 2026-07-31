# Earth Science Informatics submission-readiness record

## Status

**Not ready for submission.** The manuscript has been reframed as a Software article for *Earth Science Informatics* and the core account-free workflow is under expanded verification. Submission remains blocked until the scientific validation, candidate-release, figure, Word-document, and author sign-off gates below are closed.

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

## Non-negotiable scientific gates

| Gate | Required evidence | Current status |
|---|---|---|
| Contribution is an Earth-science informatics artifact rather than a conventional regional GIS application | Introduction, comparison table, architecture figure, explicit non-claims | Addressed; final second-agent review pending |
| Core transformation functions behave as specified | Nine-assertion environmental fixture | Passed in clean CI |
| Provenance classification fails closed | Nine-assertion provenance demonstration | Passed in clean CI |
| Generic transformations are not hard-coded to Rwanda names or coordinates | Six-assertion projected, arbitrary-identifier portability fixture | Passed in clean CI; real cross-country portability remains unproven |
| Malformed inputs and unsafe states are rejected | Seven transformation failure-injection assertions | Passed in clean CI |
| Archived GeoJSON files satisfy a common release contract | Five layer-contract checks covering schema, identifiers, values, provenance, CRS, order, and exact geometry identity | Passed in clean CI |
| Deliberate release corruption is rejected | Duplicate identifier, missing provenance, impossible value, geometry substitution, and undeclared-field tests | Passed in clean CI |
| At least one public source-derived layer receives independent numerical scrutiny | CHIRPS reproduction, `terra` versus `exactextractr`, and cell-area sensitivity workflow | Running; manuscript claims remain blocked until evidence artifact is inspected |
| Every principal manuscript claim maps to inspectable evidence or an explicit limitation | Claim-to-evidence table and dual-agent ledger | Partially addressed; revise after numerical validation |
| Verification is not misrepresented as scientific, hazard, epidemiological, or operational validation | Methods, Discussion, limitations table, conclusion | Addressed; final language audit pending |

## Journal-structure gates

The active manuscript must retain the journal's Software article structure:

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

The abstract must remain between 150 and 250 words, and the manuscript must use four to six keywords. References must use a consistent author-year style. All software, data, and repository identifiers must resolve to the exact candidate version submitted.

## Figure gates

Before final Word generation:

1. Remove titles and captions embedded inside figure files; captions remain in manuscript text.
2. Supply vector line art as EPS or another accepted editable vector format and combination art at 600 dpi TIFF.
3. Ensure panel lettering, legends, symbols, and units remain legible at final print size.
4. Do not rely on colour alone. Use line type, symbols, interval boundaries, or other redundant encodings where the figure communicates comparative information.
5. Provide concise alternative text in the Word file for every figure.
6. Inspect the architecture diagram, four-panel map, and standardized profile at 100% and reduced journal-column scale.
7. Verify that every plotted value is generated from archived or candidate data by code in the repository.

## Candidate-release gates

The published v1.1.1 archive, DOI `10.5281/zenodo.21677162`, predates the journal-candidate validators, figures, timing metadata, and public-data validation. It cannot be presented as containing those additions.

Before submission:

1. Freeze the candidate source tree and decide the new semantic version.
2. Update `DESCRIPTION`, `CITATION.cff`, `CHANGELOG.md`, README, manuscript, and file names to the same version.
3. Generate a complete candidate checksum manifest rather than relying on a partial historical scope.
4. Run all account-free verification and public-data validation workflows on the exact release commit.
5. Tag the exact release commit on GitHub.
6. Create the corresponding Zenodo version and insert its exact version DOI into the manuscript and citation metadata.
7. Confirm that the DOI archive contains every file cited as software or evidence in the manuscript.
8. Re-run link, checksum, and metadata consistency audits after DOI insertion.

No placeholder DOI or anticipated version number may appear in the submission.

## Submission-package cleanup

- Preserve declined F1000 material only under `paper/archive/` or with an explicit archival label.
- Replace the active referee dossier with an Earth Science Informatics-specific conflict-screening record.
- Ensure the active `paper/submission/` directory contains only the final Earth Science Informatics manuscript and required supplementary files.
- Remove stale old titles, assertion counts, journal names, and submission instructions from active documents.
- Confirm that no private parent-application code, disease data, credentials, or operational materials are included.

## Word-document and accessibility gates

The final Word file is built only after the scientific and release gates close. It must then pass all of the following:

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
- final spell check and terminology consistency audit.

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
11. Approval of the exact final manuscript, figures, supplementary files, release tag, and Zenodo record.

## Dual-agent review rule

Claude and Codex reviews are coordinated through `paper/DUAL_AGENT_REVIEW.md`, separate commits, or separate pull requests. A change is accepted only when it closes a documented journal requirement, strengthens evidence, removes an unsupported claim, improves reproducibility or accessibility, or resolves a factual, licensing, authorship, disclosure, or release risk. No model-generated statement is treated as evidence.
