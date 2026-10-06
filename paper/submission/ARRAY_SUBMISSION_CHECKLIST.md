# Array v1.4.0 submission checklist

## Transfer state

- [x] Destination journal: Array.
- [x] Elsevier Article Transfer from SoftwareX accepted.
- [x] Prior manuscript identifier retained for provenance: `SOFTX-D-26-01014`.
- [x] Prior external peer review on 2 October 2026 is disclosed in the cover letter.
- [x] Array Editorial Manager record has been created and returned to the author for completion.
- [x] Array email of 5 October 2026 contains no technical comments.
- [x] Editorial Manager instruction identified: `Submissions Sent Back to Author` -> `Edit submission`.
- [x] Transfer expiry recorded: **3 January 2027** if no further action is taken.
- [ ] Update the transferred Editorial Manager title from the earlier SoftwareX title to the active Array title.
- [ ] Verify article type and all transferred metadata against Array's current Editorial Manager fields.
- [ ] Inspect every transferred file and remove superseded SoftwareX-specific files before final submission.
- [ ] Confirm that no simultaneous submission remains active elsewhere at the moment of final submission.

## Active manuscript identity

- [x] Scientific manuscript source is frozen at release tag `v1.4.0`.
- [x] Active title: `SuRT-GeoHarmonizer: A contract-first workflow for verifiable raster-to-administrative data harmonization`.
- [x] Target journal is stated as Array in the manuscript.
- [x] Legal author name: TUYISHIME AUDRE PRINCE.
- [x] Current affiliation: School of Public Health, College of Medicine and Health Sciences, University of Rwanda, Kigali, Rwanda.
- [x] Corresponding email: priplee@gmail.com.
- [x] ORCID: 0009-0002-0799-3140.
- [x] Competing-interest declaration is present.
- [x] Funding declaration is present.
- [x] Generative-AI declaration is present and historically accurate.
- [x] Five research questions are explicit.
- [x] Threats-to-validity section is explicit.
- [x] Manuscript explicitly disclaims novelty in zonal-statistics algorithms.
- [x] Current prior-art treatment includes exactextractr, GDAL 3.12, spatcovar 0.1.0, DART-Pipeline/geoglue, DHIS2 climate tooling, stagg, Climate-CAFE and other adjacent systems.
- [x] Submission-only manuscript copy created as `paper/submission/array-manuscript-final.md`. It is derived from the frozen `v1.4.0` manuscript, preserves the scientific content, updates only completed-release status wording, and limits the keyword list to six terms for current Elsevier submission guidance. The `v1.4.0` tag remains unchanged.

## Evidence boundary

- [x] Grid-support, finite/QA-support, and overall-support semantics are explicit.
- [x] Overall support is the invariant-checked product of the two causal support factors.
- [x] Controlled collision fixtures test information added by decomposed support semantics.
- [x] Independent numerical cross-checks cover CHIRPS, ERA5-Land, MODIS and HAND within declared tolerances.
- [x] Out-of-tree provider loading has positive and malformed-adapter tests.
- [x] Rwanda and Uganda exercise the same generic contract.
- [x] Cross-platform evidence is bounded to the core smoke contract and does not overclaim provider acquisition portability.
- [x] Computational-cost evidence is limited to one documented Windows workstation.

## Release controls

- [x] Final adversarial review recorded in `paper/ARRAY_FINAL_REVIEW_2026-10-05.md`.
- [x] Published v1.3.0 remains immutable.
- [x] Zenodo v1.4.0 version DOI assigned: `10.5281/zenodo.23162055`.
- [x] Release-facing metadata and manuscript identify v1.4.0 and the version DOI.
- [x] Exact DOI-bearing source tree frozen.
- [x] Complete tracked-file checksum manifest regenerated on the release tree.
- [x] Strict `python python/run_all_checks.py --verify-manifest` release validation completed.
- [x] Array manuscript validation, metadata validation, reproducibility checks and core platform smoke were green before release.
- [x] Final manuscript and reviewer-response package underwent documented review before release freeze.
- [x] Exact approved commit tagged `v1.4.0`: `49a87472c3581b6f1912cde97c900ec3dbd17335`.
- [x] Matching GitHub release published without changing tagged files.
- [x] Zenodo version DOI recorded in the GitHub release and `CITATION.cff`.
- [x] GitHub release date: 5 October 2026.

## Submission-facing files

- [x] Post-release Array cover-letter source finalized on `submission/array-final-completion` so it no longer describes already-completed release actions in future tense.
- [x] Final response-to-reviewers source created as `paper/submission/response_to_softwarex_reviewers.md`, with the exact v1.4.0 release identity and no stale pre-release gate language.
- [x] Highlights source contains five general-audience bullets, each no more than 85 characters.
- [x] Confirm the final editable manuscript DOCX/PDF was rendered from the frozen manuscript plus only the approved post-release status wording correction above. Visual QA completed on all 18 pages after the renderer-safe equation fix.
- [x] Confirm the final cover-letter DOCX/PDF was rendered from the post-release final cover-letter source. Both pages visually inspected.
- [x] Confirm the final highlights Word file matches `paper/submission/highlights.txt`. Rendered one-page file visually inspected.
- [x] Confirm the reviewer-response document was rendered from `paper/submission/response_to_softwarex_reviewers.md`. All six pages visually inspected; upload remains conditional on Array providing an appropriate response field/file type.

## Editorial Manager completion

- [ ] Open `Submissions Sent Back to Author` and choose `Edit submission`.
- [ ] Replace the transferred old title with the active Array title.
- [ ] Confirm author name, affiliation, email and ORCID exactly match the manuscript.
- [ ] Confirm the Editorial Manager abstract matches `paper/submission/array-manuscript-final.md` and enter its six submission keywords exactly.
- [ ] Confirm article type against Array's available choices.
- [ ] Remove or replace superseded SoftwareX manuscript files in the transferred file list.
- [ ] Upload the final Array manuscript file.
- [ ] Upload the final Array cover letter.
- [ ] If Editorial Manager provides a reviewer-response field or file type, upload the finalized response to the prior SoftwareX reviews; otherwise retain it as audit evidence and do not force an unsolicited file type.
- [ ] Verify data/code availability statements and repository links.
- [ ] Verify funding, competing-interest, AI-use and other declarations against the frozen manuscript.
- [ ] Choose `Build PDF for Approval` after all mandatory information and files are complete.
- [ ] Inspect every page of the generated submission PDF in `Submissions Waiting Approval by Author`.
- [ ] Accept Elsevier's Ethics in Publishing Policy checkbox only after the final preview is correct.
- [ ] Final owner approval before choosing `Approve Submission`.

## Submission freeze rule

The software release `v1.4.0` is immutable. Editorial-system corrections to title, metadata, cover letter, highlights, reviewer-response packaging, or already-completed release-status wording must not rewrite or retag the software release. Any newly discovered defect in the scientific content or released software must be handled explicitly rather than silently changing the tagged source.
