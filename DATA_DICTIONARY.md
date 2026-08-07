# Data dictionary

## Generic SuRT-GeoHarmonizer output

`R/harmonize_admin_raster.R` writes a GeoJSON FeatureCollection in EPSG:4326. Every feature contains only:

- `unit_id` (string): unique non-empty identifier copied from the user-selected boundary field;
- a user-selected measurement property, whose name begins with a letter and contains only letters, digits, and underscores;
- `provenance` (string): human-readable source, product, period or threshold, transformation basis, and applicable terms;
- polygon or multipolygon geometry.

The generic interface calculates a coverage-fraction-weighted raster mean for each polygon. Optional scale, offset, masking, rounding, and output bounds are applied as declared by the user. The software stops if geometry or raster CRS is missing, geometry is invalid, identifiers are empty or duplicated, a polygon receives no finite value, or a declared bound is violated.

The interface validates computation and schema. It does not determine whether a variable, product, temporal period, scale factor, threshold, unit, or interpretation is scientifically appropriate.

The account-free example output is written to `generated/generic_admin_example.geojson` and contains:

- `unit_id`: `ALPHA-01`, `BETA-02`, or `GAMMA-03`;
- `environment_mean`: controlled values 10, 20, and 30;
- provenance stating that the data are synthetic and not source-derived evidence.

## Rwanda reference files

All committed files in `data/` are GeoJSON FeatureCollections with 30 features, one per Rwandan district in EPSG:4326. Every environmental feature carries a `provenance` string recording the source, product version, temporal basis or threshold, and licence or terms.

### Common properties

- `district` (string): one of Rwanda's 30 district names;
- `provenance` (string): source, product, period or threshold, and applicable terms.

### Per-file value properties

- **`relief_climate_rainfall.geojson`**: `annual_rainfall_mm`, CHIRPS v2.0 annual precipitation for 2023 in millimetres;
- **`relief_climate_temp.geojson`**: `mean_temperature_c`, ERA5-Land 2 m air temperature, mean of 12 monthly means for 2023 in degrees Celsius;
- **`relief_climate_ndvi.geojson`**: `mean_ndvi`, MODIS MOD13A3 v061 annual-mean NDVI for 2023, dimensionless;
- **`relief_low_lying_hand.geojson`**: `low_lying_share_pct`, percentage of district polygon represented by HAND values at or below 5 m. This is a static terrain descriptor, not observed flooding or a validated hazard model;
- **`relief_districts.geojson`**: boundary geometry with the `district` property only.

Inspect a file with `sf::st_read()`, `terra::vect()`, Python's standard `json` module, or another GeoJSON-compatible tool.
