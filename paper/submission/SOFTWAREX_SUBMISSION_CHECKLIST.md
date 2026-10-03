# SoftwareX v1.4.0 submission checklist

## Status boundary

- [x] Target journal: SoftwareX.
- [x] Article type: Original Software Publication.
- [x] Prior manuscript identifier: `SOFTX-D-26-01014`.
- [x] External peer review on 2 October 2026 is explicitly disclosed in the cover-letter draft.
- [x] Published v1.3.0 remains immutable.
- [ ] v1.4.0 release identity is intentionally not yet minted.

## Author and manuscript

- [x] Legal author name: TUYISHIME AUDRE PRINCE.
- [x] Affiliation: Independent Researcher, Kigali, Rwanda.
- [x] Corresponding email: priplee@gmail.com.
- [x] ORCID: 0009-0002-0799-3140.
- [x] Competing-interest declaration is present.
- [x] Funding declaration is present.
- [x] Generative-AI declaration is present.
- [x] Manuscript follows the SoftwareX Original Software Publication structure.
- [x] Countable manuscript text remains below 3,000 words.
- [x] Four to six keywords are supplied.
- [x] Two figure captions are supplied.
- [x] Current code-version metadata rows C1 to C9 are present.

## Reviewer-remediation evidence

- [x] Explicit raster-footprint, within-raster valid-data, and overall valid-data coverage semantics.
- [x] Polygon-cell overlap multiplied by raster-cell surface area for zonal weighting.
- [x] Correct HAND valid-area denominator semantics and negative-sentinel handling.
- [x] Calendar-day-weighted ERA5-Land annual temperature statistic.
- [x] MOD13A3 v061 pixel-reliability filtering with production default rank 0.
- [x] Generic fail-closed JSON configuration and provider-adapter contract.
- [x] Snakemake account-free evidence DAG.
- [x] Real Uganda CHIRPS second-country case through the same config-driven workflow.
- [x] Authoritative Uganda CHIRPS result: 1,238.073160 mm configured versus 1,238.073144 mm independent.
- [x] Scoped source-pinned ERA5-Land real-data numerical cross-check.
- [x] Scoped source-pinned MOD13A3 real-data numerical cross-check with all 24 source HDF SHA-256 values.
- [x] Scoped source-pinned HAND real-data numerical cross-check.
- [x] Three-platform core smoke matrix on Ubuntu 24.04, Windows 2025, and macOS 14.
- [x] Full reproducibility CI remains explicitly bounded to Ubuntu.
- [x] Controlled verification, computational cross-validation, observational validity, and byte integrity are kept distinct.

## Reproducibility and release controls

- [x] Account-free test suite is green on the current development checkpoint.
- [x] Metadata/manuscript audit is green on the current development checkpoint.
- [x] Release-contract corruption tests are green.
- [x] Complete tracked-file manifest is refreshed automatically after human source commits.
- [x] Historical non-SoftwareX targeting records are explicitly marked superseded.
- [x] Submission-source regression gate rejects stale pre-review submission claims.
- [ ] Final independent code and manuscript review on the intended release tree.
- [ ] Reserve a new version-specific Zenodo DOI for v1.4.0 without publishing it.
- [ ] Insert the reserved v1.4.0 DOI into release-facing metadata, manuscript, cover letter, and checklist.
- [ ] Freeze the exact DOI-bearing source tree.
- [ ] Regenerate the complete tracked-file checksum manifest on that exact tree.
- [ ] Run `python python/run_all_checks.py --verify-manifest` on that exact DOI-bearing commit.
- [ ] Confirm metadata/manuscript validation and three-platform core smoke remain green on that exact commit.
- [ ] Render and visually inspect the final manuscript and response package.
- [ ] Remove the `DO NOT SUBMIT YET` banner from the cover letter only after every preceding gate is green.
- [ ] Tag the exact approved commit `v1.4.0`.
- [ ] Create the matching GitHub release without altering tagged files.
- [ ] Archive that exact release content in Zenodo and publish the reserved version DOI.
- [ ] Confirm the version DOI resolves to the exact tagged v1.4.0 release.

## Submission package

- [x] Revised manuscript source: `paper/manuscript.md`.
- [x] Point-by-point response source: `paper/reviewer-response-draft.md`.
- [x] Cover-letter source updated for prior SoftwareX external review and v1.4.0 release gating.
- [x] Highlights source updated to the v1.4 evidence.
- [x] Repository documentation and machine-readable metadata are present.
- [ ] Final manuscript DOCX/PDF generated from the frozen DOI-bearing source.
- [ ] Final response-to-reviewers document generated and visually inspected.
- [ ] Final cover letter generated after v1.4.0 DOI insertion.
- [ ] Confirm with the submission system/editor whether the rebuilt work is entered as a formal resubmission or a new submission referencing `SOFTX-D-26-01014`.
- [ ] Verify no simultaneous journal submission remains active.

Do not create or publish the v1.4.0 tag, GitHub release, or Zenodo version without explicit owner authorization.
