# Dual-agent critical-review ledger

**Manuscript target:** Earth Science Informatics, Software article  
**Working branch:** `codex/earth-science-informatics-refinement-v1.3.0`  
**Coordination rule:** Claude and Codex work through separate commits or branches and document disagreements here. Neither stream silently overwrites the other.

## Review standard

A proposed change is accepted only when it does at least one of the following:

1. closes a stated journal requirement;
2. strengthens a manuscript claim with executable or inspectable evidence;
3. removes an unsupported or ambiguous claim;
4. improves reproducibility, validation, accessibility, or release integrity; or
5. resolves a factual, statistical, licensing, authorship, or disclosure risk.

Stylistic changes that do not improve precision or editorial compliance are secondary. No model-generated statement is treated as evidence. The author remains responsible for all decisions and sign-offs.

## Shared workflow

1. Read the current manuscript, journal-targeting record, code, data, and CI evidence.
2. Enter a finding below with severity, evidence, and proposed resolution.
3. Implement the change in an isolated commit or branch.
4. Run the relevant tests and record the exact result.
5. A second reviewer accepts, amends, or rejects the change with reasons.
6. Merge only after scientific, editorial, and release-version consistency are restored.

## Active findings and decisions

| ID | Severity | Finding | Decision / implementation | Evidence gate | Status |
|---|---|---|---|---|---|
| R1 | Critical | The manuscript previously targeted a journal whose scope did not match the deterministic Earth-data workflow. | Target Earth Science Informatics and frame the contribution as Earth-science informatics, not AI research or a conventional Rwanda GIS application. | Official aims, scope, and software-article instructions documented in `paper/JOURNAL_TARGETING.md`. | Implemented; second-agent challenge invited |
| R2 | Critical | Positive-path fixture tests do not establish fail-closed behaviour under malformed data or schema drift. | Add executable negative tests and a release-contract validator covering feature counts, identifiers, properties, values, provenance, CRS, and geometry identity. | Clean CI must demonstrate both valid-release acceptance and deliberate-corruption rejection. | In progress |
| R3 | Major | Portability beyond Rwanda is described as a design property but is not empirically demonstrated. | Add a geometry-agnostic synthetic fixture using arbitrary administrative identifiers and a non-Rwanda projected geometry; retain cross-country portability as unproven. | Fixture must execute generic transformations without Rwanda names or Rwanda-specific direction gates. | In progress |
| R4 | Major | The archived v1.1.1 DOI does not contain journal-branch additions such as new validators, figures, and timing outputs. | Treat the current branch as an unreleased candidate until all software changes are frozen, then create a new tagged archive and cite its version DOI. Do not invent or pre-claim a DOI. | Manuscript, `DESCRIPTION`, `CITATION.cff`, changelog, checksums, GitHub release, and Zenodo record must agree. | Open release gate |
| R5 | Major | The branch still contains F1000-specific readiness text, title references, and reviewer suggestions. | Replace submission-facing materials with Earth Science Informatics-specific versions; retain declined-submission history only where clearly labelled archival. | Repository-wide search must find no accidental F1000 submission instructions in the active package. | Open |
| R6 | Major | Figure files contain internal titles and map panels rely mainly on colour, creating journal-format and accessibility risks. | Remove embedded figure titles, preserve panel identifiers and units, add redundant visual encoding where feasible, and produce required vector/high-resolution formats. | Visual inspection plus journal figure checklist. | Open |
| R7 | Major | The archived environmental values have no independent second-implementation numerical validation. | Add at least a scoped public-data validation and equal-area sensitivity analysis where reproducible without credentials; explicitly limit conclusions to the validated subset. | Independent calculation, numerical tolerances, and machine-readable results. | Open |
| R8 | Major | The current comparison literature is too weighted toward climate-health applications and may weaken journal fit. | Reduce application-domain background and add primary literature on scientific workflows, metadata/provenance, Earth-data infrastructure, and portable geospatial computation. | Every citation verified against a primary or official source; contribution comparison remains non-promotional. | Open |
| R9 | Major | The integrity manifest covers the archived release but not every new journal-branch file, while prose can be read as covering the whole branch. | Separate archived-release integrity from candidate-package integrity or regenerate a complete manifest after version freeze. | Validator confirms manifest scope and no unlisted submission-critical file. | Open |
| R10 | Editorial | The final Springer Word file has not yet been generated and visually inspected. | Build only after scientific and release gates are closed; inspect every page, table, figure, reference, heading level, metadata field, and accessibility property. | Clean DOCX/PDF rendering and submission checklist. | Open |

## Claude review hand-off

Claude should add a dated entry below or open a separate branch/PR that references the finding IDs above. For every disagreement, state:

- the challenged finding or decision;
- the repository or literature evidence;
- the proposed replacement;
- expected effect on claims, tests, or journal compliance; and
- the validation command or inspection needed.

### Claude entries

- **1 August 2026:** Claude re-appraised its original patch against commit `20bd3b2` and accepted that the earlier full-file replacement was stale. It identified that the original provenance diagram incorrectly conflated three independently callable controls. The revised proposal separates register validation, fail-closed display classification, and illustrative-note selection; retains the district-profile plot as Supplementary Figure S1; corrects verified reference metadata; and preserves the newer validation, checksum-scope, candidate-version, and release-freeze controls. Claude reported that Python manuscript and metadata audits passed on its reconstructed patch but could not run R-dependent tests or canonical figure rendering in its environment.

## Codex review entries

- **31 July 2026:** Established Earth Science Informatics as the primary target, rewrote the manuscript to its Software article structure, added reproducible figures and machine-readable timing, fixed two plotting defects found through CI and visual inspection, and opened draft PR #7.
- **31 July 2026:** Began the second-pass rejection-risk audit. Highest-priority gaps are negative testing, release-contract enforcement, portability evidence, archive-version consistency, submission-material cleanup, figure compliance, and scoped numerical validation.
- **1 August 2026:** Accepted Claude's corrected three-control provenance concept but independently reconstructed it against the exact current branch rather than applying an unavailable or stale full-file snapshot. Added an explicit `short = TRUE` branch to make Figure 3 match `surt_illustrative_note()` more completely. Required GitHub Actions to provide the R parse, canonical SVG/EPS render, reproducibility suite, CHIRPS validation, and exact-head evidence before acceptance.

## Author-only sign-offs

The following cannot be delegated to either model:

- legal name, ORCID, email, and truthful affiliation/location;
- competing-interest and funding disclosures;
- confirmation of institutional non-endorsement;
- referee conflicts;
- approval of the final manuscript and figures;
- creation of the final GitHub/Zenodo release; and
- submission to the journal.
