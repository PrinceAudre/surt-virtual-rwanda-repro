# NOTICE: attributions, data licenses, and scope

## Code
The code in this repository is released under the MIT License (see `LICENSE`). The functions in `R/provenance_value_class.R` are reproduced from the SuRT-Virtual Rwanda application source, with the two edits disclosed in that file's header.

## Data attributions and licenses (`data/`)
All climate layers are aggregated to Rwanda's 30 districts, and the district geometry is common to every layer.

- **District boundaries (geometry; all layers and `relief_districts.geojson`)**: World Bank, "Rwanda Admin Boundaries and Villages" (district level, 30 districts). License: **CC BY 4.0**.
- **`relief_climate_rainfall.geojson`**: CHIRPS v2.0 annual precipitation, 2023. Source: Climate Hazards Center, UC Santa Barbara. License: **public domain / CC0**. Cite: Funk C, Peterson P, Landsfeld M, et al. Scientific Data 2:150066 (2015), doi:10.1038/sdata.2015.66.
- **`relief_climate_temp.geojson`**: ERA5-Land 2m temperature, monthly-mean 2023. Source: Copernicus Climate Data Store / ECMWF. Terms: **Copernicus Products licence** (reuse and redistribution permitted with attribution and the required notice/disclaimer). Cite: Munoz-Sabater J, et al. Earth System Science Data 13:4349-4383 (2021), doi:10.5194/essd-13-4349-2021.
- **`relief_climate_ndvi.geojson`**: MODIS/Terra MOD13A3 v061, annual-mean NDVI 2023. Source: NASA LP DAAC. License: **CC0**. Cite: Didan K. MOD13A3 v061, NASA LP DAAC (2021), doi:10.5067/MODIS/MOD13A3.061.
- **`relief_low_lying_hand.geojson`**: Height Above Nearest Drainage (HAND), expressed as the share of district area within 5 m above nearest drainage. Source: ASF / HydroSAR, derived from Copernicus GLO-30. License: **CC0**. This is a terrain descriptor, not observed flooding or a validated hazard model. Method: Nobre AD, et al. Journal of Hydrology 404(1-2):13-29 (2011), doi:10.1016/j.jhydrol.2011.03.051.
- **`relief_districts.geojson`**: district geometry only, from the World Bank dataset above (**CC BY 4.0**). The earlier WorldPop-derived prototype population attribute was removed in v1.1.0 because it was peripheral to this artifact and introduced an unnecessary ODbL share-alike dependency.

Colourblind-safe palette reference used by the code: Wong B. Points of view: color blindness. Nature Methods 8(6):441 (2011), doi:10.1038/nmeth.1618.

## Scope: what is deliberately NOT included
- The full SuRT-Virtual Rwanda application, its interactive dashboard, and its operational-adjacent layer (decision-support, forecast, supply, and workforce views).
- The application's real methodology register. `R/example_register.R` is a small illustrative schema example only, not the application's register.
- Any disease-side data. The application's disease signals are synthetic and illustrative; none are included here.
