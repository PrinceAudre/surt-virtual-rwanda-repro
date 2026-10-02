#!/usr/bin/env Rscript
# Account-free contract tests for the public generic administrative harmonizer.
# These tests directly exercise the success and failure branches documented for
# users, including reviewer-requested spatial coverage and parser behavior.

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

expect_failure <- function(label, expression, pattern) {
  ok <- tryCatch({
    force(expression)
    FALSE
  }, error = function(error) grepl(pattern, conditionMessage(error), ignore.case = TRUE))
  check(label, ok)
}

square <- function(xmin, xmax, ymin = 0, ymax = 2000) {
  st_polygon(list(matrix(
    c(xmin, ymin, xmax, ymin, xmax, ymax, xmin, ymax, xmin, ymin),
    ncol = 2, byrow = TRUE
  )))
}

write_units <- function(object, path) {
  suppressWarnings(st_write(object, path, quiet = TRUE, delete_dsn = TRUE))
  path
}

run_harmonizer <- function(raster_file, boundary_file, out_file, ...) {
  harmonize_admin_raster(
    raster_path = raster_file,
    boundary_path = boundary_file,
    id_field = "admin_code",
    value_name = "environment_mean",
    output_path = out_file,
    provenance = "Synthetic deterministic contract fixture; not source-derived evidence",
    ...
  )
}

work <- tempfile("surt-generic-")
dir.create(work, recursive = TRUE)
raster_path <- file.path(work, "environment.tif")
boundary_path <- file.path(work, "units.geojson")
output_path <- file.path(root, "generated", "generic_admin_example.geojson")

r <- rast(xmin = 0, xmax = 3000, ymin = 0, ymax = 2000,
          ncols = 3, nrows = 2, crs = "EPSG:3857")
x <- crds(r, df = TRUE)$x
values(r) <- ifelse(x < 1000, 10, ifelse(x < 2000, 20, 30))
writeRaster(r, raster_path, overwrite = TRUE)

units <- st_sf(
  admin_code = c("ALPHA-01", "BETA-02", "GAMMA-03"),
  geometry = st_sfc(
    square(0, 1000),
    square(1000, 2000),
    square(2000, 3000),
    crs = 3857
  )
)
write_units(units, boundary_path)

result <- run_harmonizer(
  raster_path, boundary_path, output_path,
  round_digits = 1L,
  min_value = 0,
  max_value = 100,
  min_valid_fraction = 1
)
written <- st_read(output_path, quiet = TRUE)

check("generic interface writes one feature per arbitrary unit", nrow(written) == 3L)
check("generic interface preserves arbitrary identifiers",
      identical(as.character(written$unit_id), c("ALPHA-01", "BETA-02", "GAMMA-03")))
check("surface-area-weighted means match controlled raster values",
      max(abs(as.numeric(written$environment_mean) - c(10, 20, 30))) < 1e-9)
check("output contract reports all three coverage quantities",
      all(c("raster_coverage_fraction", "valid_within_raster_fraction", "valid_data_fraction") %in%
            names(written)))
check("complete fixture reports complete valid-data coverage",
      all(abs(written$valid_data_fraction - 1) < 1e-9))
check("output GeoJSON is normalized to WGS84", identical(st_crs(written)$epsg, 4326L))
check("provenance is present for every feature",
      all(nzchar(written$provenance)) && length(unique(written$provenance)) == 1L)
check("sourceable interface returns the written output", nrow(result) == 3L)

# Layer selection by numeric index and by layer name.
r_multi <- c(r, r + 100)
names(r_multi) <- c("base_layer", "shifted_layer")
multi_path <- file.path(work, "multi.tif")
writeRaster(r_multi, multi_path, overwrite = TRUE)
by_index <- run_harmonizer(multi_path, boundary_path, file.path(work, "layer-index.geojson"), layer = 2L)
by_name <- run_harmonizer(multi_path, boundary_path, file.path(work, "layer-name.geojson"), layer = "shifted_layer")
check("layer selection by integer index uses the requested raster layer",
      max(abs(as.numeric(by_index$environment_mean) - c(110, 120, 130))) < 1e-9)
check("layer selection by layer name matches index selection",
      max(abs(by_name$environment_mean - by_index$environment_mean)) < 1e-9)
expect_failure("non-integer numeric layer indices are rejected",
               run_harmonizer(multi_path, boundary_path, file.path(work, "bad-layer.geojson"), layer = 1.5),
               "layer index must be an integer")

# Scale and offset are applied after source-value masking. GeoTIFF I/O and
# geospatial weighted summaries are floating-point operations, so assert the
# mathematically expected values with a tight numeric tolerance rather than
# bitwise identity.
scaled <- run_harmonizer(
  raster_path, boundary_path, file.path(work, "scaled.geojson"),
  scale = 2, offset = 1
)
check("scale and offset are applied to the selected source layer",
      max(abs(as.numeric(scaled$environment_mean) - c(21, 41, 61))) < 1e-9)

threshold_raster <- r
values(threshold_raster) <- ifelse(x < 1000, -9999, ifelse(x < 2000, 10, 20))
threshold_path <- file.path(work, "threshold.tif")
writeRaster(threshold_raster, threshold_path, overwrite = TRUE)
all_units <- st_sf(admin_code = "ALL", geometry = st_sfc(square(0, 3000), crs = 3857))
all_units_path <- file.path(work, "all-units.geojson")
write_units(all_units, all_units_path)
masked_below <- run_harmonizer(
  threshold_path, all_units_path, file.path(work, "masked-below.geojson"),
  na_below = 0, scale = 2, offset = 1
)
check("na_below masks raw source values before scale and offset",
      abs(masked_below$environment_mean - 31) < 1e-6)
masked_both <- run_harmonizer(
  threshold_path, all_units_path, file.path(work, "masked-both.geojson"),
  na_below = 0, na_above = 15, scale = 2, offset = 1
)
check("na_above also operates in raw source-value units",
      abs(masked_both$environment_mean - 21) < 1e-6)

# Partial valid-data coverage remains visible and can be gated.
partial <- rast(xmin = 0, xmax = 2000, ymin = 0, ymax = 1000,
                ncols = 2, nrows = 1, crs = "EPSG:3857")
values(partial) <- c(10, NA)
partial_path <- file.path(work, "partial.tif")
writeRaster(partial, partial_path, overwrite = TRUE)
partial_units <- st_sf(admin_code = "PARTIAL", geometry = st_sfc(square(0, 2000, 0, 1000), crs = 3857))
partial_units_path <- file.path(work, "partial-units.geojson")
write_units(partial_units, partial_units_path)
partial_result <- run_harmonizer(
  partial_path, partial_units_path, file.path(work, "partial-out.geojson"),
  min_valid_fraction = 0
)
check("partial finite coverage is reported instead of silently treated as complete",
      abs(partial_result$valid_data_fraction - 0.5) < 1e-9)
expect_failure("minimum valid-data fraction fails closed when coverage is insufficient",
               run_harmonizer(
                 partial_path, partial_units_path, file.path(work, "partial-gated.geojson"),
                 min_valid_fraction = 0.75
               ),
               "valid-data fraction below minimum")

all_na <- partial
values(all_na) <- NA_real_
all_na_path <- file.path(work, "all-na.tif")
writeRaster(all_na, all_na_path, overwrite = TRUE)
expect_failure("full no-data polygons fail closed",
               run_harmonizer(all_na_path, partial_units_path, file.path(work, "all-na.geojson")),
               "no finite raster value")

# Identifier, schema, geometry, and CRS failures.
expect_failure("reserved output names are rejected",
               harmonize_admin_raster(
                 raster_path, boundary_path, "admin_code", "valid_data_fraction",
                 file.path(work, "reserved.geojson"), "Synthetic fixture"
               ),
               "reserved")
expect_failure("geometry cannot be selected as the identifier",
               harmonize_admin_raster(
                 raster_path, boundary_path, "geometry", "environment_mean",
                 file.path(work, "geometry-id.geojson"), "Synthetic fixture"
               ),
               "non-geometry")

duplicate_units <- units
duplicate_units$admin_code <- c("DUP", "DUP", "OTHER")
duplicate_path <- file.path(work, "duplicate.geojson")
write_units(duplicate_units, duplicate_path)
expect_failure("duplicated administrative identifiers are rejected",
               run_harmonizer(raster_path, duplicate_path, file.path(work, "duplicate-out.geojson")),
               "identifiers must be unique")

empty_units <- units
empty_units$admin_code[2] <- " "
empty_path <- file.path(work, "empty-id.geojson")
write_units(empty_units, empty_path)
expect_failure("empty administrative identifiers are rejected",
               run_harmonizer(raster_path, empty_path, file.path(work, "empty-out.geojson")),
               "identifiers must be non-empty")

point_units <- st_sf(admin_code = "POINT", geometry = st_sfc(st_point(c(500, 500)), crs = 3857))
point_path <- file.path(work, "point.geojson")
write_units(point_units, point_path)
expect_failure("non-polygon boundary geometry is rejected",
               run_harmonizer(raster_path, point_path, file.path(work, "point-out.geojson")),
               "polygons or multipolygons")

bowtie <- st_polygon(list(matrix(c(
  0, 0,
  1000, 1000,
  0, 1000,
  1000, 0,
  0, 0
), ncol = 2, byrow = TRUE)))
invalid_units <- st_sf(admin_code = "INVALID", geometry = st_sfc(bowtie, crs = 3857))
invalid_path <- file.path(work, "invalid.geojson")
write_units(invalid_units, invalid_path)
expect_failure("invalid polygon geometry is rejected",
               run_harmonizer(raster_path, invalid_path, file.path(work, "invalid-out.geojson")),
               "invalid features")

no_crs_raster <- r
crs(no_crs_raster) <- ""
no_crs_raster_path <- file.path(work, "no-crs.tif")
writeRaster(no_crs_raster, no_crs_raster_path, overwrite = TRUE)
expect_failure("missing raster CRS is rejected",
               run_harmonizer(no_crs_raster_path, boundary_path, file.path(work, "no-raster-crs.geojson")),
               "raster CRS is missing")

shp_path <- file.path(work, "no_boundary_crs.shp")
suppressWarnings(st_write(units, shp_path, quiet = TRUE, delete_dsn = TRUE))
prj_path <- sub("\\.shp$", ".prj", shp_path, ignore.case = TRUE)
if (file.exists(prj_path)) file.remove(prj_path)
expect_failure("missing boundary CRS is rejected",
               run_harmonizer(raster_path, shp_path, file.path(work, "no-boundary-crs.geojson")),
               "boundary CRS is missing")

# Bounds and parser strictness.
expect_failure("minimum output bound violations fail closed",
               run_harmonizer(raster_path, boundary_path, file.path(work, "min-fail.geojson"), min_value = 15),
               "below the minimum")
expect_failure("maximum output bound violations fail closed",
               run_harmonizer(raster_path, boundary_path, file.path(work, "max-fail.geojson"), max_value = 25),
               "above the maximum")
expect_failure("non-integer round_digits values are rejected by the public function",
               run_harmonizer(raster_path, boundary_path, file.path(work, "round-fail.geojson"), round_digits = 1.5),
               "round-digits must be an integer")
expect_failure("non-integer round-digits CLI text is rejected instead of coerced",
               as_optional_integer("1.5"),
               "expected an integer")
expect_failure("invalid minimum coverage fractions are rejected",
               run_harmonizer(raster_path, boundary_path, file.path(work, "coverage-fail.geojson"), min_valid_fraction = 1.1),
               "between 0 and 1")

cat(sprintf("\n=== generic administrative harmonizer: %d passed, 0 failed ===\n", passed))
