# Data dictionary

## Generic SuRT-GeoHarmonizer output contract for v1.4

`R/harmonize_admin_raster.R` writes a GeoJSON FeatureCollection in EPSG:4326. Every feature contains:

- `unit_id` (string): unique non-empty identifier copied from the user-selected boundary field;
- a user-selected measurement property, whose name begins with a letter and contains only letters, digits, and underscores;
- `raster_coverage_fraction` (number, 0 to 1): fraction of polygon surface area intersecting the selected raster footprint;
- `valid_within_raster_fraction` (number, 0 to 1): fraction of raster-covered polygon area represented by finite selected-raster values after raw-value masking and scale/offset conversion;
- `valid_data_fraction` (number, 0 to 1): overall polygon valid-data fraction, calculated as `raster_coverage_fraction * valid_within_raster_fraction`;
- `provenance` (string): human-readable source, product, period or threshold, transformation basis, and applicable terms;
- polygon or multipolygon geometry.

The measurement is a surface-area-weighted mean over finite raster values. For each intersected raster cell, the contribution weight is the polygon-cell overlap fraction multiplied by the cell surface area in square metres. The mean is therefore calculated over valid raster-covered area rather than by treating equal angular cells as equal-area observations.

`--na-below` and `--na-above` are interpreted in raw/source raster units and are applied before `--scale` and `--offset`. `--min-valid-fraction` is evaluated against `valid_data_fraction`; the default is `0`, which reports coverage without rejecting partial support. Optional output rounding and minimum/maximum value bounds are applied after aggregation.

The software stops if the raster or boundary CRS is missing, polygon geometry is invalid or unsupported, identifiers are empty or duplicated, a polygon receives no finite raster value, the overall valid-data fraction violates a declared minimum, or a declared output bound is violated.

The interface validates computation and schema. It does not determine whether a variable, product, temporal period, scale factor, threshold, unit, or interpretation is scientifically appropriate.

The account-free example output is written to `generated/generic_admin_example.geojson`. Its controlled administrative identifiers are `ALPHA-01`, `BETA-02`, and `GAMMA-03`; its measurement property is `environment_mean`; and it includes the three coverage fractions above plus provenance identifying the data as synthetic test evidence.

## Rwanda reference builders for v1.4

The v1.4 provider builders write development outputs under `generated/` by default. They use the common Rwanda district geometry and retain provider-specific scientific semantics.

### CHIRPS annual rainfall

`R/build_relief_climate_rainfall.R` writes:

- `district` (string);
- `annual_rainfall_mm` (number): CHIRPS v2.0 annual precipitation in millimetres for the selected year;
- `raster_coverage_fraction`;
- `valid_within_raster_fraction`;
- `valid_data_fraction`;
- `provenance`.

Negative CHIRPS no-data/fill values are masked before aggregation. District rainfall is a polygon-overlap and cell-surface-area-weighted mean over finite annual raster values.

### ERA5-Land 2 m air temperature

`R/build_relief_climate_temperature.R` writes:

- `district` (string);
- `mean_temp_c` (number): annual mean 2 m air temperature in degrees Celsius;
- `raster_coverage_fraction`;
- `valid_within_raster_fraction`;
- `valid_data_fraction`;
- `provenance`.

The annual raster is the calendar-day-weighted mean of the 12 ERA5-Land monthly means for the selected year, including the correct February length in leap years. Kelvin values are converted to degrees Celsius before the district surface-area-weighted summary.

### MODIS MOD13A3 v061 NDVI

`R/build_relief_climate_ndvi_real.R` writes:

- `district` (string);
- `mean_ndvi` (number): annual mean MOD13A3 NDVI after scale, quality filtering, temporal aggregation, and spatial aggregation;
- `valid_ndvi_area_fraction` (number, 0 to 1): overall district area fraction with finite annual NDVI after the configured quality and temporal-completeness policy;
- `mean_valid_month_fraction` (number, 0 to 1): surface-area-weighted mean fraction of monthly mosaics with an accepted finite NDVI value;
- `provenance`.

The v1.4 default accepts MOD13A3 pixel reliability rank `0` only and requires each annual raster cell to have accepted values in at least 50% of monthly mosaics. Rank `1` can be admitted deliberately through the transform helper; `accepted_quality = NULL` is an explicit unfiltered mode, not the production default. District means are surface-area weighted.

### Global 30 m HAND terrain descriptor

`R/build_relief_low_lying_hand.R` writes:

- `district` (string);
- `low_lying_share_pct` (number, 0 to 100): percentage of valid HAND-covered district area at or below the selected HAND threshold;
- `raster_coverage_fraction`;
- `valid_within_raster_fraction`;
- `valid_data_fraction`;
- `valid_hand_area_fraction` (number, 0 to 1): semantic alias of `valid_data_fraction` retained for domain readability and backward compatibility;
- `provenance`.

Negative HAND sentinels are treated as no-data. The numerator and denominator both use polygon-cell overlap multiplied by cell surface area. `low_lying_share_pct` is therefore not a percentage of the whole district when HAND coverage is incomplete. It is a static terrain descriptor, not observed flooding, flood probability, a validated flood-hazard model, or an operational recommendation.

## Published v1.3 reference files versus v1.4 development outputs

The committed files under `data/` are the immutable published v1.3 reference artifacts unless and until a reviewer-remediation step explicitly replaces them after real-data regeneration and independent validation. They should not be interpreted as already regenerated v1.4 scientific outputs merely because the v1.4 code is present on the development branch.

The v1.4 builders intentionally default to `generated/` so revised scientific outputs can be checked before any published reference file is replaced. Final v1.4 release files must be regenerated, independently reviewed, and included in the exact release checksum manifest before tagging.

Inspect GeoJSON with `sf::st_read()`, `terra::vect()`, Python's standard `json` module, or another GeoJSON-compatible tool.
