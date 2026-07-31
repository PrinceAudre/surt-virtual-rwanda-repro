# F1000Research editorial-readiness record

## Status

**Do not resubmit yet.** Submission 188121 was declined at the pre-publication check on 31 July 2026 with the generic statement that it did not meet journal requirements. No manuscript-specific deficiency was supplied.

A clarification request has been prepared in Gmail. Resubmission should occur only after the editorial office identifies the unmet criterion or confirms that a substantially revised submission may be treated as new.

A review of the current F1000Research eligibility policy identifies author affiliation as the leading unresolved risk. For original research outputs, at least one key author must be formally affiliated with an accredited institution or recognised organisation, and the affiliation may be verified. The manuscript's current `Independent researcher, Kigali, Rwanda` line should therefore be treated as provisional rather than submission-ready.

Any replacement affiliation must be truthful, current, verifiable, and appropriate to the circumstances in which the work was conducted. A clinical employer, contractual research organisation, private company, university, or other organisation must not be listed merely to clear an eligibility check, and an affiliation must not imply sponsorship or endorsement that did not occur.

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
| Author eligibility and affiliation | Current independent-researcher wording appears insufficient under the published policy | Unresolved, editorial confirmation required |
| Referee eligibility and conflicts | Five-candidate file | Personal conflict check required |
| Editorial reason for rejection | Clarification draft to editorial office | Awaiting response |

## Required author sign-offs before resubmission

1. Obtain F1000Research's confirmation of the failed criterion and its acceptable affiliation treatment.
2. Identify a truthful, current, and verifiable formal affiliation only where it accurately represents the circumstances of the work.
3. Confirm the competing-interest statement about contractual CHAI research coordination.
4. Confirm that no listed organisation sponsored or endorsed the software article unless that is documented.
5. Recheck all five suggested referees for personal or professional conflicts.
6. Review the final DOCX and approve the exact title, author name, affiliation, ORCID, and corresponding email.

## Release discipline

The current archived software remains version 1.1.1 with DOI `10.5281/zenodo.21677162`. This branch revises the publication package but does not create a new Zenodo version. If code or archived documentation changes are required after editorial clarification, create a new tagged release and use its version DOI in the resubmitted manuscript.
