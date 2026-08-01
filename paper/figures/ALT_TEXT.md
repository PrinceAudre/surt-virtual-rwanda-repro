# Figure alternative text and accessibility record

Use the concise alternatives below in the final Word manuscript. They describe the information conveyed by each figure without duplicating the full caption. Final wording must be rechecked against the exact generated files after the candidate release is frozen.

## Figure 1

**Alternative text:** Flow diagram linking four source products to provider-specific preprocessing, administrative polygon extraction, standardized GeoJSON output, and versioned release controls. Five separate evidence paths show positive transformation tests, projected non-Rwanda portability tests, failure injection, independent release-contract checks, and public CHIRPS numerical reproduction. All evidence paths feed clean continuous integration and integrity reporting.

**Accessibility checks:**

- No article title or caption is embedded in the artwork.
- Solid arrows denote the production path; dashed arrows denote evidence and validation paths.
- All nodes are labelled with text and do not rely on colour.
- EPS and SVG vector outputs are generated from the same code.

## Figure 2

**Alternative text:** Four district maps of Rwanda labelled a through d. Panel a shows 2023 annual CHIRPS rainfall, panel b shows 2023 mean ERA5-Land temperature, panel c shows 2023 mean MODIS NDVI, and panel d shows the percentage of each district represented by HAND values at or below 5 metres. Each map contains six numeric intervals and district boundaries.

**Accessibility checks:**

- Panel identity is encoded by letters and the manuscript caption.
- Each legend contains the variable name, units where applicable, and numeric intervals.
- The Cividis palette has monotonic luminance and remains ordered in greyscale.
- Numeric intervals provide non-colour interpretation of the class ranges.
- The four-panel combination is generated as a 600 dpi TIFF; each panel is also generated as SVG and EPS.
- The HAND panel is described as terrain share, not flood extent or probability.

## Figure 3

**Alternative text:** Three-column decision diagram showing independent provenance controls. Register validation checks required fields, legal class values, and rejects the combination of source-derived evidence with a placeholder method. Display classification treats an output as illustrative unless its identifier is present and its evidence class is exactly source-derived; this step does not test method class or independently verify real-data use. Illustrative-note selection returns no note for a source-derived display, a short “illustrative” label when requested, one full note for a documented method on synthetic data, and another full note for synthetic, placeholder, unknown, or incomplete material. A footer states that the three functions are independently callable.

**Accessibility checks:**

- The diagram is unfilled black line art and does not rely on colour.
- Each control is identified by number, title, and function name.
- Decision branches are labelled yes or no.
- A footer explicitly prevents interpretation of register validity as a prerequisite for the other functions.
- SVG and EPS vector outputs are generated from the same code.

## Supplementary Figure S1

**Alternative text:** Multi-line profile chart of standardized rainfall, temperature, NDVI, and HAND-share values for 30 Rwanda districts ordered by the first principal component. The four variables use different point symbols and line types. Values above and below zero indicate district values above and below each layer's national mean; the chart is not a composite score.

**Accessibility checks:**

- All four series are black and differentiated by both symbols and line types.
- A horizontal zero reference line is shown.
- District labels are printed on the horizontal axis.
- The plot is generated as 600 dpi TIFF and EPS.
- The caption explicitly rejects interpretation as a hazard, epidemiological, or causal index.

## Final Word-file checks

1. Insert meaningful alternative text, not the file name.
2. Mark decorative objects, if any, as decorative; no current figure is decorative.
3. Confirm reading order after figure placement.
4. Confirm that panel letters, legends, and district labels remain legible at final journal size.
5. Check contrast in colour and greyscale PDF rendering.
6. Ensure captions remain editable text outside the images.
