# F1000Research editorial-readiness record

## Status

**Do not resubmit yet.** Submission 188121 was declined at the pre-publication check on 31 July 2026 with the generic statement that it did not meet journal requirements. No manuscript-specific deficiency was supplied.

A clarification request has been prepared in Gmail. Resubmission should occur only after the editorial office identifies the unmet criterion or confirms that a substantially revised submission may be treated as new.

## Changes completed in this hardening branch

- Repositioned the article from a generic "proof of concept" to a specific Software Tool Article.
- Defined one integrated contribution: cross-provider environmental preparation, district aggregation, fail-closed provenance labelling, account-free verification, and archived release integrity.
- Added direct comparison with Google Earth Engine, MODIStsp, and `exactextractr`.
- Added suitable inputs, commands, output schema, interpretation limits, and two concrete use cases.
- Distinguished software verification from scientific and operational validation.
- Corrected the repository summary from 17 to 18 software assertions.
- Removed unverified institutional affiliation from machine-readable citation metadata.
- Added a precise contractual-interest disclosure and independent-capacity statement.
- Synchronized the revised title in the README and referee file.
- Preserved the published Zenodo v1.1.1 DOI and did not mint or claim a new release.

## F1000Research pre-publication checks addressed

| Check | Evidence in package | Status |
|---|---|---|
| Software Tool Article scope and rationale | Introduction, comparison table, use cases | Addressed |
| Assessable methods and operation | Commands, input/output contract, environment, fixture | Addressed |
| Open source and archived version | GitHub repository, MIT code licence, Zenodo DOI | Addressed |
| Underlying outputs and metadata | GeoJSON files, data dictionary, notice, checksums | Addressed |
| Clear claims and limitations | Claim-to-evidence table, verification/validation boundary | Addressed |
| Ethics and consent | Dedicated statement | Addressed |
| Competing interests | Dedicated statement | Addressed, author verification required |
| Affiliation | Independent-researcher wording in manuscript; no affiliation in CFF | Author verification required |
| Referee eligibility and conflicts | Five-candidate file | Personal conflict check required |
| Editorial reason for rejection | Clarification draft to editorial office | Awaiting response |

## Required author sign-offs before resubmission

1. Confirm that **Independent researcher, Kigali, Rwanda** is the correct article affiliation.
2. Confirm the competing-interest statement about contractual CHAI research coordination.
3. Confirm that CHAI did not sponsor or endorse this software article.
4. Recheck all five suggested referees for personal or professional conflicts.
5. Review the final DOCX and approve the exact title, author name, ORCID, and corresponding email.
6. Obtain a specific response from F1000Research about the failed requirement.

## Release discipline

The current archived software remains version 1.1.1 with DOI `10.5281/zenodo.21677162`. This branch revises the publication package but does not create a new Zenodo version. If code or archived documentation changes are required after editorial clarification, create a new tagged release and use its version DOI in the resubmitted manuscript.
