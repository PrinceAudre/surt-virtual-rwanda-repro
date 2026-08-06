# Contributing to SuRT-GeoHarmonizer

Contributions are welcome when they improve reproducibility, provider support, input validation, portability, documentation, accessibility, or scientific claim boundaries.

## Before opening a change

Use a GitHub issue to describe:

- the research or software problem;
- the smallest reproducible example;
- the relevant operating system, R version, and Python version;
- whether provider credentials or network access are required;
- the expected and observed behaviour;
- any licensing or redistribution implications.

Do not include passwords, access tokens, private data, patient data, confidential surveillance data, or proprietary provider files.

## Development principles

A change should do at least one of the following:

1. add or improve a documented user pathway;
2. make a transformation or contract independently testable;
3. close a fail-open behaviour;
4. improve portability without overstating validation;
5. improve data terms, attribution, or provenance;
6. remove an unsupported scientific or operational claim;
7. improve accessibility, security, or release integrity.

Stylistic changes that do not improve precision or usability are secondary.

## Branch and pull-request workflow

1. Create a focused branch from the current development branch.
2. Keep provider acquisition, transformation, evidence classification, and scientific interpretation as separate concerns.
3. Add an account-free fixture for new transformation logic whenever feasible.
4. Add a deliberate failure test for new validation rules.
5. Update `README.md`, `REPRODUCIBILITY.md`, `DATA_DICTIONARY.md`, `NOTICE.md`, or machine-readable metadata when behaviour or terms change.
6. Run the complete account-free suite:

```text
python python/run_all_checks.py
```

7. Do not regenerate `CHECKSUMS.sha256` until the candidate tree is otherwise frozen.
8. Describe residual limitations in the pull request.

## Generic-interface contributions

Changes to `R/harmonize_admin_raster.R` must preserve these guarantees:

- non-empty unique administrative identifiers;
- valid polygon geometry with a declared CRS;
- a raster with a declared CRS;
- finite extracted values for every feature;
- WGS84 GeoJSON output;
- allow-listed properties only;
- a non-empty provenance statement;
- fail-closed optional output bounds.

The generic interface validates computational behaviour. A contributor remains responsible for the scientific appropriateness of the selected source, period, variable, units, scaling, thresholds, and interpretation.

## Provider-specific contributions

A new provider module should document:

- official product name and version;
- access method and account requirements;
- source licence or terms;
- no-data conventions;
- scale and offset rules;
- temporal aggregation;
- coordinate reference system handling;
- expected output units;
- bounded-value checks;
- known limitations;
- a provider-free fixture that exercises the transformation path.

Provider credentials must remain outside the repository.

## Testing and evidence

The main suite distinguishes:

- controlled transformation behaviour;
- generic interface behaviour;
- failure rejection;
- release-schema enforcement;
- numerical reproduction of a public source;
- byte-level integrity.

Passing one category must not be presented as proof of another. For example, a checksum does not establish scientific validity, and a synthetic fixture does not validate a provider product.

## Versioning and archives

The Git tag, `CITATION.cff`, `codemeta.json`, `DESCRIPTION`, README, manuscript, checksum manifest, and Zenodo version archive must identify the same release. Published tags and Zenodo versions are immutable.

## AI-assisted contributions

AI tools may be used for coding, review, or language support. The contributor must inspect the proposed changes, verify all cited facts and licences, run the relevant tests, and remain accountable for the contribution. AI output is not evidence.

## Code of conduct

Be specific, professional, and evidence-based. Critique code and claims rather than contributors. Do not use issues or pull requests to expose private information or credentials.

## Support and security

Use GitHub Issues for ordinary reproducible defects and feature requests. Follow `SECURITY_REVIEW.md` for security-sensitive concerns.
