# Contributing to SuRT-GeoHarmonizer

Thank you for your interest in contributing. SuRT-GeoHarmonizer is a reusable R and Python command-line workflow for reproducible, provenance-labelled administrative-scale Earth-data harmonization. Rwanda's 30 districts are the reference deployment; the generic harmonization and provenance interfaces are not restricted to Rwanda. Contributions that improve reuse, portability, validation, documentation, accessibility, security, or test coverage are welcome.

## Scope and non-goals

- Outputs are **descriptive environmental layers only**. Contributions must not add or imply validated hazard, flood, forecast, epidemiological, exposure, causal, or operational decision-support claims.
- No patient, surveillance, confidential operational, proprietary, or credential-bearing data may be added.
- New bundled data must have redistribution terms compatible with the repository and an ElsevierSoftwareX repository copy, such as CC0, public domain, or CC BY 4.0. Do not introduce share-alike data such as ODbL without an explicit maintainer decision and a documented compatibility review. A prior ODbL dependency was deliberately removed.
- A checksum proves byte integrity, not scientific validity. A synthetic fixture proves controlled software behaviour, not provider accuracy or geographic validation.
- The private SuRT-Virtual Rwanda application, its private methodology register, and operational interfaces are outside this repository.

## Before opening a change

Use a GitHub issue to describe:

- the research or software problem;
- the smallest reproducible example;
- the relevant operating system, R version, and Python version;
- whether provider credentials or network access are required;
- the expected and observed behaviour;
- any licensing, attribution, or redistribution implications.

Do not include passwords, access tokens, private data, patient data, confidential surveillance data, or proprietary provider files.

## Getting set up

1. Use Python 3.10 or later.
2. Restore the pinned R environment:

```text
Rscript -e "renv::restore(prompt = FALSE)"
```

3. The account-free verification runner uses the Python standard library. Optional provider clients are pinned separately:

```text
python -m pip install -r requirements-providers.txt
```

Provider clients are not required for the account-free test pathway.

## Required checks before a pull request

Run the complete account-free suite:

```text
python python/run_all_checks.py
```

This suite requires no private repository, provider account, unpublished data, or network request. It exercises provenance rules, controlled environmental transformations, projected arbitrary geometry, the generic administrative interface, deliberate transformation failures, release-contract validation, corruption rejection, manuscript and metadata checks, and checksum integrity.

When a change affects the CHIRPS builder, extraction behaviour, public-data validation, or reported rainfall evidence, also run:

```text
Rscript R/validate_chirps_rainfall.R 2023
```

The CHIRPS numerical validation requires network access but no provider account.

`run_all_checks.py` must exit successfully, and its machine-readable summary must reflect the repository's actual version, branch, release status, DOI state, and assertion count. Do not weaken an audit or hard-code a passing result to make a change appear valid.

## Development principles

A change should do at least one of the following:

1. add or improve a documented user pathway;
2. make a transformation or contract independently testable;
3. close a fail-open behaviour;
4. improve portability without overstating validation;
5. improve data terms, attribution, or provenance;
6. remove an unsupported scientific or operational claim;
7. improve accessibility, security, or release integrity.

Keep provider acquisition, transformation, administrative harmonization, evidence classification, scientific interpretation, and release validation as separate concerns. Stylistic changes that do not improve precision or usability are secondary.

## Branch and pull-request workflow

1. Create a focused branch from the current development branch.
2. Keep commits small, descriptive, and reversible.
3. Add an account-free positive fixture for new transformation logic whenever feasible.
4. Add a deliberate failure test when validation, provenance, schema, or claim boundaries change.
5. Update `README.md`, `REPRODUCIBILITY.md`, `DATA_DICTIONARY.md`, `NOTICE.md`, `CITATION.cff`, `codemeta.json`, or the manuscript when behaviour, metadata, terms, or claims change.
6. Run the required checks on the exact candidate commit.
7. Do not regenerate `CHECKSUMS.sha256` until the candidate tree is otherwise frozen.
8. Describe residual limitations and any unexecuted checks in the pull request.

## Generic-interface contributions

Changes to `R/harmonize_admin_raster.R` must preserve these guarantees:

- non-empty, unique administrative identifiers from a non-geometry attribute;
- rejection of reserved output-name collisions;
- valid polygon or multipolygon geometry with a declared coordinate reference system;
- a raster with a declared coordinate reference system;
- explicit layer selection for multi-layer rasters;
- finite extracted values for every feature;
- WGS84 GeoJSON output;
- allow-listed output properties only;
- a non-empty provenance statement;
- fail-closed optional bounds, masking, scaling, and offset handling.

The generic interface validates computational behaviour. A contributor remains responsible for the scientific appropriateness of the selected source, period, variable, units, scale factor, thresholds, aggregation, and interpretation.

Do not hard-code Rwanda-specific district names, identifiers, extents, coordinate systems, feature counts, or provider assumptions into the generic interface.

## Adding an environmental layer or provider

A new provider-specific module should document:

- official product name and version;
- access method and account requirements;
- source licence or terms;
- no-data conventions;
- scale and offset rules;
- temporal support and aggregation;
- coordinate reference system handling;
- expected output units;
- bounded-value and completeness checks;
- known limitations;
- a provider-free fixture that exercises the transformation path.

If the contribution uses the public evidence-classification mechanism, use only the supported values:

- `evidence_class`: `source-derived` or `illustrative`;
- `method_class`: `documented` or `placeholder`.

The provenance rule is fail closed: unknown, incomplete, synthetic, or placeholder material remains illustrative unless a known identifier explicitly records a documented method applied to real or public data. Do not expose or reconstruct the private parent application's methodology register. `R/example_register.R` is an illustrative schema example only.

For each new layer:

1. add or update the transformation or builder under `R/`;
2. document the source, temporal basis, units, terms, and claim boundary;
3. update `DATA_DICTIONARY.md` and `NOTICE.md`;
4. add a positive transformation fixture;
5. add at least one relevant failure-injection case;
6. add an independent public numerical cross-check where a suitable source and method exist.

Provider credentials must remain outside the repository.

## Testing and evidence

A contribution is not complete until new behaviour is supported by executable evidence. The test system distinguishes:

- controlled transformation behaviour;
- generic-interface behaviour;
- failure rejection;
- release-schema enforcement;
- numerical reproduction of a public source;
- byte-level integrity.

Do not silently reconcile inconsistent inputs and archived outputs. Report the discrepancy, determine its cause, and preserve the evidence required to reproduce the decision.

Any figure included in documentation or the manuscript must be reproducible from code and data in the repository, with accessibility text and claim boundaries appropriate to the underlying evidence.

## Coding conventions

- Use R and Python command-line scripts; no artificial packaging or build step is required.
- Keep functions pure where practical and make file writes and network access explicit.
- Use repository-relative paths rather than assumptions about the caller's working directory.
- Fail closed on invalid, incomplete, contradictory, or unsupported inputs.
- Match the existing style in the file being edited.
- Keep credentials and provider caches outside version control.

## Versioning and releases

The Git tag, `CITATION.cff`, `codemeta.json`, `DESCRIPTION`, README, manuscript, checksum manifest, and Zenodo version archive must identify the same release. Published tags and Zenodo versions are immutable.

Releases are cut only after:

1. the complete account-free suite passes on the exact candidate commit;
2. the applicable public CHIRPS numerical validation passes;
3. the complete tracked-file checksum manifest is regenerated and verified;
4. continuous-integration results correspond to the exact release commit;
5. the candidate has passed the required independent review.

The version-specific Zenodo DOI is minted from the validated tag and inserted only after Zenodo issues it. Do not commit an invented DOI, a placeholder DOI, or a claim that an unarchived release is immutable.

## Licence of contributions

By contributing, you agree that your code and documentation contributions are licensed under the repository's MIT License. Retain all third-party data attributions and required notices in `NOTICE.md`.

## AI-assisted contributions

AI tools may be used for coding, review, or language support. The contributor must inspect every proposed change, verify cited facts and licences, run the relevant checks, and remain accountable for the contribution. AI output is not evidence.

## Code of conduct, support, and security

Be specific, professional, and evidence-based. Critique code and claims rather than contributors. Do not use issues or pull requests to expose private information or credentials.

Use GitHub Issues for ordinary reproducible defects and feature requests. Follow `SECURITY_REVIEW.md` for security-sensitive concerns.
