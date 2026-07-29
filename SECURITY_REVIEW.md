# Security and scope review

Before this artifact was prepared, its candidate contents were reviewed so that no sensitive, private, or operational material would be published. This note records that review for transparency.

## Reviewed and cleared
- **Environmental pipeline code** (`R/` builders and transforms, `python/` fetchers): no credentials or secrets. The two fetchers read the user's own Copernicus CDS and NASA Earthdata credentials from standard local files (`.cdsapirc` and the earthaccess-managed netrc); no key is stored in the code.
- **Environmental data** (`data/`): licence-checked for redistribution (World Bank CC BY 4.0 boundaries; CHIRPS CC0; ERA5-Land under the Copernicus Products licence; MODIS CC0; HAND CC0). The WorldPop-derived prototype population attribute was removed in v1.1.0. See `NOTICE.md`.
- **Provenance / value-class functions**: the generic functions only, reproduced with the edits disclosed in `provenance_value_class.R`.

## Deliberately excluded
- **All synthetic disease data.** The application's synthetic hazard and signal datasets were excluded. They are synthetic, but they include sensitive-topic content and operational-adjacent outputs that have no place in a climate-and-provenance artifact.
- **The application's real methodology register and its gate.** These enumerate the full application, including its operational-adjacent outputs (decision-support, forecast, supply, and workforce). Only the generic value-class functions are included.
- **The full application and its interactive dashboard.**

This artifact is therefore a reduced, descriptive, non-operational slice of the project, sufficient to inspect the environmental-data preparation pathway and to exercise the provenance / value-class discipline described in the paper.
