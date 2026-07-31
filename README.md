# SuRT-Virtual Rwanda: reproducibility artifact

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21671788.svg)](https://doi.org/10.5281/zenodo.21671788)

Reproducibility artifact for the paper *A reproducible R workflow for district-level environmental layers with fail-closed provenance labelling: a Rwanda implementation*.

It contains the environmental-data preparation workflow and provenance / value-class contract described in the paper, together with source-derived environmental layers for Rwanda's 30 districts under the per-file terms documented in `NOTICE.md`.

## What this is, and what it is not

This is a **reduced, honestly scoped** artifact. It is **not** the whole SuRT-Virtual Rwanda application.

- It **is**: the environmental workflow for rainfall, temperature, vegetation greenness, and low-lying terrain share; the generic provenance / value-class functions; and the resulting source-derived district layers.
- It is **not**: the private interactive application, its full methodology register, or its operational-adjacent decision, forecast, supply, and workforce interfaces.
- It contains **no disease data**. The value-class functions are demonstrated against a small, clearly labelled example register (`R/example_register.R`), not the private application's register.

**Non-operational.** Nothing in this repository is validated or intended for clinical, operational, hazard, forecasting, or resource-allocation use (`operational_use_allowed = FALSE`). The environmental layers are supplied for descriptive research and reproducibility.

## Contents

- `R/`: environmental builders and transformation functions, the provenance/value-class module, the example register, the nine-assertion provenance demonstration, and the nine-assertion environmental fixture.
- `python/`: official-client fetchers for ERA5-Land and MODIS NDVI, plus the cross-platform verification runner.
- `data/`: district GeoJSON layers for rainfall, temperature, NDVI, low-lying HAND share, and district geometry.
- `paper/`: the manuscript source, editorial-readiness checklist, and referee suggestions. The prior v1.1.1 submission file is retained as an archive of the declined submission.

## Account-free reproducibility check

After restoring `renv.lock`, run:

```text
python python/run_all_checks.py
```

This runs **18 assertions** across provenance labelling and environmental transformations, writes an inspectable synthetic-fixture GeoJSON, and verifies every release checksum. It requires no private repository, network call, or data-provider account.

See `REPRODUCIBILITY.md` for real-data build commands and the boundary between software verification and rebuilding the source-derived 2023 layers.

## Provenance / value-class contract

`R/provenance_value_class.R` implements a fail-closed rule: a register row is accepted as `source-derived` only when it declares a documented method applied to real or public data. Unknown, incomplete, synthetic, and placeholder entries are treated as `illustrative`.

Run the demonstration directly:

```text
Rscript R/demo_value_class.R
```

## Licences

- **Code:** MIT, see `LICENSE`.
- **Data:** per source. District boundaries are World Bank CC BY 4.0; CHIRPS is public domain / CC0; ERA5-Land uses the Copernicus Products licence; MODIS and HAND are CC0. Full attribution and terms are in `NOTICE.md`.

## Verification and environment

Release files carry SHA-256 checksums in `CHECKSUMS.sha256`. R and package versions are recorded in `environment.txt` and `renv.lock`. GitHub Actions repeats the account-free checks on a clean runner.

## How to cite

Please cite the paper and the archived software release. The concept DOI for all versions is [10.5281/zenodo.21671788](https://doi.org/10.5281/zenodo.21671788); the published v1.1.1 version DOI is [10.5281/zenodo.21677162](https://doi.org/10.5281/zenodo.21677162).

See also `NOTICE.md`, `DATA_DICTIONARY.md`, `REPRODUCIBILITY.md`, `SECURITY_REVIEW.md`, and `paper/EDITORIAL_READINESS.md`.
