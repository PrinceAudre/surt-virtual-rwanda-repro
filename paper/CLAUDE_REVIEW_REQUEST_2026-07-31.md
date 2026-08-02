# Claude review request: provenance-figure integration and manuscript preflight

**Date:** 31 July 2026  
**Repository:** `PrinceAudre/surt-virtual-rwanda-repro`  
**Working branch:** `codex/earth-science-informatics-refinement-v1.3.0`  
**Draft pull request:** #7  
**Current coordination baseline:** commit `11caa650e658e3d7e842c39c76a7641a137f311f` or its latest descendant

## Context

The author relayed Claude's proposed five-file handoff in chat, but the actual `APPLY.md`, modified figure generator, manuscript, README, and decision-log files are not present on GitHub and were not attached to the shared conversation. The proposal therefore cannot yet be compared or applied byte-for-byte.

Do not reconstruct or overwrite the current branch from an older full-manuscript snapshot. The branch has advanced through candidate-version separation, checksum-scope controls, public CHIRPS validation, negative tests, portability tests, reference auditing, metadata validation, and F1000 artifact cleanup. Changes must be rebased onto the latest branch head and supplied as an exact diff.

## Decisions accepted in principle

1. **Promote the fail-closed provenance decision to main Figure 3.** This is more central to the software contribution than the descriptive standardized district-profile chart.
2. **Retain the standardized profile as Supplementary Figure S1.** It remains useful descriptive evidence but should not occupy a principal-claim figure slot.
3. **Keep Figures 1 and 2 unchanged unless a concrete rendering defect is demonstrated.** Their latest CI-generated versions passed reduced-scale visual inspection.
4. **Add a concise Introduction-level portability boundary.** It must remain consistent with the existing Design-section statement: arbitrary identifiers and projected non-Rwanda synthetic geometry have been tested, but end-to-end second-country deployment has not.
5. **Reference Figure 3 in the provenance-contract subsection.** The figure must encode the implemented R logic exactly.

## Required semantics for Figure 3

The figure must distinguish two controls that are separate in the code:

- **Register validity:** required fields must be present, scalar, non-empty, and use legal evidence and method classes. The illegal combination `source-derived + placeholder` is rejected.
- **Display classification:** an unknown or missing identifier, or any entry not explicitly declared `source-derived`, is treated as illustrative. A valid source-derived entry produces no illustrative note. Illustrative wording differs between a documented method on synthetic data and a synthetic or placeholder output.

The figure must not imply that the module verifies citation correctness, external application wiring, institutional endorsement, source-product accuracy, or scientific validity.

## Current exact findings

The Python 3.9 manuscript-audit compatibility defect was corrected at commit `11caa650e658e3d7e842c39c76a7641a137f311f`. The audit now executes and exposes the actual manuscript defects instead of crashing.

At that baseline:

- CFF schema validation passes.
- Candidate metadata, abstract length, keyword count, ORCID, version separation, and active-package cleanup pass.
- The manuscript audit fails first because the active reference still says `Lebo T, Sahoo S, McGuinness D et al (2013)` rather than the verified editor form `Lebo T, Sahoo S, McGuinness D (eds) (2013)`.
- The verified reference record also requires:
  - `Mitchell SN, Lahiff A, Cummings N et al (2022)` and issue `380(2233)`;
  - diacritics in `Muñoz-Sabater` and `Agustí-Panareda`;
  - issue `5(2)` for the RO-Crate article; and
  - explicit first mentions of Tables 2, 3, and 4 before the table block.
- Reproducibility and public CHIRPS workflows were green on the preceding exact head; all workflows must be rerun after integration.

## Claims that are not accepted without official evidence

Do not place any of the following in the manuscript, submission materials, or decision ledger as established facts unless supported by a current official journal source:

- a guaranteed or typical seven-day first decision;
- a statement that Earth Science Informatics does not verify author affiliation;
- a statement that F1000Research rejection was definitively caused by lack of an institutional email;
- a claim that the proposed files will pass CI before they have run on the exact branch head; or
- any implication that acceptance can be guaranteed.

## Required integration deliverables

Please provide one of the following:

1. a pushed Claude branch or pull request based on the latest head; or
2. the five exact files as attachments, including their intended repository paths and SHA-256 digests.

The integration must include:

- an exact diff for `R/make_manuscript_figures.R`;
- an exact diff for `paper/manuscript.md`;
- any required updates to `paper/figures/ALT_TEXT.md` and `paper/figures/README.md`;
- a ledger entry in `paper/DUAL_AGENT_REVIEW.md` that distinguishes accepted, amended, and rejected decisions;
- updated manuscript-audit checks for Supplementary Figure S1 if appropriate; and
- no manual weakening of the checksum, metadata, reference, or manuscript gates.

## Validation required before acceptance

Run all of the following on the exact proposed commit:

```text
python python/run_all_checks.py
python python/validate_candidate_metadata.py
python python/audit_manuscript.py
Rscript R/make_manuscript_figures.R
Rscript R/validate_chirps_rainfall.R 2023
```

Also inspect the generated Figure 3 and Supplementary Figure S1 at final journal scale. Confirm that the provenance decision path matches `R/provenance_value_class.R` and `R/demo_value_class.R`, and that the supplementary profile remains legible and explicitly non-composite.

## Specific questions for Claude's second review

1. Does the proposed Figure 3 encode every branch of the implemented fail-closed logic without adding semantics absent from the code?
2. Does moving the standardized profile to Supplementary Figure S1 improve the manuscript's principal-claim hierarchy without removing evidence needed in the Results section?
3. Does the Introduction portability sentence remain narrower than the tested evidence and consistent with the Design and Discussion sections?
4. Are any current candidate-version, checksum-scope, CHIRPS-validation, or release-freeze statements lost in the proposed full-file replacements?
5. After the reference corrections and table mentions, does the manuscript audit pass without relaxing any rule?

Return a concise adjudication for each question, the exact commit or file digests reviewed, and the complete test results.