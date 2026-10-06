# Array Editorial Manager entry sheet

Use this sheet only to reconcile the transferred Array record with the finalized submission package. The scientific release `v1.4.0` is immutable.

## Submission identity

**Destination journal:** Array

**Transfer provenance:** Previously reviewed at SoftwareX as `SOFTX-D-26-01014`; Elsevier Article Transfer accepted.

**Active title:** SuRT-GeoHarmonizer: A contract-first workflow for verifiable raster-to-administrative data harmonization

**Article type:** Select **Regular Paper** if that option is available. Do not select Technical Note for the current 18-page research manuscript. If Editorial Manager presents a different journal-specific research-article label, stop and reconcile the exact available choices before proceeding.

## Author and correspondence

**Author:** TUYISHIME AUDRE PRINCE

**Affiliation:** School of Public Health, College of Medicine and Health Sciences, University of Rwanda, Kigali, Rwanda

**Corresponding author:** TUYISHIME AUDRE PRINCE

**Email:** priplee@gmail.com

**ORCID:** 0009-0002-0799-3140

**Author count:** 1

## Abstract

Administrative analyses often convert gridded environmental products into polygon-level covariates, but this handoff can obscure whether a reported value represents the whole administrative unit, only the raster-covered portion, or only finite quality-accepted data. We present SuRT-GeoHarmonizer, an open R and Python workflow that treats raster-to-administrative harmonization as a machine-verifiable software contract. It combines surface-area-weighted extraction, separate grid-coverage and finite-data support semantics, fail-closed declarative jobs, an out-of-tree provider boundary, provenance-labelled outputs, independent numerical cross-checks, and release-integrity gates. Controlled fixtures with the same zonal mean showed that decomposing support preserved distinctions lost by a mean or a single overall-validity field. Source-pinned checks agreed closely with independent calculations for Uganda CHIRPS 2023 (difference 0.000016 mm), Nyarugenge ERA5-Land 2023 (approximately 0.000003 °C), MOD13A3 under the declared two-decimal output contract, and Rubavu HAND (less than 1e-9 percentage points). An external provider module loaded without modifying the generic harmonizer or built-in registry, while malformed adapters failed closed. The same core contract was exercised on Rwanda and Uganda geometry and passed core smoke tests on Ubuntu, Windows, and macOS; credentialed acquisition was excluded from that portability claim. On one Windows workstation, the mandatory support contract added median wall-clock costs of 0.03-0.07 s across three benchmark workloads while preserving identical paired means. SuRT-GeoHarmonizer does not introduce a new zonal-statistics algorithm; its contribution is the evaluated integration and assurance contract around a common scientific-data handoff.

## Keywords

1. raster harmonization
2. zonal statistics
3. data provenance
4. geospatial computing
5. reproducible research
6. software verification

## Software, code and availability

**Repository:** https://github.com/PrinceAudre/surt-virtual-rwanda-repro

**Software version:** v1.4.0

**Exact released commit:** `49a87472c3581b6f1912cde97c900ec3dbd17335`

**Zenodo version DOI:** https://doi.org/10.5281/zenodo.23162055

**Zenodo concept DOI:** https://doi.org/10.5281/zenodo.21671788

**Licence:** MIT License for the software. Third-party environmental data retain their original provider terms and citations.

**Availability statement:** The public repository is https://github.com/PrinceAudre/surt-virtual-rwanda-repro. The v1.4.0 release identity uses version DOI https://doi.org/10.5281/zenodo.23162055. Its release contract requires the exact v1.4.0 tagged tree and Zenodo archive to agree with the tracked-file checksum manifest. Source-pinned numerical evidence is retained under the repository evidence directories for CHIRPS, ERA5-Land, MODIS and HAND.

## Declarations

**Competing interests:** The author declares no known competing financial interests or personal relationships that could have appeared to influence this work.

**Funding:** This work received no specific grant from public, commercial or not-for-profit funding agencies.

**Generative AI / AI-assisted technologies:** During preparation of this work, the author used OpenAI ChatGPT and Codex and, during earlier development stages, Anthropic Claude for coding assistance, critical review and language editing. After using these tools, the author reviewed and edited the content as needed, reran the reported checks, verified cited facts and source terms, and takes full responsibility for the software and manuscript. These tools did not generate source environmental data or empirical measurements.

**Simultaneous submission:** The finalized cover letter states that the manuscript is not under simultaneous consideration elsewhere. Confirm this remains true at the moment of final approval.

## Highlights

- Contract-first handoff separates grid support from usable-data support
- Overall valid support is checked as the product of two support factors
- A Uganda climate case reuses the same workflow beyond Rwanda
- Climate and terrain results agree with independent calculations
- External data providers load without changes to the generic workflow

## File mapping

Use the final package generated from post-release package source commit `60f3f5bd9ddcc121b7904a6b59871ebc4a5059f9`.

- **Manuscript:** final Array manuscript DOCX from the validated submission package.
- **Cover letter:** final Array cover-letter DOCX from the validated submission package.
- **Highlights:** final highlights DOCX from the validated submission package.
- **Response to reviewers:** upload only if Array provides an appropriate reviewer-response field or file type. Do not force it into an unrelated category.
- **Do not upload:** historical SoftwareX manuscript files, obsolete manuscript versions, development reviewer-response drafts, or superseded Earth Science Informatics targeting material.

The package artifact checksum is recorded by GitHub Actions. Its internal `SHA256SUMS.txt` must verify before upload.

## Editorial Manager sequence

1. Open **Submissions Sent Back to Author**.
2. Choose **Edit submission**.
3. Replace the transferred SoftwareX title with the active Array title above.
4. Reconcile article type, author details, abstract and six keywords.
5. Inspect the transferred file list and remove superseded SoftwareX files.
6. Upload the final manuscript and cover letter, plus highlights where requested.
7. Add the reviewer response only in an appropriate response field/file type.
8. Verify repository, DOI, data/code availability, funding, competing-interest and AI-use fields against this sheet.
9. Choose **Build PDF for Approval** only after all fields and files are complete.
10. Inspect every page of the Editorial Manager-generated PDF.
11. Accept the Ethics in Publishing Policy checkbox only after the generated PDF is correct.
12. Obtain explicit owner approval before selecting **Approve Submission**.

## Hard stop conditions

Do not approve the submission if any of the following is true:

- the title still shows the old SoftwareX title;
- author name, affiliation, email or ORCID differs from the finalized manuscript;
- an obsolete SoftwareX file remains active in the submission;
- the generated PDF has missing figures, broken equations, truncated tables, altered references or formatting defects;
- the software DOI or repository link differs from the released v1.4.0 identity;
- a newly discovered scientific/software defect would require changing the immutable v1.4.0 release;
- the manuscript is simultaneously under consideration elsewhere;
- the owner has not explicitly approved the final Editorial Manager PDF.
