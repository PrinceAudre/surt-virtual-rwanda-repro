# Claude Fable 5 handoff: final SoftwareX implementation and rejection-risk review

Use Claude Fable 5 for this task because it requires sustained repository inspection, implementation, validation, and editorial judgment.

## Repository and immutable boundary

Repository: `PrinceAudre/surt-virtual-rwanda-repro`

Review base branch: `codex/softwarex-submission-v1.3.0`

Create and work only on a new branch:

```text
claude/softwarex-fable5-final
```

Do not modify `main`, rewrite Git history, move or recreate tag `v1.2.0`, or alter the published Zenodo version DOI `10.5281/zenodo.21744708`. Version `1.2.0` is immutable historical evidence.

The active product is **SuRT-GeoHarmonizer version 1.3.0**, an R and Python command-line workflow for administrative-scale environmental raster harmonization and provenance labelling. Rwanda is the reference implementation, not the product boundary.

## Current target

Journal: **SoftwareX**, Elsevier

Article type: **Original Software Publication**

The manuscript must use the current official SoftwareX requirements, including the mandatory structure, maximum 3,000 countable words, open-source distribution, code metadata table, support information, and software-reuse framing.

## Your authority

You are authorized to inspect, edit, test, commit, and open a pull request from your branch. Do not merely provide suggestions where a safe, evidence-supported correction can be implemented.

Do not create a Git tag, GitHub release, or Zenodo version. Do not invent or reserve a DOI. Those actions occur only after the author approves the exact validated commit.

## Files that require complete inspection

At minimum inspect:

- `README.md`
- `REPRODUCIBILITY.md`
- `CONTRIBUTING.md`
- `DATA_DICTIONARY.md`
- `NOTICE.md`
- `LICENSE`
- `DESCRIPTION`
- `CITATION.cff`
- `codemeta.json`
- `requirements-providers.txt`
- `R/harmonize_admin_raster.R`
- `R/test_generic_harmonizer.R`
- every provider-specific R builder and transform
- every Python provider client and validator
- `python/run_all_checks.py`
- `python/validate_candidate_metadata.py`
- `python/audit_manuscript.py`
- all GitHub Actions workflows
- `paper/manuscript.md`
- all active `paper/submission/` files
- `CHECKSUMS.sha256`
- `CHANGELOG.md`
- the complete diff from `main` to `codex/softwarex-submission-v1.3.0`

Read the earlier Claude SoftwareX audit supplied to the author only as historical context. Re-evaluate every conclusion independently against the current branch.

## Primary objectives

### 1. Verify that this is a real reusable software product

Determine whether the current branch now presents a coherent research-software product rather than a manuscript companion artifact.

Confirm that:

- `SuRT-GeoHarmonizer` is used consistently as the product identity;
- the public generic interface is understandable and executable;
- the Rwanda implementation is correctly described as a reference deployment;
- a clean reviewer can reproduce the account-free pathway;
- the generic example uses the actual public interface rather than duplicated test-only logic;
- input and output contracts are explicit;
- limitations and unsupported scientific interpretations remain visible;
- the private parent application is neither required nor implied to be included.

### 2. Pressure-test the generic interface

Review `R/harmonize_admin_raster.R` for:

- argument parsing defects;
- scalar and type assumptions;
- CRS handling;
- invalid, empty, mixed, or non-polygon geometry;
- duplicate or missing identifiers;
- multi-layer raster selection;
- no-data masking;
- scale and offset ordering;
- finite-value enforcement;
- exact extraction behaviour;
- output allow-listing;
- GeoJSON writing;
- path handling across operating systems;
- error messages and fail-closed behaviour;
- accidental scientific overclaim.

Add or improve tests where necessary. Every correction must have executable evidence.

### 3. Validate the complete account-free evidence suite

Restore the declared environment and run:

```text
python python/run_all_checks.py
```

Also run the direct component commands documented in `REPRODUCIBILITY.md` where useful.

Do not report a passing result unless it was actually run on the exact reviewed commit. Record:

- operating system;
- R version;
- Python version;
- package restoration result;
- each command;
- each return code;
- total explicit outcome count;
- any warnings or environmental limitations.

If the full environment cannot be restored, state precisely what could and could not be executed. Do not substitute source inspection for execution.

### 4. Audit release and machine-readable metadata

Verify consistency across:

- software name;
- version `1.3.0`;
- author legal name and ORCID;
- independent Rwanda affiliation;
- support email;
- repository URL;
- MIT licence;
- historical `v1.2.0` DOI;
- concept DOI;
- candidate branch;
- release status;
- stated assertion count;
- operating-system claims;
- dependencies;
- final tag and Zenodo gates.

Reject any stale Earth Science Informatics, F1000Research, pre-DOI-freeze, null-DOI, or superseded release language in active product and submission files.

Validate `CITATION.cff` with an official CFF validator and validate `codemeta.json` as JSON and CodeMeta-compatible metadata.

### 5. Audit the SoftwareX manuscript

Use the current official SoftwareX Guide for Authors and Original Software Publication template.

Confirm or correct:

- journal and article type;
- title and software identity;
- truthful author information;
- abstract length;
- four to six keywords;
- required SoftwareX section structure;
- countable word total at or below 3,000;
- maximum figure count;
- code metadata rows;
- software impact and reuse argument;
- relationship to adjacent tools;
- references and DOI accuracy;
- declarations;
- AI-use disclosure;
- software and data availability;
- no unsupported second-country validation claim;
- no hazard, forecast, epidemiological, or operational overclaim;
- no claim that checksums prove scientific validity.

Use primary sources for factual verification. Do not add citations that were not verified.

### 6. Review SoftwareX submission materials

Inspect and improve:

- cover letter;
- highlights;
- submission checklist;
- manuscript source;
- figure captions and accessibility text;
- suggested article classification and keywords.

The cover letter must directly explain why the paper fits SoftwareX after the prior journal rejected it for scope, without disparaging the previous editor or presenting the rejection as evidence of quality.

Highlights must meet Elsevier limits and be technically precise.

### 7. Integrity manifest and final release gate

Ensure `CHECKSUMS.sha256` matches the complete tracked candidate tree after all other edits. Use the repository builder rather than hand-editing hashes:

```text
python python/build_checksum_manifest.py --all-tracked --write
python python/build_checksum_manifest.py --all-tracked --check
```

Rerun all account-free checks after regenerating the manifest.

Do not insert a version-specific v1.3.0 DOI before Zenodo actually issues it. The candidate may identify the concept DOI and the controlled post-validation archive step.

### 8. Security, licence, and redistribution review

Confirm that:

- credentials cannot enter the repository through documented workflows;
- provider clients fail closed without credentials;
- no private or operational source is required;
- every bundled data source can be redistributed in an ElsevierSoftwareX repository copy under its stated terms;
- attribution and the Copernicus notice remain present;
- generated synthetic examples are unambiguously labelled;
- no dependency or copied code creates an undisclosed licence conflict.

## Required implementation discipline

- Preserve honest limitations even when they weaken the sales pitch.
- Do not transform the project into a superficial R package unless a package architecture is genuinely necessary.
- Prefer the existing cross-language command-line architecture when technically sound.
- Do not introduce broad refactoring unrelated to acceptance or reuse.
- Do not alter archived historical records merely to remove old journal names.
- Do not silently change scientific values or thresholds.
- Do not use AI-generated text as evidence.
- Keep commits small, descriptive, and reversible.

## Required output

Create or update:

```text
paper/FABLE5_SOFTWAREX_FINAL_REVIEW.md
```

The report must contain:

1. exact branch and reviewed commit;
2. final verdict: `READY`, `READY AFTER AUTHOR ACTION`, or `NOT READY`;
3. all changes implemented, grouped by commit;
4. complete commands run and results;
5. SoftwareX requirement checklist;
6. repository product-readiness checklist;
7. manuscript word count and figure count;
8. licence and redistribution conclusion;
9. unresolved risks by severity;
10. author-only actions;
11. exact recommended release and submission sequence;
12. explicit confirmation that no DOI, tag, release, or empirical result was invented.

Open a pull request into `codex/softwarex-submission-v1.3.0` with:

- a concise title;
- a structured summary;
- test evidence;
- remaining author-only actions;
- no claim that the work is published or accepted.

Stop only when all safe repository changes are implemented, checks are run to the extent the environment permits, and the report and pull request accurately describe the remaining state.
