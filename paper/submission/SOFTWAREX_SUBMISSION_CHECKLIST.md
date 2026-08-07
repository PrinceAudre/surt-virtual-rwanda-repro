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
- [x] Public CHIRPS numerical validation is separately documented and green.
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

The version-specific Zenodo DOI `10.5281/zenodo.21840177` has been reserved in a new-version draft. Complete the remaining release actions in this order:

1. [x] Run the complete account-free reproducibility workflow on the pre-DOI candidate and confirm green.
2. [x] Run the public CHIRPS 2023 validation and confirm green.
3. [x] Reserve the genuine v1.3.0 Zenodo DOI without publishing the draft.
4. [x] Insert DOI `10.5281/zenodo.21840177` into `CITATION.cff`, CodeMeta, README, manuscript, cover letter, and release validation metadata.
5. [ ] Regenerate `CHECKSUMS.sha256` with `--all-tracked --write` after all DOI-bearing edits are frozen.
6. [ ] Run the complete account-free checks again on the exact DOI-bearing commit.
7. [ ] Confirm metadata/manuscript validation and checksum verification are green on that exact commit.
8. [ ] Create immutable tag `v1.3.0` on that exact commit.
9. [ ] Publish the corresponding GitHub release without changing tagged files.
10. [ ] Upload/archive the exact `v1.3.0` release content in the existing Zenodo new-version draft.
11. [ ] Confirm Zenodo title, version, creator, licence, and DOI metadata match the software release, then publish the Zenodo record so DOI `10.5281/zenodo.21840177` is registered.
12. [ ] Confirm the DOI resolves to the published v1.3.0 record.
13. [ ] Regenerate the final manuscript DOCX from the DOI-bearing manuscript source and visually inspect it.
14. [ ] Regenerate the final cover letter, Highlights file, submission ZIP, and package SHA-256 record.
15. [ ] Upload the manuscript as an Original Software Publication.
16. [ ] Upload highlights as a separate editable Highlights file.
17. [ ] Upload the cover letter.
18. [ ] Enter the author affiliation as `Independent Researcher, Kigali, Rwanda`.
19. [ ] Confirm that Elsevier's Rights and Access workflow applies the Rwanda waiver before authorizing any payment.
20. [ ] Verify that no simultaneous journal submission remains active.

Do not publish the Zenodo draft until the DOI-bearing exact release commit has passed all required checks and has been tagged `v1.3.0`.
