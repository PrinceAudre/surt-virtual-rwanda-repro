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
| R1 | Critical | The manuscript previously targeted a journal whose scope did not match the deterministic Earth-data workflow. | Target Earth Science Informatics and frame the contribution as Earth-science informatics, not AI research or a conventional Rwanda GIS application. | Official aims, scope, and software-article instructions documented in `paper/JOURNAL_TARGETING.md`; manuscript and metadata audits pass. | Implemented and independently confirmed |
| R2 | Critical | Positive-path fixture tests do not establish fail-closed behaviour under malformed data or schema drift. | Add executable negative tests and a release-contract validator covering feature counts, identifiers, properties, values, provenance, CRS, and geometry identity. | Clean CI demonstrates valid-release acceptance and deliberate-corruption rejection within 41 explicit outcomes. | Implemented and passed |
| R3 | Major | Portability beyond Rwanda is described as a design property but is not empirically demonstrated. | Add a geometry-agnostic synthetic fixture using arbitrary administrative identifiers and non-Rwanda projected geometry; retain cross-country portability as unproven. | Six projected arbitrary-identifier assertions pass; manuscript explicitly limits the claim. | Implemented within stated limitation |
| R4 | Major | The archived v1.1.1 DOI does not contain journal-branch additions such as new validators, figures, and timing outputs. | Treat the current branch as an unreleased candidate until all software changes are frozen, then create a new tagged archive and cite its version DOI. Do not invent or pre-claim a DOI. | Manuscript, `DESCRIPTION`, `CITATION.cff`, changelog, checksums, GitHub release, and Zenodo record must agree. | Open release gate |
| R5 | Major | The branch contained F1000-specific readiness text, title references, and reviewer suggestions. | Replace submission-facing materials with Earth Science Informatics-specific versions; retain declined-submission history only where clearly labelled archival. | Active metadata audit finds no active F1000 submission artifacts; historical records remain under `paper/archive/`. | Implemented |
| R6 | Major | Figure files contained internal titles and comparative figures relied too heavily on colour. | Remove embedded titles, retain captions outside artwork, use vector or 600 dpi outputs, add alternative text, and retain redundant line types, symbols, interval labels, and colour-blind-friendly hues. | Canonical CI artwork inspected at journal scale; Figure 3 has exact zero geometric overlap and Supplementary Figure S1 uses Okabe-Ito colours plus distinct markers and line types. | Implemented, passed, and dual-agent accepted |
| R7 | Major | The archived environmental values had no independent second-implementation numerical validation. | Add scoped public CHIRPS reproduction, extraction-engine comparison, and cell-area weighting sensitivity; explicitly preserve limits for ERA5-Land, MODIS, and HAND. | Public CHIRPS workflow passes and evidence artifact is retained; manuscript does not generalize beyond the tested layer. | Implemented for CHIRPS; other layers remain explicit future work |
| R8 | Major | The comparison literature was too weighted toward climate-health applications and could weaken journal fit. | Reduce application-domain background and add primary literature on scientific workflows, metadata/provenance, Earth-data infrastructure, and portable geospatial computation. | Reference audit and manuscript citation audit pass. | Implemented |
| R9 | Major | The integrity manifest covers an interim stable scope rather than every final candidate file. | Regenerate a complete all-tracked checksum manifest only after the submission source tree is frozen. | Final validator must confirm complete manifest scope and no unlisted submission-critical file. | Open release gate |
| R10 | Editorial | The final Springer Word file has not yet been generated and visually inspected. | Build only after release and DOI gates close; inspect every page, table, figure, reference, heading level, metadata field, and accessibility property. | Clean DOCX/PDF rendering and submission checklist. | Open document gate |

## Claude review hand-off

Claude should add a dated entry below or open a separate branch/PR that references the finding IDs above. For every disagreement, state:

- the challenged finding or decision;
- the repository or literature evidence;
- the proposed replacement;
- expected effect on claims, tests, or journal compliance; and
- the validation command or inspection needed.

### Claude entries

- **1 August 2026:** Claude re-appraised its original patch against commit `20bd3b2` and accepted that the earlier full-file replacement was stale. It identified that the original provenance diagram incorrectly conflated three independently callable controls. The revised proposal separates register validation, fail-closed display classification, and illustrative-note selection; retains the district-profile plot as Supplementary Figure S1; corrects verified reference metadata; and preserves the newer validation, checksum-scope, candidate-version, and release-freeze controls. Claude reported that Python manuscript and metadata audits passed on its reconstructed patch but could not run R-dependent tests or canonical figure rendering in its environment.
- **1 August 2026:** Claude independently reviewed final head `952fda78611358416706202ec15f811072961c4b`. It confirmed that `R/provenance_value_class.R` remained byte-identical to the reviewed base, the last Figure 3 change affected only the `Return empty string` box and arrow coordinates, the polygon intersection with the `short is TRUE?` diamond is exactly zero, and both manuscript and candidate-metadata audits pass. Claude accepted Figure 3 and Supplementary Figure S1 as submission-grade, declared earlier `handoff/` and `handoff2/` patches superseded, and raised no remaining semantic, accessibility, or journal-format objection.

## Codex review entries

- **31 July 2026:** Established Earth Science Informatics as the primary target, rewrote the manuscript to its Software article structure, added reproducible figures and machine-readable timing, fixed two plotting defects found through CI and visual inspection, and opened draft PR #7.
- **31 July 2026:** Began the second-pass rejection-risk audit. Highest-priority gaps were negative testing, release-contract enforcement, portability evidence, archive-version consistency, submission-material cleanup, figure compliance, and scoped numerical validation.
- **1 August 2026:** Accepted Claude's corrected three-control provenance concept but independently reconstructed it against the exact current branch rather than applying an unavailable or stale full-file snapshot. Added an explicit `short = TRUE` branch to make Figure 3 match `surt_illustrative_note()` more completely. Required GitHub Actions to provide the R parse, canonical SVG/EPS render, reproducibility suite, CHIRPS validation, and exact-head evidence before acceptance.
- **1 August 2026:** Integrated the reviewed manuscript through an exact-base guarded workflow. The source manuscript had to match Git blob `54619a4ba4e6e7815909aa4237dc5bab46270913`; the resulting manuscript had to match SHA-256 `300a01ce116e0421553f069527531ec9268afe9023d73b4d01cb7585f2c9e50f`. Both manuscript and metadata preflights passed before commit `5994b9f87839580cf915d8a758d156d1aca4d21c`; temporary integration files removed themselves from the branch.
- **1 August 2026:** The first canonical R render exposed a PostScript-only font compatibility defect after all 41 account-free outcomes had passed. A guarded one-line edit removed the unsupported `family = "mono"` override while preserving every Figure 3 coordinate and label.
- **1 August 2026:** Visual inspection of the first successful canonical bundle found that Supplementary Figure S1's zero reference line extended through the y-axis labels because `xpd = NA` was enabled before plotting. The corrected generator clips the data and zero line with `xpd = FALSE`, then enables `xpd = NA` only for the external legend.
- **1 August 2026:** Added an Okabe-Ito colour-blind-friendly palette to Supplementary Figure S1 while preserving distinct markers and line types, updated alternative text, and retained greyscale interpretability.
- **1 August 2026:** Closed Claude's final geometric transparency note by raising the `Return empty string` box to `y = 5.06-5.60`. Canonical CI rendering and exact geometry verification show zero intersection, no clipped text, and no semantic change. All exact-head workflows passed on `952fda7`; evidence artifact `8819629403` has SHA-256 `36d4cebd4ead726f186a92db727f6d791f9e6186a0c9c612c3c9b5295ca68947`.

## Review closure

The scientific, manuscript, reference, provenance-figure, map, and supplementary-profile review cycle is closed at commit `952fda78611358416706202ec15f811072961c4b`. Earlier Claude patch bundles are superseded and must not be reapplied. Remaining work is limited to the controlled release freeze, immutable version DOI, complete release checksum manifest, final Springer DOCX/PDF construction, and author-only sign-offs.

## Author-only sign-offs

The following cannot be delegated to either model:

- legal name, ORCID, email, and truthful affiliation/location;
- competing-interest and funding disclosures;
- confirmation of institutional non-endorsement;
- referee conflicts;
- approval of the final manuscript and figures;
- creation of the final GitHub/Zenodo release; and
- submission to the journal.
