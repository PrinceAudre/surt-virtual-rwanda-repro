#!/usr/bin/env Rscript
# Array E2: quantify the runtime and R-heap cost of SuRT's support contract
# relative to a direct area-weighted zonal-mean primitive using the same
# terra/exactextractr stack. This benchmark does not test superiority.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

file_arg <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
here <- dirname(normalizePath(file_arg, winslash = "/", mustWork = TRUE))
source(file.path(here, "zonal_area_summary.R"))

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (!length(idx)) return(default)
  if (idx[[1]] == length(args)) stop(sprintf("Missing value after %s", flag), call. = FALSE)
  args[[idx[[1]] + 1L]]
}

repetitions <- as.integer(get_arg("--repetitions", "3"))
if (!is.finite(repetitions) || repetitions < 1L) stop("--repetitions must be a positive integer")
output_path <- get_arg("--output", "")

rect_polygon <- function(xmin, xmax, ymin, ymax, crs) {
  sf::st_sfc(sf::st_polygon(list(matrix(c(
    xmin, ymin,
    xmax, ymin,
    xmax, ymax,
    xmin, ymax,
    xmin, ymin
  ), ncol = 2, byrow = TRUE))), crs = crs)
}

make_fixture <- function(ncells_side, polygon_side) {
  extent_max <- 100000
  r <- terra::rast(
    xmin = 0, xmax = extent_max, ymin = 0, ymax = extent_max,
    ncols = ncells_side, nrows = ncells_side, crs = "EPSG:3857"
  )
  idx <- seq_len(terra::ncell(r))
  values <- ((idx * 17L) %% 997L) / 10
  values[idx %% 13L == 0L] <- NA_real_
  terra::values(r) <- values

  frame <- sf::st_sf(
    geometry = rect_polygon(0, extent_max, 0, extent_max, 3857)
  )
  grid <- sf::st_make_grid(frame, n = c(polygon_side, polygon_side), what = "polygons")
  polygons <- sf::st_sf(
    unit_id = sprintf("U%04d", seq_along(grid)),
    geometry = grid
  )
  list(raster = r, polygons = polygons)
}

# Direct baseline: same cell-area and exact-extraction primitives, but returns
# only the finite-value area-weighted mean. It deliberately omits raster-footprint
# coverage, within-footprint finite-data coverage, overall valid-data coverage,
# output schema/provenance, and higher-level release checks.
direct_area_weighted_mean <- function(raster, polygons) {
  raster_crs <- sf::st_crs(terra::crs(raster, proj = TRUE))
  transformed <- sf::st_transform(polygons, raster_crs)
  cell_area <- terra::cellSize(raster, mask = FALSE, unit = "m", transform = TRUE)
  result <- exactextractr::exact_extract(
    raster,
    transformed,
    weights = cell_area,
    fun = function(values, coverage_fraction, weights) {
      touched <- is.finite(coverage_fraction) & coverage_fraction > 0 &
        is.finite(weights) & weights > 0
      if (!any(touched)) return(NA_real_)
      values <- values[touched]
      area_weights <- coverage_fraction[touched] * weights[touched]
      valid <- is.finite(values)
      if (!any(valid)) return(NA_real_)
      valid_area <- sum(area_weights[valid])
      if (!is.finite(valid_area) || valid_area <= 0) return(NA_real_)
      sum(values[valid] * area_weights[valid]) / valid_area
    },
    progress = FALSE
  )
  as.numeric(result)
}

measure_once <- function(fun) {
  invisible(gc())
  invisible(gc(reset = TRUE))
  started <- proc.time()
  result <- fun()
  elapsed <- as.numeric((proc.time() - started)[["elapsed"]])
  gc_stats <- gc()
  # gc() columns are used, Mb, gc trigger, Mb, max used, Mb. The sixth
  # column is the high-water mark in MB for Ncells and Vcells. This is an
  # R-heap indicator, not total operating-system resident set size.
  heap_high_water_mb <- sum(gc_stats[, 6], na.rm = TRUE)
  list(result = result, elapsed_s = elapsed, heap_high_water_mb = heap_high_water_mb)
}

scenarios <- data.frame(
  scenario = c("small", "medium", "large"),
  raster_side = c(100L, 300L, 600L),
  polygon_side = c(4L, 8L, 12L),
  stringsAsFactors = FALSE
)

rows <- list()
row_idx <- 0L

for (i in seq_len(nrow(scenarios))) {
  sc <- scenarios[i, ]
  fixture <- make_fixture(sc$raster_side, sc$polygon_side)

  # Warm both code paths before timed repetitions.
  baseline_warm <- direct_area_weighted_mean(fixture$raster, fixture$polygons)
  contract_warm <- surt_area_weighted_summary(fixture$raster, fixture$polygons)
  if (length(baseline_warm) != nrow(contract_warm) ||
      max(abs(baseline_warm - contract_warm$value), na.rm = TRUE) > 1e-9) {
    stop(sprintf("Baseline/contract mismatch in %s warm-up", sc$scenario), call. = FALSE)
  }
  rm(baseline_warm, contract_warm)
  invisible(gc())

  for (rep in seq_len(repetitions)) {
    baseline <- measure_once(function() direct_area_weighted_mean(fixture$raster, fixture$polygons))
    contract <- measure_once(function() surt_area_weighted_summary(fixture$raster, fixture$polygons))

    max_diff <- max(abs(baseline$result - contract$result$value), na.rm = TRUE)
    if (!is.finite(max_diff) || max_diff > 1e-9) {
      stop(sprintf("Baseline/contract result mismatch in %s repetition %d", sc$scenario, rep), call. = FALSE)
    }

    for (entry in list(
      list(mode = "direct_mean", measurement = baseline),
      list(mode = "surt_support_contract", measurement = contract)
    )) {
      row_idx <- row_idx + 1L
      rows[[row_idx]] <- data.frame(
        scenario = sc$scenario,
        raster_side = sc$raster_side,
        raster_cells = sc$raster_side * sc$raster_side,
        polygon_count = sc$polygon_side * sc$polygon_side,
        repetition = rep,
        mode = entry$mode,
        elapsed_s = entry$measurement$elapsed_s,
        r_heap_high_water_mb = entry$measurement$heap_high_water_mb,
        max_value_difference_vs_peer = max_diff,
        stringsAsFactors = FALSE
      )
    }
    rm(baseline, contract)
  }
  rm(fixture)
  invisible(gc())
}

raw <- do.call(rbind, rows)
summary_rows <- do.call(rbind, lapply(split(raw, interaction(raw$scenario, raw$mode, drop = TRUE)), function(x) {
  data.frame(
    scenario = x$scenario[[1]],
    raster_cells = x$raster_cells[[1]],
    polygon_count = x$polygon_count[[1]],
    mode = x$mode[[1]],
    median_elapsed_s = median(x$elapsed_s),
    max_r_heap_high_water_mb = max(x$r_heap_high_water_mb),
    max_value_difference_vs_peer = max(x$max_value_difference_vs_peer),
    stringsAsFactors = FALSE
  )
}))
rownames(summary_rows) <- NULL
summary_rows <- summary_rows[order(match(summary_rows$scenario, scenarios$scenario), summary_rows$mode), ]

cat("Array cost-of-auditability benchmark summary\n")
print(summary_rows, row.names = FALSE, digits = 6)
cat("\nMemory note: r_heap_high_water_mb is the R garbage-collector heap high-water indicator, not total process RSS.\n")

if (nzchar(output_path)) {
  dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
  write.csv(raw, output_path, row.names = FALSE)
  summary_path <- sub("\\.csv$", "_summary.csv", output_path, ignore.case = TRUE)
  if (identical(summary_path, output_path)) summary_path <- paste0(output_path, ".summary.csv")
  write.csv(summary_rows, summary_path, row.names = FALSE)
  cat(sprintf("\nWrote raw benchmark: %s\n", output_path))
  cat(sprintf("Wrote benchmark summary: %s\n", summary_path))
}
