#!/usr/bin/env Rscript
# Explicit transform/select stage for the account-free workflow fixture.

suppressWarnings(suppressMessages(library(terra)))
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2L) {
  stop("Usage: Rscript R/transform_workflow_demo_raster.R <raw.tif> <prepared.tif> [layer_name]")
}
raw_path <- args[[1]]
out_path <- args[[2]]
layer_name <- if (length(args) >= 3L && nzchar(args[[3]])) args[[3]] else "demo_signal"

if (!file.exists(raw_path)) stop(sprintf("FAIL-CLOSED: raw workflow raster not found: %s", raw_path))
r <- terra::rast(raw_path)
if (!(layer_name %in% names(r))) {
  stop(sprintf(
    "FAIL-CLOSED: requested workflow layer %s not present; available: %s",
    layer_name, paste(names(r), collapse = ", ")
  ))
}
prepared <- r[[layer_name]]
names(prepared) <- "prepared_signal"
dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
terra::writeRaster(prepared, out_path, overwrite = TRUE)

check <- terra::rast(out_path)
if (terra::nlyr(check) != 1L || terra::ncell(check) != 6L) {
  stop("FAIL-CLOSED: prepared workflow raster violates the one-layer fixture contract.")
}
cat(sprintf("[PASS] selected %s and wrote prepared raster -> %s\n", layer_name, out_path))
