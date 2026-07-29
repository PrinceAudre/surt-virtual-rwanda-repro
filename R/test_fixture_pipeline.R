#!/usr/bin/env Rscript
# Hermetic test of the released zonal-summary transforms. The raster values are
# synthetic fixtures created in memory; no network account, private repository,
# or external data download is required.
suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

file_arg <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
here <- dirname(normalizePath(file_arg, winslash = "/", mustWork = TRUE))
root <- normalizePath(file.path(here, ".."), winslash = "/", mustWork = TRUE)

source(file.path(here, "relief_rainfall_transform.R"))
source(file.path(here, "relief_temp_transform.R"))
source(file.path(here, "relief_ndvi_transform.R"))
source(file.path(here, "relief_low_lying_transform.R"))

stop_if_not <- function(label, condition) {
  if (!isTRUE(condition)) stop(sprintf("[FAIL] %s", label), call. = FALSE)
  cat(sprintf("[PASS] %s\n", label))
}

square <- function(xmin, xmax, ymin = -2, ymax = -1) {
  st_polygon(list(matrix(
    c(xmin, ymin, xmax, ymin, xmax, ymax, xmin, ymax, xmin, ymin),
    ncol = 2, byrow = TRUE
  )))
}

districts <- st_sf(
  district = c("Nyamasheke", "Huye", "Nyagatare"),
  geometry = st_sfc(
    square(29, 30), square(30, 31), square(31, 32),
    crs = 4326
  )
)

template <- rast(
  xmin = 29, xmax = 32, ymin = -2, ymax = -1,
  ncols = 6, nrows = 2, crs = "EPSG:4326"
)
x <- crds(template, df = TRUE)$x

rainfall <- setValues(template, ifelse(x < 30, 1500, ifelse(x < 31, 1100, 800)))
rain_values <- rainfall_district_means(rainfall, districts)
rain_gate <- rainfall_consistency_gate(
  districts$district, rain_values, rainfall_district_lon(districts)
)
stop_if_not("rainfall zonal means match fixture", identical(as.numeric(rain_values), c(1500, 1100, 800)))
stop_if_not("rainfall west-to-east consistency gate passes", rain_gate[["west"]] > rain_gate[["east"]])

temperature <- setValues(template, ifelse(x < 30, 17, ifelse(x < 31, 19.5, 22)))
temp_values <- temp_district_means(temperature, districts)
temp_gate <- temp_consistency_gate(
  districts$district, temp_values, temp_district_lon(districts)
)
stop_if_not("temperature zonal means match fixture", identical(as.numeric(temp_values), c(17, 19.5, 22)))
stop_if_not("temperature west-to-east consistency gate passes", temp_gate[["west"]] < temp_gate[["east"]])

hand <- setValues(template, ifelse(x < 30, 12, ifelse(x < 31, rep(c(3, 8), 2), 2)))
low_values <- low_lying_share(hand, districts, threshold_m = 5)
low_gate <- low_lying_consistency_gate(
  districts$district, low_values, low_lying_district_lon(districts)
)
stop_if_not("HAND threshold returns bounded low-lying shares",
            all(low_values >= 0 & low_values <= 100))
stop_if_not("low-lying share west-to-east consistency gate passes",
            low_gate[["east"]] > low_gate[["west"]])

ndvi_raw <- setValues(template, ifelse(x < 30, 7000, ifelse(x < 31, 6000, 5000)))
ndvi <- ndvi_scale_mask_mod13a3(ndvi_raw)
ndvi_assert_raster_scale(ndvi)
ndvi_values <- round(exactextractr::exact_extract(ndvi, districts, "mean", progress = FALSE), 2)
ndvi_consistency_gate(
  districts$district, ndvi_values,
  west_forest = "Nyamasheke", east_savanna = "Nyagatare"
)
stop_if_not("MODIS scale and mask transform returns physical NDVI",
            identical(as.numeric(ndvi_values), c(0.7, 0.6, 0.5)))

out_arg <- commandArgs(trailingOnly = TRUE)
out <- if (length(out_arg) && nzchar(out_arg[1])) out_arg[1] else
  file.path(root, "generated", "fixture_pipeline_output.geojson")
dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
fixture_out <- districts
fixture_out$annual_rainfall_mm <- rain_values
fixture_out$mean_temp_c <- temp_values
fixture_out$mean_ndvi <- ndvi_values
fixture_out$low_lying_share_pct <- low_values
st_write(fixture_out, out, delete_dsn = TRUE, quiet = TRUE)

stop_if_not("fixture output GeoJSON was written", file.exists(out))
cat(sprintf("\n=== fixture pipeline: 8 passed, 0 failed; output %s ===\n", out))
