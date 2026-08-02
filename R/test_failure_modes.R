#!/usr/bin/env Rscript
# Deliberate failure injection for the transformation contract. Each malformed
# input must fail visibly for the stated reason; accepting it is a test failure.

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
expect_error_contains <- function(label, expression, expected) {
  message_text <- tryCatch({
    force(expression)
    NA_character_
  }, error = function(e) conditionMessage(e))
  if (is.na(message_text))
    stop(sprintf("[FAIL] %s: malformed input was accepted", label), call. = FALSE)
  if (!grepl(tolower(expected), tolower(message_text), fixed = TRUE))
    stop(sprintf("[FAIL] %s: wrong failure reason: %s", label, message_text), call. = FALSE)
  passed <<- passed + 1L
  cat(sprintf("[PASS] %s\n", label))
}

square <- function(xmin, xmax, ymin = 0, ymax = 1) {
  st_polygon(list(matrix(
    c(xmin, ymin, xmax, ymin, xmax, ymax, xmin, ymax, xmin, ymin),
    ncol = 2, byrow = TRUE
  )))
}

districts <- st_sf(
  district = c("West", "Centre", "East"),
  geometry = st_sfc(square(0, 1), square(1, 2), square(2, 3), crs = 4326)
)
template <- rast(xmin = 0, xmax = 3, ymin = 0, ymax = 1,
                 ncols = 6, nrows = 2, crs = "EPSG:4326")

# 1. A polygon with no valid raster coverage must not silently receive NA.
no_coverage <- st_sf(
  district = "Outside",
  geometry = st_sfc(square(10, 11), crs = 4326)
)
expect_error_contains(
  "rainfall missing coverage fails closed",
  rainfall_district_means(setValues(template, 1000), no_coverage),
  "got no rainfall value"
)

# 2. A classic unconverted Kelvin temperature must be rejected by the band gate.
expect_error_contains(
  "unconverted Kelvin temperature is rejected",
  temp_consistency_gate(districts$district, c(288, 290, 292), c(0.5, 1.5, 2.5)),
  "outside the sane"
)

# 3. An inverted rainfall gradient must not pass the broad-direction tripwire.
expect_error_contains(
  "inverted rainfall direction is rejected",
  rainfall_consistency_gate(districts$district, c(700, 1000, 1500), c(0.5, 1.5, 2.5)),
  "consistency check violated"
)

# 4. Raw MODIS digital numbers must fail the physical-scale assertion.
expect_error_contains(
  "unscaled MODIS digital numbers are rejected",
  ndvi_assert_raster_scale(setValues(template, 6000)),
  "scale was likely never applied"
)

# 5. A partial MODIS cache must not be mislabeled as an annual product.
expect_error_contains(
  "partial MODIS year is rejected",
  ndvi_assert_complete_year(
    month_keys = c("2023-01", "2023-01"),
    tile_keys = c("h20v09", "h21v09")
  ),
  "incomplete MODIS cache"
)

# 6. HAND containing only no-data sentinels must not yield a percentage.
expect_error_contains(
  "HAND all-no-data coverage fails closed",
  low_lying_share(setValues(template, -9999), districts, threshold_m = 5),
  "got no HAND value"
)

# 7. An impossible low-lying percentage must fail the valid-range gate.
expect_error_contains(
  "impossible HAND percentage is rejected",
  low_lying_consistency_gate(districts$district, c(-1, 50, 101), c(0.5, 1.5, 2.5)),
  "outside the valid"
)

cat(sprintf("\n=== transformation failure injection: %d passed, 0 failed ===\n", passed))
