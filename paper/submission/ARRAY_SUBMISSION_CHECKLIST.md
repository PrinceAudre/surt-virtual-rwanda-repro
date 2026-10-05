# Array v1.4.0 submission checklist

## Transfer state

- [x] Destination journal: Array.
- [x] Elsevier Article Transfer from SoftwareX accepted.
- [x] Prior manuscript identifier retained for provenance: `SOFTX-D-26-01014`.
- [x] Prior external peer review on 2 October 2026 is disclosed in the cover letter.
- [x] Array Editorial Manager record has been created and returned to the author for completion.
- [x] No technical comments were included in the transfer email.
- [ ] Update the transferred Editorial Manager title from the earlier SoftwareX title to the active Array title.
- [ ] Verify article type and all transferred metadata against Array's current Editorial Manager fields.
- [ ] Inspect every transferred file and remove superseded SoftwareX-specific files before final submission.
- [ ] Confirm that no simultaneous submission remains active elsewhere.

## Active manuscript identity

- [x] Active manuscript source: `paper/array-manuscript.md`.
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

## Evidence boundary

- [x] Grid-support, finite/QA-support, and overall-support semantics are explicit.
- [x] The overall support field is treated as the product of the two causal factors and is invariant-checked.
- [x] Controlled collision fixtures test whether decomposed support semantics add information beyond a mean or one overall-validity field.
- [x] Independent numerical cross-checks cover CHIRPS, ERA5-Land, MODIS and HAND within declared tolerances.
- [x] Out-of-tree provider loading has positive and malformed-adapter tests.
- [x] Rwanda and Uganda exercise the same generic contract.
- [x] Cross-platform evidence is bounded to the core smoke contract and does not overclaim provider acquisition portability.
- [x] Computational-cost evidence is reported as measured on one documented Windows workstation.

## Release controls

- [x] Final pre-freeze adversarial review is recorded in paper/ARRAY_FINAL_REVIEW_2026-10-05.md; Gates 1 through 11 are closed.

- [x] Published v1.3.0 remains immutable and is not presented as the Array submission release.
- [x] Reserve a new version-specific Zenodo DOI for v1.4.0 without publishing it: `10.5281/zenodo.23162055`.
- [x] Insert the reserved DOI into release-facing metadata, manuscript, cover letter, and checklist.
- [ ] Freeze the exact DOI-bearing source tree.
- [ ] Regenerate the complete tracked-file checksum manifest on that exact tree.
- [ ] Run `python python/run_all_checks.py --verify-manifest` on that exact DOI-bearing commit.
- [ ] Confirm Array manuscript validation, metadata validation, reproducibility checks, and core platform smoke are green on the exact release tree.
- [ ] Render and visually inspect the final manuscript and any response-to-reviewers file.
- [ ] Remove the `DO NOT SUBMIT YET` banner only after all preceding release gates are green.
- [ ] Tag the exact approved commit `v1.4.0`.
- [ ] Create the matching GitHub release without changing tagged files.
- [ ] Archive that exact release content in Zenodo and publish the reserved version DOI.
- [ ] Confirm the version DOI resolves to the exact tagged v1.4.0 release.

## Editorial Manager completion

- [ ] Replace the transferred old title with the active Array title.
- [ ] Confirm author name, affiliation, email and ORCID exactly match the manuscript.
- [ ] Confirm abstract and keywords match the frozen manuscript.
- [x] Highlights source has five general-audience bullets, each no more than 85 characters.
- [ ] Convert final highlights to a separate editable Word file if the Array workflow requests final-file highlights.
- [ ] Upload the final frozen manuscript file generated from `paper/array-manuscript.md`.
- [ ] Upload the final Array cover letter.
- [ ] If Editorial Manager provides a reviewer-response field or file type, upload the finalized response to the prior SoftwareX reviews; otherwise retain it as audit evidence and do not force an unsolicited file type.
- [ ] Verify data/code availability statements and repository links.
- [ ] Verify funding, competing-interest, AI-use, and other declarations against the frozen manuscript.
- [ ] Preview the submission-generated PDF and inspect every page before approval.
- [ ] Final owner approval before pressing the Array submission button.

Do not create or publish the v1.4.0 tag, GitHub release, Zenodo version, or final Array submission without explicit owner authorization.
