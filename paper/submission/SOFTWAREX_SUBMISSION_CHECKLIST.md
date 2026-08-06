# SoftwareX submission checklist

## Journal and article

- [x] Target journal: SoftwareX.
- [x] Article type: Original Software Publication.
- [x] Software product identity: SuRT-GeoHarmonizer.
- [x] Manuscript follows the SoftwareX software-publication structure.
- [x] Countable manuscript text remains below 3,000 words.
- [x] Two figures are embedded with captions.
- [x] Current code version table contains rows C1 to C9.
- [x] Four to six keywords are supplied.
- [x] Five highlights are supplied, each no more than 85 characters.

## Author information

- [x] Legal author name: TUYISHIME AUDRE PRINCE.
- [x] Affiliation: Independent Researcher, Kigali, Rwanda.
- [x] Corresponding email: priplee@gmail.com.
- [x] ORCID: 0009-0002-0799-3140.
- [x] Sole-author responsibility and contribution are clear.
- [x] Competing-interest declaration is present.
- [x] Funding declaration is present.
- [x] Generative-AI use declaration is present.

## Software product

- [x] Public GitHub repository.
- [x] MIT code licence.
- [x] Generic raster and polygon command-line interface.
- [x] Account-free arbitrary-geometry example.
- [x] Installation and quick-start instructions.
- [x] Input and output contracts.
- [x] CodeMeta and Citation File Format metadata.
- [x] Contribution policy.
- [x] Locked R dependency graph.
- [x] Optional Python provider clients are pinned.
- [x] GitHub Issues support pathway and support email.
- [x] Provider credentials remain outside the repository.

## Evidence and claims

- [x] Account-free suite reports 48 explicit behavioural and contract outcomes.
- [x] Positive transformations are separated from deliberate failure tests.
- [x] GeoJSON validation uses an independent Python implementation.
- [x] Public CHIRPS numerical validation is separately documented.
- [x] Only CHIRPS is claimed to have equivalent independent numerical validation.
- [x] Generic synthetic example is not presented as second-country scientific validation.
- [x] HAND is described as a terrain descriptor, not a flood hazard.
- [x] No forecast, epidemiological, exposure, causal, or operational claim is made.
- [x] Checksums are described as integrity evidence, not scientific validation.

## Licences and redistribution

- [x] District geometry attribution and CC BY 4.0 terms are recorded.
- [x] CHIRPS public-domain or CC0 terms are recorded.
- [x] ERA5-Land Copernicus Products licence and attribution are recorded.
- [x] MODIS and HAND source terms are recorded.
- [x] No ODbL share-alike data remain in the distributed product.
- [x] Synthetic examples are labelled as synthetic.
- [x] Private application, patient, surveillance, and operational data are excluded.

## Files prepared

- [x] SoftwareX manuscript source.
- [x] Manuscript DOCX with figures embedded.
- [x] Cover letter.
- [x] Highlights file.
- [x] Repository documentation and machine-readable metadata.
- [x] Claude Fable 5 final-review prompt.

## Final exact-release actions

Complete these in order after the final Claude and Codex review changes are merged:

1. [ ] Run `python python/run_all_checks.py` on the exact final commit.
2. [ ] Run the public CHIRPS validation or confirm the most recent exact-code result remains applicable.
3. [ ] Regenerate `CHECKSUMS.sha256` with `--all-tracked --write`.
4. [ ] Rerun all account-free checks and manifest verification.
5. [ ] Confirm all GitHub Actions are green on the exact commit.
6. [ ] Create immutable tag `v1.3.0` on that exact commit.
7. [ ] Publish the corresponding GitHub release.
8. [ ] Archive tag `v1.3.0` as a new Zenodo version.
9. [ ] Insert the genuine new version DOI into `CITATION.cff`, CodeMeta if used, README, manuscript, cover letter, and release validator.
10. [ ] Regenerate the checksum manifest after DOI insertion and rerun exact-head validation.
11. [ ] Upload the manuscript as an Original Software Publication.
12. [ ] Upload highlights as a separate editable Highlights file.
13. [ ] Upload the cover letter.
14. [ ] Enter the author affiliation as `Independent Researcher, Kigali, Rwanda`.
15. [ ] Confirm that Elsevier's Rights and Access workflow applies the Rwanda waiver before authorizing any payment.
16. [ ] Verify that no simultaneous journal submission remains active.

Do not create or cite a version-specific DOI until Zenodo has actually issued it for the exact final tag.
