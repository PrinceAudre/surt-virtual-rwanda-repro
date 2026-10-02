#!/usr/bin/env Rscript
# Create deterministic synthetic inputs for the account-free Snakemake workflow.
# These fixtures verify orchestration and contracts only. They are not real data.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
}))

args <- commandArgs(trailingOnly = TRUE)
out_dir <- if (length(args) >= 1L && nzchar(args[[1]])) args[[1]] else
  file.path("generated", "workflow_demo")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

raw_path <- file.path(out_dir, "raw_multilayer.tif")
boundary_path <- file.path(out_dir, "units.geojson")

r <- terra::rast(
  xmin = 0, xmax = 3000, ymin = 0, ymax = 1000,
  ncols = 6, nrows = 1, nlyrs = 2, crs = "EPSG:3857"
)
terra::values(r[[1]]) <- c(100, 200, 300, 400, 500, -9999)
terra::values(r[[2]]) <- c(1, 2, 3, 4, 5, 6)
names(r) <- c("demo_signal", "unused_auxiliary")
terra::writeRaster(r, raw_path, overwrite = TRUE)

rect <- function(xmin, xmax) {
  sf::st_polygon(list(matrix(c(
    xmin, 0,
    xmax, 0,
    xmax, 1000,
    xmin, 1000,
    xmin, 0
  ), ncol = 2, byrow = TRUE)))
}

units <- sf::st_sf(
  unit_code = c("ALPHA-01", "BETA-02", "GAMMA-03"),
  geometry = sf::st_sfc(
    rect(0, 1000), rect(1000, 2000), rect(2000, 3000),
    crs = 3857
  )
)
if (file.exists(boundary_path)) file.remove(boundary_path)
sf::st_write(units, boundary_path, quiet = TRUE)

if (!file.exists(raw_path) || file.size(raw_path) <= 0) {
  stop("FAIL-CLOSED: controlled raw raster fixture was not written.")
}
if (!file.exists(boundary_path) || file.size(boundary_path) <= 0) {
  stop("FAIL-CLOSED: controlled boundary fixture was not written.")
}
cat(sprintf("[PASS] workflow fixture raster -> %s\n", raw_path))
cat(sprintf("[PASS] workflow fixture boundaries -> %s\n", boundary_path))
