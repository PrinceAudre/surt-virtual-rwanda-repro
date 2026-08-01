# Security and scope review

This record documents the security, privacy, credential, and publication-scope review for the Earth Science Informatics journal candidate. It supplements automated checks and does not replace the author's final pre-release inspection.

## Version 1.2.0 freeze status

The current branch is the version 1.2.0 pre-DOI release freeze based on published version 1.1.1. Historical F1000Research submission artifacts were removed from the active tree without rewriting Git history. No version DOI, Git tag, GitHub release, Zenodo publication, or journal submission is claimed yet.

## Reviewed and cleared

### Environmental pipeline code

The R builders and transformation functions and the Python provider fetchers contain no embedded credentials, access tokens, private endpoints, or secret values.

- The ERA5-Land fetcher reads the user's own Copernicus Climate Data Store credentials from the provider-standard `.cdsapirc` file.
- The MODIS fetcher uses NASA Earthdata authentication managed through the provider-supported `earthaccess` workflow and local netrc configuration.
- CHIRPS and HAND use public network downloads.
- Credential files, cache directories, generated outputs, R libraries, Python bytecode, and local history files are excluded from version control.

### New verification and validation files

The candidate adds:

- `R/test_portability_fixture.R`;
- `R/test_failure_modes.R`;
- `R/validate_chirps_rainfall.R`;
- `R/make_manuscript_figures.R`;
- `python/validate_release_contract.py`;
- expanded `python/run_all_checks.py`; and
- two GitHub Actions workflows.

These files use public or committed data, synthetic in-memory fixtures, standard GitHub-hosted runners, and repository-relative paths. They contain no credential values. The public CHIRPS validation downloads a public annual GeoTIFF and records only numerical comparison evidence and the source-file digest.

### Environmental data

The committed `data/` directory was reviewed for redistribution terms and sensitive content:

- World Bank administrative boundaries: CC BY 4.0;
- CHIRPS: public domain/CC0;
- ERA5-Land: Copernicus Products licence;
- MODIS: CC0; and
- HAND: CC0.

Full attribution and source-specific terms are recorded in `NOTICE.md`. The WorldPop-derived prototype population attribute was removed in version 1.1.0. The candidate contains no individual-level, household-level, patient, facility, surveillance, or confidential operational records.

### Provenance and evidence-class functions

Only the generic fail-closed functions and a small synthetic example register are included. The private parent application's complete methodology register and operational-adjacent classifications remain excluded.

### Manuscript and submission files

The candidate includes manuscript source, reviewer candidates, journal-targeting analysis, review ledgers, readiness records, figure alternative text, and historical notes. These contain professional contact details and public institutional profile links needed for manuscript preparation, but no private correspondence, personal identification document, signature image, financial account, provider credential, or confidential contract is included.

The historical files removed from the active tree are indexed in `paper/archive/F1000_ARTIFACT_INDEX.md` and remain accessible through Git history. The active submission directory is reserved for Earth Science Informatics materials.

## Deliberately excluded

- The full private SuRT-Virtual Rwanda application and interactive dashboard.
- Synthetic disease and signal datasets, despite being synthetic, because they are operational-adjacent and irrelevant to this Earth-data artifact.
- The private application's full methodology register and decision-support gate.
- Patient, clinical, facility, surveillance, workforce, supply, or resource-allocation data.
- API keys, passwords, session tokens, cookies, `.cdsapirc`, `.netrc`, environment-secret files, and provider download caches.
- Institutional logos, endorsements, signatures, or claims of sponsorship not supported by documented authorization.

## Residual risks and controls

| Risk | Control |
|---|---|
| Provider clients may expose local credential-path errors in logs | Workflows use hosted runners without user secrets; local users should inspect logs before sharing |
| External download URLs or terms may change | Release documentation records source and terms; provider-dependent builds fail visibly rather than embedding fallback data |
| Generated outputs may contain local absolute paths | Generated evidence is inspected before archival; scripts write repository-relative metadata where possible |
| Reviewer contact information may become outdated | Verify each address against an official institutional source immediately before submission |
| The pre-DOI freeze may be mistaken for a published release | `CITATION.cff`, `DESCRIPTION`, README, manuscript, and readiness records state that DOI reservation, exact tagging, and archival publication remain pending |
| Historical submission files may be mistaken for active materials | Removed from the candidate tree and indexed under `paper/archive/` |
| Public environmental layers may be overinterpreted operationally | README, manuscript, data dictionary, notices, and provenance labels state the descriptive and non-operational boundary |
| A listed-file checksum may be mistaken for full scientific validation | Documentation separates byte integrity, software verification, numerical reproduction, and scientific interpretation |

## Final release security gate

Before the candidate is tagged or deposited:

1. scan the complete tracked tree for secrets, private keys, tokens, credential assignments, local usernames, absolute home paths, and sensitive file names;
2. inspect every generated manuscript, figure, archive, and evidence file before upload;
3. confirm that no GitHub Actions artifact required by the paper contains credentials or private logs;
4. regenerate a complete frozen checksum manifest;
5. verify source-data licence and attribution language against current official terms;
6. confirm that author affiliation and competing-interest statements do not imply undocumented sponsorship or endorsement; and
7. run all account-free and public-data validation workflows on the exact release commit.

The candidate remains a reduced, descriptive, non-operational artifact intended to make the environmental-data preparation and provenance discipline independently inspectable.
