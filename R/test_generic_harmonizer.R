#!/usr/bin/env Rscript
# Account-free end-to-end test of the public generic input contract.
# It creates a projected raster and arbitrary polygon units, invokes the same
# interface documented for users, and validates the written WGS84 GeoJSON.

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

square <- function(xmin, xmax, ymin = 0, ymax = 2000) {
  st_polygon(list(matrix(
    c(xmin, ymin, xmax, ymin, xmax, ymax, xmin, ymax, xmin, ymin),
    ncol = 2, byrow = TRUE
  )))
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
st_write(units, boundary_path, driver = "GeoJSON", quiet = TRUE)

result <- harmonize_admin_raster(
  raster_path = raster_path,
  boundary_path = boundary_path,
  id_field = "admin_code",
  value_name = "environment_mean",
  output_path = output_path,
  provenance = "Synthetic projected example; deterministic fixture; not source-derived evidence",
  round_digits = 1L,
  min_value = 0,
  max_value = 100
)

reserved_name_rejected <- tryCatch({
  harmonize_admin_raster(
    raster_path = raster_path,
    boundary_path = boundary_path,
    id_field = "admin_code",
    value_name = "provenance",
    output_path = file.path(work, "reserved.geojson"),
    provenance = "Synthetic fixture"
  )
  FALSE
}, error = function(error) grepl("reserved", conditionMessage(error), fixed = TRUE))

geometry_id_rejected <- tryCatch({
  harmonize_admin_raster(
    raster_path = raster_path,
    boundary_path = boundary_path,
    id_field = "geometry",
    value_name = "environment_mean",
    output_path = file.path(work, "geometry-id.geojson"),
    provenance = "Synthetic fixture"
  )
  FALSE
}, error = function(error) grepl("non-geometry", conditionMessage(error), fixed = TRUE))

written <- st_read(output_path, quiet = TRUE)
check("generic interface writes one feature per arbitrary unit", nrow(written) == 3L)
check("generic interface preserves arbitrary identifiers",
      identical(as.character(written$unit_id), c("ALPHA-01", "BETA-02", "GAMMA-03")))
check("coverage-weighted means match controlled raster values",
      identical(as.numeric(written$environment_mean), c(10, 20, 30)))
check("output contract contains only identifier, value, provenance and geometry",
      identical(names(written), c("unit_id", "environment_mean", "provenance", "geometry")))
check("output GeoJSON is normalized to WGS84", identical(st_crs(written)$epsg, 4326L))
check("provenance is present for every feature",
      all(nzchar(written$provenance)) && length(unique(written$provenance)) == 1L)
check("sourceable interface returns output and rejects schema collisions",
      nrow(result) == 3L && reserved_name_rejected && geometry_id_rejected)

cat(sprintf("\n=== generic administrative harmonizer: %d passed, 0 failed ===\n", passed))
