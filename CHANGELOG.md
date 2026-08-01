# Changelog

## 1.2.0 - 2026-08-01

### Scientific and software evaluation

- Reframed the article as an Earth Science Informatics Software article focused on cross-provider Earth-data harmonization, provenance, executable evidence, and release integrity.
- Expanded account-free verification from 18 positive assertions to 41 explicit outcomes:
  - 9 provenance assertions;
  - 9 environmental-transformation assertions;
  - 6 projected, arbitrary-identifier portability assertions;
  - 7 transformation failure-injection assertions;
  - 5 valid GeoJSON release-contract checks; and
  - 5 deliberate release-corruption rejections.
- Added `python/validate_release_contract.py`, an independent standard-library validator for feature counts, identifiers, schemas, values, provenance, coordinates, district ordering, and exact geometry identity.
- Added `R/test_portability_fixture.R` to exercise generic transformations with projected non-Rwanda geometry and arbitrary administrative identifiers.
- Added `R/test_failure_modes.R` to prove that missing coverage, unit errors, inversion, unscaled MODIS values, partial years, all-no-data terrain, and impossible percentages fail closed.
- Added public CHIRPS numerical validation with exact archived-value reproduction, an independent `terra` cross-check, cell-area weighting sensitivity, machine-readable evidence, and a source-raster digest.
- Distinguished the 41 behavioural and contract outcomes from the separately scoped listed-file SHA-256 integrity checks.

### Manuscript and figures

- Rebuilt `paper/manuscript.md` around a six-level evidence hierarchy and narrowed every portability, numerical-validation, hazard, epidemiological, and operational claim.
- Added literature on Earth-science workflow reuse, FAIR provenance, PROV-O, and RO-Crate while explicitly avoiding standards-conformance claims.
- Added reproducible manuscript figures generated from the committed GeoJSON files.
- Added caption-free EPS and SVG line art and 600 dpi TIFF combination art, numeric map intervals, greyscale-ordered colour, and redundant line types and symbols.
- Added `paper/figures/ALT_TEXT.md` for final Word accessibility checks.
- Added a journal-specific reviewer dossier and a strict editorial-readiness record.
- Added `paper/DUAL_AGENT_REVIEW.md` as a shared Claude and Codex finding and decision ledger.

### Submission-package and release hygiene

- Archived the prior F1000Research readiness record and removed the historical F1000Research Word file and build script from the active candidate tree without rewriting Git history.
- Froze the release-facing package metadata at version 1.2.0 pending reservation and insertion of the immutable Zenodo version DOI.
- Retained version 1.1.1 and DOI `10.5281/zenodo.21677162` as the historical published base archive only.
- Replaced the interim checksum scope with a complete all-tracked SHA-256 manifest; DOI insertion will require one final manifest regeneration and exact-head CI run before tagging and archival.

## Archived - F1000Research resubmission hardening attempt

- Reframed the earlier manuscript as one integrated Software Tool workflow.
- Added comparison with Google Earth Engine, MODIStsp, and `exactextractr`.
- Added input/output contracts, use cases, and a clearer distinction between software verification and scientific validation.
- Removed an unverified institutional affiliation from `CITATION.cff`.
- Added an editorial-readiness checklist and synchronized the then-current manuscript title.

This attempt was superseded after submission 188121 was declined at pre-publication check on 31 July 2026. Historical records are preserved under `paper/archive/` and in Git history.

## 1.1.1 - 2026-07-29

- Expanded the account-free NDVI fixture to exercise the complete two-month and two-tile MODIS-sinusoidal mosaic, annual-mean, scale, reprojection, and district-extraction path.
- Corrected the manuscript and submission package to report the resulting nine environmental-fixture assertions.

## 1.1.0 - 2026-07-29

- Replaced the potentially evaluative evidence class `sound` with `source-derived`.
- Renamed the HAND output and field to the neutral `low_lying_share_pct`; it is no longer described as flood-prone or flood-susceptibility.
- Removed the peripheral WorldPop-derived population attribute and its ODbL dependency from the released district geometry.
- Corrected ERA5-Land licensing language to the Copernicus Products licence.
- Made all builders repository-relative and parameterised their output, geometry, and cache paths.
- Added an account-free fixture pipeline, a one-command verification runner, an R dependency lockfile, and GitHub Actions.
- Added explicit reproducibility guidance and strengthened release metadata.
