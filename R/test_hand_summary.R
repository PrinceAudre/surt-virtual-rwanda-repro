#!/usr/bin/env Rscript
# Reviewer-requested controlled verification of the HAND denominator contract.
# No network data are used. The equal-area fixture gives an explicit numerator,
# denominator, valid-area fraction, and threshold percentage.

suppressWarnings(suppressMessages({
  library(terra)
  library(sf)
  library(exactextractr)
}))

file_arg <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
here <- dirname(normalizePath(file_arg, winslash = "/", mustWork = TRUE))
source(file.path(here, "relief_low_lying_transform.R"))

passed <- 0L
check <- function(label, condition) {
  if (!isTRUE(condition)) stop(sprintf("[FAIL] %s", label), call. = FALSE)
  passed <<- passed + 1L
  cat(sprintf("[PASS] %s\n", label))
}

# EPSG:6933 is a global equal-area CRS. Four 1 km x 1 km cells fill the polygon.
hand <- rast(
  xmin = 0, xmax = 2000, ymin = 0, ymax = 2000,
  ncols = 2, nrows = 2, crs = "EPSG:6933"
)
values(hand) <- c(2, 8, -9999, 4)
polygon <- st_sf(
  unit_id = "HAND-FIXTURE",
  geometry = st_sfc(st_polygon(list(matrix(c(
    0, 0, 2000, 0, 2000, 2000, 0, 2000, 0, 0
  ), ncol = 2, byrow = TRUE))), crs = 6933)
)

summary <- low_lying_summary(hand, polygon, threshold_m = 5)

# In an equal-area 2x2 fixture each cell contributes the same area:
# valid cells = 3/4; low-lying valid cells = 2/3 of the valid denominator.
check("HAND mixed valid/no-data fixture reports 75 percent valid-area coverage",
      abs(summary$valid_hand_area_fraction - 0.75) < 1e-6)
check("HAND threshold denominator contains exactly three equal-area valid cells",
      abs(summary$valid_hand_area_m2 / 3e6 - 1) < 1e-6)
check("HAND threshold numerator contains exactly two equal-area cells at or below 5 m",
      abs(summary$threshold_area_m2 / 2e6 - 1) < 1e-6)
check("HAND share is percentage of valid HAND-covered area, not whole polygon area",
      abs(summary$low_lying_share_pct - (200 / 3)) < 1e-8)
check("negative HAND sentinel is excluded from both numerator and denominator",
      summary$threshold_area_m2 < summary$valid_hand_area_m2)
check("complete raster footprint is distinguished from incomplete valid HAND coverage",
      abs(summary$raster_coverage_fraction - 1) < 1e-6 &&
        summary$valid_hand_area_fraction < summary$raster_coverage_fraction)

all_invalid <- hand
values(all_invalid) <- -9999
rejected <- tryCatch({
  low_lying_summary(all_invalid, polygon, threshold_m = 5)
  FALSE
}, error = function(error) grepl("no valid HAND value", conditionMessage(error), fixed = TRUE))
check("all-no-data HAND polygon fails closed", rejected)

bad_threshold <- tryCatch({
  low_lying_summary(hand, polygon, threshold_m = -1)
  FALSE
}, error = function(error) grepl("non-negative", conditionMessage(error), fixed = TRUE))
check("negative HAND threshold fails closed", bad_threshold)

cat(sprintf("\n=== HAND valid-area denominator: %d passed, 0 failed ===\n", passed))
