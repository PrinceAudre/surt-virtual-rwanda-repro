#!/usr/bin/env Rscript
# Geometry-agnostic fixture for the generic transformation functions.
# This deliberately uses arbitrary administrative identifiers and projected
# geometry outside Rwanda. Rwanda-specific directional gates are not invoked.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

file_arg <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
here <- dirname(normalizePath(file_arg, winslash = "/", mustWork = TRUE))

source(file.path(here, "relief_rainfall_transform.R"))
source(file.path(here, "relief_temp_transform.R"))
source(file.path(here, "relief_ndvi_transform.R"))
source(file.path(here, "relief_low_lying_transform.R"))

passed <- 0L
check <- function(label, condition) {
  if (!isTRUE(condition)) stop(sprintf("[FAIL] %s", label), call. = FALSE)
  passed <<- passed + 1L
  cat(sprintf("[PASS] %s\n", label))
}

square <- function(xmin, xmax, ymin = 0, ymax = 100000) {
  st_polygon(list(matrix(
    c(xmin, ymin, xmax, ymin, xmax, ymax, xmin, ymax, xmin, ymin),
    ncol = 2, byrow = TRUE
  )))
}

# Arbitrary identifiers and a projected metric CRS demonstrate that the core
# zonal transformations do not depend on Rwanda names or longitude-based gates.
admin <- st_sf(
  admin_id = c("ALPHA-01", "BETA-02", "GAMMA-03"),
  geometry = st_sfc(
    square(0, 100000),
    square(100000, 200000),
    square(200000, 300000),
    crs = 3857
  )
)

template <- rast(
  xmin = 0, xmax = 300000, ymin = 0, ymax = 100000,
  ncols = 6, nrows = 2, crs = "EPSG:3857"
)
x <- crds(template, df = TRUE)$x

rain <- setValues(template, ifelse(x < 100000, 700, ifelse(x < 200000, 1100, 1500)))
rain_values <- rainfall_district_means(rain, admin)
check("arbitrary administrative identifiers are preserved",
      identical(admin$admin_id, c("ALPHA-01", "BETA-02", "GAMMA-03")))
check("rainfall aggregation works with projected non-Rwanda geometry",
      identical(as.numeric(rain_values), c(700, 1100, 1500)))

temperature <- setValues(template, ifelse(x < 100000, 12.5, ifelse(x < 200000, 18.5, 24.5)))
temp_values <- temp_district_means(temperature, admin)
check("temperature aggregation is independent of Rwanda district names",
      identical(as.numeric(temp_values), c(12.5, 18.5, 24.5)))

hand <- setValues(template, ifelse(x < 100000, 2, ifelse(x < 200000, rep(c(2, 8), 2), 9)))
hand_values <- low_lying_share(hand, admin, threshold_m = 5)
check("HAND threshold aggregation works with projected arbitrary polygons",
      identical(as.numeric(hand_values), c(100, 50, 0)))

# Exercise the generic MODIS scale/mosaic/temporal/reprojection path and extract
# it against the same arbitrary units after transforming those polygons to 4326.
admin_4326 <- st_transform(admin, 4326)
modis_sinu <- "+proj=sinu +R=6371007.181 +units=m +no_defs"
lonlat_template <- rast(
  xmin = xmin(vect(admin_4326)), xmax = xmax(vect(admin_4326)),
  ymin = ymin(vect(admin_4326)), ymax = ymax(vect(admin_4326)),
  ncols = 120, nrows = 40, crs = "EPSG:4326"
)
lon <- crds(lonlat_template, df = TRUE)$x
cut_1 <- quantile(lon, 1 / 3)
cut_2 <- quantile(lon, 2 / 3)
raw_1 <- setValues(lonlat_template, ifelse(lon < cut_1, 4000, ifelse(lon < cut_2, 6000, 8000)))
raw_2 <- setValues(lonlat_template, ifelse(lon < cut_1, 5000, ifelse(lon < cut_2, 7000, 9000)))
sinu_template <- project(lonlat_template, modis_sinu, method = "near")
month_raster <- function(raw) project(raw, sinu_template, method = "near")
sinu_1 <- month_raster(raw_1)
sinu_2 <- month_raster(raw_2)
sinu_x <- init(sinu_1, "x")
seam <- mean(c(xmin(sinu_1), xmax(sinu_1)))
ndvi <- ndvi_annual_mean_4326(list(
  list(month = "M01", r = ifel(sinu_x <= seam, sinu_1, NA)),
  list(month = "M01", r = ifel(sinu_x > seam, sinu_1, NA)),
  list(month = "M02", r = ifel(sinu_x <= seam, sinu_2, NA)),
  list(month = "M02", r = ifel(sinu_x > seam, sinu_2, NA))
))
ndvi_assert_raster_scale(ndvi)
ndvi_values <- exactextractr::exact_extract(ndvi, admin_4326, "mean", progress = FALSE)
check("MODIS transformation covers arbitrary administrative geometry",
      length(ndvi_values) == 3L && all(is.finite(ndvi_values)) &&
        all(ndvi_values > 0.35 & ndvi_values < 0.95))

check("portability fixture uses no Rwanda district identifiers",
      !any(admin$admin_id %in% c("Nyarugenge", "Gasabo", "Nyagatare", "Nyamasheke")))

cat(sprintf("\n=== geometry-agnostic portability fixture: %d passed, 0 failed ===\n", passed))
