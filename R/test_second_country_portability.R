#!/usr/bin/env Rscript
# Real second-country boundary portability smoke test.
#
# The Uganda polygon is source-derived from Natural Earth 1:110m Admin 0 data.
# The raster signal is synthetic and deterministic. This test therefore
# demonstrates cross-country geometry/identifier portability only; it is not
# validation of an environmental product or of scientific results for Uganda.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

file_arg <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
here <- dirname(normalizePath(file_arg, winslash = "/", mustWork = TRUE))
root <- normalizePath(file.path(here, ".."), winslash = "/", mustWork = TRUE)
source(file.path(here, "harmonize_admin_raster.R"))

passed <- 0L
check <- function(label, condition) {
  if (!isTRUE(condition)) stop(sprintf("[FAIL] %s", label), call. = FALSE)
  passed <<- passed + 1L
  cat(sprintf("[PASS] %s\n", label))
}

boundary_path <- file.path(root, "fixtures", "uganda_natural_earth_110m.geojson")
output_path <- file.path(root, "generated", "uganda_portability_example.geojson")
work <- tempfile("surt-uganda-portability-")
dir.create(work, recursive = TRUE)
raster_path <- file.path(work, "synthetic_signal.tif")

uganda <- st_read(boundary_path, quiet = TRUE, stringsAsFactors = FALSE)
check("Uganda fixture contains one real second-country administrative geometry",
      nrow(uganda) == 1L && identical(as.character(uganda$iso_a3), "UGA"))
check("Uganda source fixture is valid WGS84 polygon geometry",
      identical(st_crs(uganda)$epsg, 4326L) &&
        all(st_geometry_type(uganda) %in% c("POLYGON", "MULTIPOLYGON")) &&
        all(st_is_valid(uganda)))
check("Uganda fixture records Natural Earth public-domain source metadata",
      identical(as.character(uganda$source_dataset),
                "Natural Earth 1:110m Admin 0 - Countries") &&
        identical(as.character(uganda$source_terms), "Public domain"))

# A deterministic synthetic raster covers the Uganda source geometry. Its only
# purpose is to exercise the generic harmonizer against a real non-Rwanda
# polygon while keeping this CI gate account-free and hermetic.
r <- rast(xmin = 29, xmax = 36, ymin = -2, ymax = 5,
          ncols = 28, nrows = 28, crs = "EPSG:4326")
xy <- crds(r, df = TRUE)
values(r) <- 50 + xy$x + 2 * xy$y
writeRaster(r, raster_path, overwrite = TRUE)

provenance <- paste(
  "Uganda boundary: Natural Earth 1:110m Admin 0 - Countries, public domain;",
  "environmental signal: deterministic synthetic portability fixture, not source-derived evidence"
)

result <- harmonize_admin_raster(
  raster_path = raster_path,
  boundary_path = boundary_path,
  id_field = "iso_a3",
  value_name = "synthetic_signal_mean",
  output_path = output_path,
  provenance = provenance,
  min_valid_fraction = 0.999999,
  min_value = 70,
  max_value = 100,
  round_digits = 6L
)

written <- st_read(output_path, quiet = TRUE, stringsAsFactors = FALSE)
check("real-country portability run preserves the Uganda identifier",
      nrow(written) == 1L && identical(as.character(written$unit_id), "UGA"))
check("real-country portability run reports complete raster support",
      abs(written$raster_coverage_fraction[[1]] - 1) < 1e-9 &&
        abs(written$valid_within_raster_fraction[[1]] - 1) < 1e-9 &&
        abs(written$valid_data_fraction[[1]] - 1) < 1e-9)
check("real-country portability run returns a finite bounded synthetic mean",
      is.finite(written$synthetic_signal_mean[[1]]) &&
        written$synthetic_signal_mean[[1]] >= 70 &&
        written$synthetic_signal_mean[[1]] <= 100)
check("real-country portability output preserves the source geography",
      isTRUE(st_equals(st_geometry(written), st_geometry(uganda), sparse = FALSE)[1, 1]))
check("real-country portability provenance distinguishes real boundary from synthetic raster",
      grepl("Natural Earth", written$provenance[[1]], fixed = TRUE) &&
        grepl("synthetic", written$provenance[[1]], ignore.case = TRUE) &&
        grepl("not source-derived evidence", written$provenance[[1]], fixed = TRUE))
check("sourceable generic interface returns the Uganda output",
      nrow(result) == 1L && identical(as.character(result$unit_id), "UGA"))

cat(sprintf(
  "\n=== real second-country boundary portability: %d passed, 0 failed ===\n",
  passed
))
