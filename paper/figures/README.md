# Manuscript figures

All figures in this directory are generated from version-controlled sources by:

```text
Rscript R/make_manuscript_figures.R
```

Generated files are written to `paper/figures/generated/` and uploaded by GitHub Actions as the `manuscript-figures` artifact. Generated binary files are not committed until the author has inspected them and selected the final journal layout.

## Planned captions

**Fig. 1 Cross-provider Earth-data preparation and auditable release contract.** Provider-specific environmental products pass through documented masking, scaling, temporal aggregation, district aggregation, provenance classification, and release-integrity controls. The synthetic fixture exercises the transformation paths without provider accounts; it does not validate the source products or the reported 2023 district values.

**Fig. 2 Spatial distribution of the four released district-level environmental layers for Rwanda.** (a) CHIRPS annual rainfall for 2023, in millimetres; (b) ERA5-Land mean 2 m air temperature for 2023, in degrees Celsius; (c) MODIS MOD13A3 mean NDVI for 2023; and (d) percentage of district area represented by HAND values of 5 m or less. The HAND layer is a static relative-elevation descriptor and must not be interpreted as observed flooding or flood probability.

**Fig. 3 Standardized district profiles across the four released environmental layers.** Values are expressed as within-layer z scores to make cross-layer spatial patterns visually comparable despite different physical units. District ordering is based on the first principal component of the four standardized layers. The plot is descriptive and does not represent an epidemiological risk score, hazard index, or causal model.

## Editorial controls

- Figure values are read from the archived GeoJSON files, not copied manually.
- The script fails if a layer does not contain exactly 30 districts, a required field is absent, or a value is non-finite.
- The map palette is perceptually ordered and designed to remain interpretable when converted to greyscale.
- Vector SVG versions of the four maps are retained for layout flexibility; the combined map and profile figure are produced as 600 dpi TIFF files.
- Captions, source attribution, and interpretive limitations remain in the manuscript rather than being embedded in the graphics.
