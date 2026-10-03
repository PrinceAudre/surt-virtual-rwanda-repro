# Claude independent final-review request for SoftwareX v1.4.0

**Date:** 3 October 2026

Repository: `PrinceAudre/surt-virtual-rwanda-repro`

Review branch: `review/softwarex-resubmission-v1.4.0`

Manuscript: SoftwareX `SOFTX-D-26-01014`

## Purpose

Perform an independent final technical and editorial review of the reviewer-remediated v1.4.0 candidate. Do not assume earlier Claude, Codex, or ChatGPT conclusions are correct. Re-read the current branch and test the evidence against the actual code and reviewer concerns.

The published v1.3.0 release is immutable historical evidence. Do not alter it. Do not create a v1.4.0 tag, GitHub release, Zenodo record, or DOI. Those actions require explicit owner authorization after this review and the final release freeze.

## Current evidence that must be independently checked

The current branch claims the following scoped results:

- Uganda CHIRPS 2023: configured `1238.073160 mm`, independent `terra` `1238.073144 mm`, absolute difference `0.000016 mm`, complete reported coverage.
- Nyarugenge ERA5-Land 2023: production `20.597411 °C`, independent `20.597414 °C`.
- Nyarugenge MOD13A3 v061 2023: production output `0.56` NDVI, independent pre-rounding estimate `0.55775352`; all 24 source HDF granules are SHA-256 pinned.
- Rubavu HAND at or below 5 m: production `26.133870170321%`, independent `26.133870170236%`.
- Core smoke CI passes on Ubuntu 24.04, Windows 2025, and macOS 14, while the full geospatial reproducibility workflow remains explicitly Ubuntu-based.

Treat all of these as claims to verify, not facts to repeat automatically.

## Required review scope

Inspect at minimum:

- `README.md`
- `REPRODUCIBILITY.md`
- `CHANGELOG.md`
- `DATA_DICTIONARY.md`
- `NOTICE.md`
- `DESCRIPTION`
- `CITATION.cff`
- `codemeta.json`
- `CHECKSUMS.sha256`
- `R/harmonize_admin_raster.R`
- `R/zonal_area_summary.R`
- `R/relief_temp_transform.R`
- `R/relief_ndvi_transform.R`
- `R/relief_low_lying_transform.R`
- `R/validate_uganda_chirps_case.R`
- `R/validate_era5land_nyarugenge_real.R`
- `R/validate_modis_ndvi_nyarugenge_real.R`
- `R/validate_hand_rubavu_real.R`
- relevant test files in `R/`
- `python/config_contract.py`
- `python/provider_adapters.py`
- `python/run_configured_harmonization.py`
- `python/validate_release_contract.py`
- `python/validate_resubmission_metadata.py`
- `python/audit_manuscript.py`
- `.github/workflows/`
- `docs/CONFIGURATION_AND_ADAPTERS.md`
- `docs/WORKFLOW.md`
- `evidence/`
- `paper/manuscript.md`
- `paper/reviewer-response-draft.md`
- `paper/tool-comparison-evidence.md`
- every active file under `paper/submission/`
- GitHub issue #10 as the implementation ledger

Historical Earth Science Informatics/F1000 files may remain for provenance only when explicitly marked superseded or stored under `paper/archive/`.

## Review questions

### 1. Scientific and spatial correctness

Verify that surface-area-weighted means, raster-footprint coverage, within-raster valid coverage, and overall valid-data coverage are correctly defined and implemented. Check the near-global geographic-footprint normalization and all fail-closed edge cases.

Confirm that HAND uses valid HAND-covered area as the denominator and that no text turns the terrain descriptor into a flood-hazard claim.

Confirm that ERA5-Land uses a calendar-day-weighted mean of 12 monthly means before Kelvin-to-Celsius conversion.

Confirm that MOD13A3 QA filtering uses the intended pixel-reliability policy, scaling, temporal completeness rule, and source granules.

### 2. Independent numerical evidence

Recompute or inspect the cross-check logic closely enough to determine whether the claimed agreement is genuinely independent of the production path. Confirm source identity, rounding semantics, acceptance thresholds, and any shared-code assumptions that could weaken independence.

Flag any evidence file that is stale, internally inconsistent, insufficiently pinned, or broader in wording than the computation supports.

### 3. Generic interface, configuration, and adapters

Pressure-test the public harmonizer and declarative contract for malformed inputs, CRS issues, duplicate/empty identifiers, invalid geometry, no-data handling, masking order, layer selection, rounding, value bounds, reserved names, coverage thresholds, and plugin loading.

Confirm that provider-specific scientific QA remains outside the generic zonal engine and that extension claims do not imply unimplemented provider adapters.

### 4. Reproducibility and operating-system claims

Run the account-free checks if your environment permits. Review the Snakemake DAG and CI configuration. Confirm that the manuscript and documentation distinguish:

- full Ubuntu reproducibility;
- three-platform core smoke evidence;
- geographic/input portability;
- credentialed provider acquisition.

Reject any wording that collapses those four into a single portability claim.

### 5. Reviewer response

Read the actual reviewer-response draft point by point. For every reviewer concern, decide one of:

- `CLOSED WITH SUFFICIENT EVIDENCE`
- `CLOSED BUT WORDING SHOULD BE NARROWER`
- `PARTIALLY CLOSED`
- `OPEN`

Do not mark an item closed merely because the manuscript says it is addressed.

### 6. SoftwareX manuscript and submission package

Audit the manuscript for technical consistency, SoftwareX structure, word count, references, comparison claims, limitations, AI-use disclosure, software/data availability, and code-version metadata.

Audit `paper/submission/` specifically for stale pre-review or v1.3 submission language. The current cover-letter source must explicitly disclose prior external review under `SOFTX-D-26-01014` and must remain fail-closed while v1.4.0 is unreleased.

### 7. Release integrity

Confirm that the development manifest mechanism is sound, but do not treat the current development manifest as the final DOI-bearing release freeze. Identify exactly what must still happen after owner approval:

1. reserve v1.4.0 DOI;
2. insert it into release-facing metadata;
3. freeze the exact tree;
4. rebuild and strictly verify the complete manifest;
5. render and inspect the final package;
6. tag/release/archive the exact approved commit.

## Required execution

Run as much of the following as your environment allows, without weakening gates merely to get green output:

```text
python python/run_all_checks.py
python python/validate_resubmission_metadata.py
python python/audit_manuscript.py
python python/validate_release_contract.py
python python/build_checksum_manifest.py --all-tracked --check
snakemake --cores 1
```

Run relevant direct R tests and validators when source data and dependencies are available. Record exact commands and exit codes. If a provider credential or cached source is unavailable, state that limitation rather than substituting source inspection for execution.

## Deliverable

Create `paper/CLAUDE_V14_FINAL_REVIEW.md` containing:

1. exact reviewed branch and commit;
2. verdict: `GO FOR RELEASE FREEZE`, `GO AFTER CORRECTIONS`, or `HOLD`;
3. reviewer-comment closure table;
4. technical findings by severity;
5. manuscript/submission findings;
6. commands actually run and results;
7. evidence files independently checked;
8. remaining owner-only actions;
9. exact release sequence;
10. explicit confirmation that no tag, release, DOI, empirical value, or CI result was invented.

If corrections are safe and evidence-supported, implement them on a separate review branch and provide small commits. Do not modify the active remediation branch directly and do not publish any release artifact.
