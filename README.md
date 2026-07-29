# SuRT-Virtual Rwanda: reproducibility artifact

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21671788.svg)](https://doi.org/10.5281/zenodo.21671788)

Reproducibility artifact for the paper *An R pipeline for district-level environmental layers and provenance labelling: a Rwanda proof of concept*.

It contains the environmental-data preparation pipeline and the provenance / value-class discipline described in that paper, together with source-derived environmental layers for Rwanda's 30 districts under the per-file terms documented in `NOTICE.md`.

## What this is, and what it is not

This is a **reduced, honestly-scoped** artifact. It is **not** the whole SuRT-Virtual Rwanda application.

- It **is**: the real environmental data pipeline (rainfall, temperature, vegetation greenness, and low-lying terrain share, aggregated to Rwanda's 30 districts); the generic provenance / value-class functions that enforce the labelling discipline; and the resulting source-derived environmental layers as data.
- It is **not**: the full application. The application's real methodology register, its interactive dashboard, and its operational-adjacent layer (for example decision-support queues, forecast and supply / workforce views) are deliberately **not included**. They remain a private, non-operational research prototype.
- The disease-side signals in the application are **synthetic and illustrative**, so this artifact ships **no disease data at all**. It ships only the source-derived environmental layers and code. The value-class functions are demonstrated against a small, clearly labelled illustrative example register (`R/example_register.R`), which is **not** the application's register.

**Non-operational.** Nothing here is validated for, or intended for, clinical, operational, or resource-allocation use (`operational_use_allowed = FALSE`). The environmental values are source-derived and retain the per-file terms documented in `NOTICE.md`; they are provided for descriptive research and reproducibility only.

## Contents

- `R/` environmental pipeline, the provenance/value-class module (`provenance_value_class.R`), an illustrative example register (`example_register.R`), the nine-assertion demonstration (`demo_value_class.R`), and an account-free fixture pipeline (`test_fixture_pipeline.R`).
- `python/` the two official-client fetchers for ERA5-Land (Copernicus CDS) and MODIS NDVI (NASA Earthdata). No credentials are stored here; each reads the user's own account credentials from the standard local files.
- `data/` the source-derived environmental layers for Rwanda's 30 districts as GeoJSON (rainfall, temperature, NDVI, and low-lying HAND share), plus district boundary geometry. See `DATA_DICTIONARY.md` and `NOTICE.md`.

## Account-free reproducibility check

After restoring `renv.lock`, run:

```text
python python/run_all_checks.py
```

This runs 17 assertions across the labelling and environmental transformations,
writes an inspectable synthetic-fixture GeoJSON, and verifies the release
checksums. It requires no network access, private repository, or data-provider
account. See `REPRODUCIBILITY.md` for real-data build commands and the precise
boundary between fixture verification and rebuilding the released 2023 layers.

## The provenance / value-class discipline

`R/provenance_value_class.R` implements the contract described in the paper: a register row is accepted as `source-derived` only when it declares a documented method on real/public data; unknown, incomplete, synthetic, or placeholder entries are treated as `illustrative` by default.

Run the demo and checks:

    Rscript R/demo_value_class.R

## Licenses

- **Code**: MIT (see `LICENSE`).
- **Data**: per-source, in `data/`. District boundaries are World Bank CC BY 4.0; CHIRPS is public domain / CC0; ERA5-Land is under the Copernicus Products licence; MODIS and HAND are CC0. Full per-file attributions and required citations are in **`NOTICE.md`**. No single software licence is asserted over the data.

## Verification and environment

All release files carry SHA-256 checksums in `CHECKSUMS.sha256`. The exact R and package versions are recorded in `environment.txt` and `renv.lock`. GitHub Actions repeats the account-free checks on a clean runner.

## How to cite

Please cite the paper (Tuyishime Audre Prince, Clinton Health Access Initiative; ORCID 0009-0002-0799-3140) and the archived software release. The concept DOI for all versions is [10.5281/zenodo.21671788](https://doi.org/10.5281/zenodo.21671788); the published v1.1.1 version DOI is [10.5281/zenodo.21677162](https://doi.org/10.5281/zenodo.21677162).

See also: `NOTICE.md` (attributions and data licenses), `DATA_DICTIONARY.md` (data fields), and `SECURITY_REVIEW.md` (what was reviewed and what was deliberately excluded).
