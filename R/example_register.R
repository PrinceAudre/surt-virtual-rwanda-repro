# example_register.R
# ---------------------------------------------------------------------
# ILLUSTRATIVE SCHEMA EXAMPLE ONLY. This is NOT SuRT-Virtual Rwanda's application
# register. It exists solely to demonstrate the value-class functions in
# provenance_value_class.R against the register schema described in the paper.
#
# It contains two entries: one "source-derived" + "documented" (a real climate layer produced by a
# real method on real public data), and one "illustrative" + "placeholder" (a synthetic
# disease-side signal). The application's real register, and its operational-adjacent
# outputs, are not included in this reduced public artifact.
# ---------------------------------------------------------------------
example_register <- function() {
  list(
    list(id = "climate_temperature_layer",
         display = "Per-district temperature (real climate layer)",
         method  = "Area-mean aggregation of ERA5-Land 2m temperature (monthly-mean 2023) to each of Rwanda's 30 district polygons.",
         palette = "viridis (colourblind-safe, perceptually uniform)",
         evidence_class = "source-derived",
         method_class = "documented",
         citation = "Data: ERA5-Land (Copernicus Climate Data Store), Copernicus licence; Munoz-Sabater et al., Earth Syst Sci Data 13:4349-4383 (2021), doi:10.5194/essd-13-4349-2021. Boundaries: World Bank 'Rwanda Admin Boundaries and Villages', CC BY 4.0. Palette: viridis; colourblind-safe per Wong 2011, Nat Methods 8:441."),
    list(id = "synthetic_disease_signal",
         display = "Per-district disease-side signal (synthetic, illustrative)",
         method  = "Synthetic, seeded demonstration signal. Not real surveillance data, not a forecast, and not a validated indicator; present only to exercise the framework.",
         palette = "n/a (numeric illustrative index)",
         evidence_class = "illustrative",
         method_class = "placeholder",
         citation = "No method to cite - synthetic demonstration signal. Presenting a synthetic value as a real finding is exactly what the value-class discipline prevents.")
  )
}
