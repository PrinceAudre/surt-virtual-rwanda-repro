# NOTICE: attributions, data licences, and scope

## Code

SuRT-GeoHarmonizer code is released under the MIT License, see `LICENSE`. The functions in `R/provenance_value_class.R` were extracted from the private SuRT-Virtual Rwanda application source with the edits disclosed in that file's header.

`R/harmonize_admin_raster.R` is a provider-agnostic interface. Users who process external raster or boundary files remain responsible for complying with the source terms governing those inputs and any generated derivative outputs. Supplying a provenance string does not itself establish legal permission or scientific validity.

## Rwanda reference-data attributions and licences (`data/`)

All environmental layers are aggregated to Rwanda's 30 districts, and the district geometry is common to every layer.

- **District boundaries, including `relief_districts.geojson`:** World Bank, "Rwanda Admin Boundaries and Villages", district level. Licence: **CC BY 4.0**.
- **`relief_climate_rainfall.geojson`:** CHIRPS v2.0 annual precipitation, 2023. Source: Climate Hazards Center, University of California Santa Barbara. Licence: **public domain or CC0**. Cite Funk C, Peterson P, Landsfeld M, et al., Scientific Data 2:150066 (2015), doi:10.1038/sdata.2015.66.
- **`relief_climate_temp.geojson`:** ERA5-Land 2 m temperature, monthly-mean 2023. Source: Copernicus Climate Data Store and ECMWF. Terms: **Copernicus Products licence**, including required attribution and disclaimer. Cite Muñoz-Sabater J, et al., Earth System Science Data 13:4349-4383 (2021), doi:10.5194/essd-13-4349-2021.
- **`relief_climate_ndvi.geojson`:** MODIS/Terra MOD13A3 v061 annual-mean NDVI, 2023. Source: NASA LP DAAC. Licence: **CC0**. Cite Didan K, MOD13A3 v061 (2021), doi:10.5067/MODIS/MOD13A3.061.
- **`relief_low_lying_hand.geojson`:** Height Above Nearest Drainage, expressed as the share of district area represented by values at or below 5 m. Source: ASF or HydroSAR, derived from Copernicus GLO-30. Licence: **CC0**. This is a terrain descriptor, not observed flooding or a validated hazard model. Method: Nobre AD, et al., Journal of Hydrology 404:13-29 (2011), doi:10.1016/j.jhydrol.2011.03.051.

The earlier WorldPop-derived prototype population attribute was removed in version 1.1.0 because it was peripheral to the software and introduced an unnecessary ODbL share-alike dependency.

The colourblind-safe palette reference used by figure code is Wong B, Color blindness, Nature Methods 8:441 (2011), doi:10.1038/nmeth.1618.

## Synthetic and generated examples

Files created by `R/test_generic_harmonizer.R`, `R/test_portability_fixture.R`, and other controlled fixtures are synthetic. They must not be represented as source-derived environmental evidence. Generated files under `generated/` are excluded from version control unless a release process explicitly archives them as evidence.

## Deliberate scope exclusions

This repository does not contain:

- the full SuRT-Virtual Rwanda interactive application;
- operational decision, forecast, supply, workforce, clinical, or resource-allocation interfaces;
- the private application's real methodology register;
- patient, disease, surveillance, or confidential operational data;
- a validated flood, climate, exposure, epidemiological, or risk model;
- a claim that the generic interface determines scientifically appropriate inputs or interpretations.

`R/example_register.R` is a small illustrative schema example and is not the private application's register. Any disease-side signals in the private application are outside this repository.
