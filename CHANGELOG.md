# Changelog

## 1.1.0 - 2026-07-29

- Replaced the potentially evaluative evidence class `sound` with
  `source-derived`.
- Renamed the HAND output and field to the neutral
  `low_lying_share_pct`; it is no longer described as flood-prone or
  flood-susceptibility.
- Removed the peripheral WorldPop-derived population attribute and its ODbL
  dependency from the released district geometry.
- Corrected ERA5-Land licensing language to the Copernicus Products licence.
- Made all builders repository-relative and parameterised their output,
  geometry, and cache paths.
- Added an account-free fixture pipeline, a one-command verification runner,
  an R dependency lockfile, and GitHub Actions.
- Added explicit reproducibility guidance and strengthened release metadata.
