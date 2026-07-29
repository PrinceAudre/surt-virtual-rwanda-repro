# Data dictionary

All files in `data/` are GeoJSON FeatureCollections with 30 features, one per Rwandan district (EPSG:4326). Every feature carries a `provenance` string recording the source, product version, temporal basis, and license of its value.

## Common properties
- `district` (string): district name (one of Rwanda's 30 districts).
- `provenance` (string): source, product, period, and license of the value in that file.

## Per-file value property
- **`relief_climate_rainfall.geojson`**: CHIRPS v2.0 annual precipitation for 2023 (mm), per district.
- **`relief_climate_temp.geojson`**: ERA5-Land 2m air temperature, monthly-mean 2023 (degrees Celsius), per district.
- **`relief_climate_ndvi.geojson`**: MODIS MOD13A3 v061 annual-mean NDVI 2023 (dimensionless, approximately 0 to 1), per district.
- **`relief_low_lying_hand.geojson`**: `low_lying_share_pct` = share of district area with HAND <=5 m (percent). A static terrain descriptor, not observed flooding or a validated hazard model.
- **`relief_districts.geojson`**: boundary geometry with the `district` property only.

The exact value-field name in each file is visible in the file itself. Inspect any file in R with `jsonlite::fromJSON()` or `terra::vect()`, or read the `provenance` property directly.
