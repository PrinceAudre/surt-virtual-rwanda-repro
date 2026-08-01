# SuRT-Virtual Rwanda: reproducibility artifact

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21671788.svg)](https://doi.org/10.5281/zenodo.21671788)

Companion reproducibility artifact for the working Software article *An auditable cross-provider workflow for district-scale Earth-data harmonization and provenance labelling: software design and a Rwanda implementation*.

## Version 1.2.0 release freeze

The current branch is the **version 1.2.0 pre-DOI release freeze**. It extends the published version 1.1.1 base archive with additional validators, numerical-validation workflows, figures, evidence summaries, and submission records. Scientific and figure review are closed. The immutable Zenodo version DOI must still be reserved and inserted before the exact Git tag, archival publication, citation, or journal submission.

- **Release-freeze version:** `1.2.0`
- **Published base archive:** version 1.1.1, DOI `10.5281/zenodo.21677162`
- **Concept DOI for all versions:** `10.5281/zenodo.21671788`
- **Version DOI:** not yet reserved; no placeholder DOI is asserted
- **Freeze branch:** `codex/earth-science-informatics-refinement-v1.3.0`

Until the version DOI is published, cite version 1.1.1 only for the historical base archive and do not represent it as containing the version 1.2.0 additions.

## Scope

This is a reduced, honestly scoped artifact. It is not the whole SuRT-Virtual Rwanda application.

It includes:

- provider-specific preparation of CHIRPS rainfall, ERA5-Land temperature, MODIS NDVI, and HAND terrain data;
- district-level GeoJSON outputs for Rwanda's 30 districts;
- a fail-closed provenance and evidence-class module;
- positive transformation fixtures, projected non-Rwanda portability checks, and deliberate failure injection;
- independent release-contract and corruption validation;
- scoped public CHIRPS numerical reproduction and weighting sensitivity;
- machine-readable verification summaries, figures, source terms, and integrity metadata.

It excludes:

- the private interactive application and its full methodology register;
- disease, patient, surveillance, or confidential operational data;
- decision, forecast, supply, workforce, clinical, or resource-allocation interfaces; and
- any claim that the prepared layers are validated hazards, forecasts, epidemiological effects, or operational recommendations.

`operational_use_allowed = FALSE`.

## Repository map

- `R/`: provider transformations and builders, provenance functions, positive fixtures, portability fixture, failure-injection tests, CHIRPS numerical validation, and manuscript-figure generation.
- `python/`: provider fetch clients, the cross-platform verification runner, and the independent GeoJSON release-contract validator.
- `data/`: district geometry and four environmental GeoJSON layers.
- `.github/workflows/`: clean account-free verification and public CHIRPS validation.
- `paper/`: manuscript, journal-targeting analysis, dual-agent review ledger, readiness record, reviewer dossier, figure accessibility record, and historical submission records under `paper/archive/`.
- `NOTICE.md`, `DATA_DICTIONARY.md`, and `CHECKSUMS.sha256`: source terms, field definitions, and the current listed-file integrity scope.

Historical F1000Research submission files were removed from the active candidate tree and remain available in Git history. See `paper/archive/F1000_ARTIFACT_INDEX.md`.

## Account-free verification

After restoring `renv.lock`, run:

```text
python python/run_all_checks.py
```

The runner executes **41 explicit outcomes**:

- 9 provenance assertions;
- 9 controlled environmental-transformation assertions;
- 6 geometry-agnostic portability assertions;
- 7 transformation failure-injection assertions;
- 5 valid release-layer contract checks; and
- 5 deliberate release-corruption rejections.

It also writes machine-readable summaries, creates an inspectable fixture GeoJSON, and verifies every file currently listed in `CHECKSUMS.sha256`. No private repository, provider account, or network call is required for this command.

## Public CHIRPS numerical validation

Run:

```text
Rscript R/validate_chirps_rainfall.R 2023
```

The workflow independently downloads the public CHIRPS 2023 annual GeoTIFF, reproduces the 30 archived district values, cross-checks `exactextractr` against `terra`, and quantifies cell-area weighting sensitivity.

Current clean-CI results:

- 30/30 archived values reproduce exactly after rounding;
- maximum cross-engine difference: 0.000136 mm;
- maximum cell-area-weighting difference: 0.005127 mm.

This validates computational reproduction of the CHIRPS layer only. It does not validate CHIRPS observational accuracy or the ERA5-Land, MODIS, and HAND layers.

## Real-data builders

```text
Rscript R/build_relief_climate_rainfall.R 2023
Rscript R/build_relief_climate_temperature.R 2023
Rscript R/build_relief_climate_ndvi_real.R 2023
Rscript R/build_relief_low_lying_hand.R 5
```

CHIRPS and HAND require network access. ERA5-Land and MODIS additionally require the user's own free Copernicus Climate Data Store and NASA Earthdata credentials. Credentials are read from provider-standard local files and are not stored in the repository.

## Provenance contract

`R/provenance_value_class.R` accepts `source-derived` status only when a register row declares a documented method applied to real or public data. Unknown, incomplete, synthetic, and placeholder entries default to `illustrative` and receive an explanatory note.

The current candidate records lightweight human-readable provenance. It does not claim PROV-O, RO-Crate, or CWL conformance.

## Licences

- **Code:** MIT, see `LICENSE`.
- **Data:** source-specific. District boundaries are World Bank CC BY 4.0; CHIRPS is public domain/CC0; ERA5-Land uses the Copernicus Products licence; MODIS and HAND are CC0. See `NOTICE.md`.

## Citation

For the published base software, cite version 1.1.1:

> Tuyishime AP (2026). SuRT-Virtual Rwanda: reproducibility artifact for district-level environmental-layer preparation and provenance labelling. Version 1.1.1. Zenodo. https://doi.org/10.5281/zenodo.21677162

Version 1.2.0 is frozen pending DOI reservation. After the reserved version DOI is inserted, the complete manifest will be regenerated and the exact commit will be tagged and archived before journal submission.

See `REPRODUCIBILITY.md`, `SECURITY_REVIEW.md`, `paper/DUAL_AGENT_REVIEW.md`, and `paper/EDITORIAL_READINESS.md`.
