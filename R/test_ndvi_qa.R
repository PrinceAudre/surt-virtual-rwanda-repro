#!/usr/bin/env Rscript
# Controlled verification of MOD13A3 pixel-reliability filtering and temporal coverage.

suppressWarnings(suppressMessages({ library(terra) }))
file_arg <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
here <- dirname(normalizePath(file_arg, winslash = "/", mustWork = TRUE))
source(file.path(here, "relief_ndvi_transform.R"))

passed <- 0L
check <- function(label, condition) {
  if (!isTRUE(condition)) stop(sprintf("[FAIL] %s", label), call. = FALSE)
  passed <<- passed + 1L
  cat(sprintf("[PASS] %s\n", label))
}

r <- rast(xmin = 0, xmax = 4, ymin = 0, ymax = 1,
          ncols = 4, nrows = 1, crs = "EPSG:4326")
values(r) <- c(5000, 6000, 7000, 8000)
qa <- r
values(qa) <- c(0, 1, 2, 3)

good <- ndvi_apply_mod13a3_quality(r, qa, accepted_quality = 0L)
good_values <- values(good)[, 1]
check("default-good QA retains rank 0 NDVI", abs(good_values[[1]] - 0.5) < 1e-12)
check("default-good QA masks marginal, snow/ice, and cloudy ranks",
      all(is.na(good_values[2:4])))

good_marginal <- ndvi_apply_mod13a3_quality(r, qa, accepted_quality = c(0L, 1L))
gm_values <- values(good_marginal)[, 1]
check("configurable QA can deliberately admit marginal rank 1",
      abs(gm_values[[1]] - 0.5) < 1e-12 && abs(gm_values[[2]] - 0.6) < 1e-12 &&
        all(is.na(gm_values[3:4])))

unfiltered <- ndvi_apply_mod13a3_quality(r, accepted_quality = NULL)
check("explicit unfiltered mode retains all valid-range NDVI values",
      max(abs(values(unfiltered)[, 1] - c(0.5, 0.6, 0.7, 0.8))) < 1e-12)

missing_qa_rejected <- tryCatch({
  ndvi_apply_mod13a3_quality(r, accepted_quality = 0L)
  FALSE
}, error = function(error) grepl("pixel-reliability raster is missing", conditionMessage(error), fixed = TRUE))
check("quality-filtered mode fails closed when QA raster is absent", missing_qa_rejected)

bad_policy_rejected <- tryCatch({
  ndvi_apply_mod13a3_quality(r, qa, accepted_quality = 4L)
  FALSE
}, error = function(error) grepl("integers from 0 to 3", conditionMessage(error), fixed = TRUE))
check("invalid MOD13A3 reliability rank fails closed", bad_policy_rejected)

# Separate annual-QA fixtures preserve the earlier rank-policy test above while
# exercising temporal completeness explicitly. Cell 1 is good both months;
# cell 2 is good only in month 1; cells 3-4 are never accepted. With a 0.5
# minimum valid-month fraction, cells 1-2 remain with completeness 1.0 and 0.5.
qa_month1 <- qa
values(qa_month1) <- c(0, 0, 2, 3)
r2 <- r
values(r2) <- c(7000, 9000, 7000, 8000)
qa_month2 <- qa
values(qa_month2) <- c(0, 3, 2, 3)
summary <- ndvi_annual_summary_4326(
  list(
    list(month = "M01", r = r, qa = qa_month1),
    list(month = "M02", r = r2, qa = qa_month2)
  ),
  accepted_quality = 0L,
  min_valid_month_fraction = 0.5
)
mean_values <- values(summary$mean)[, 1]
valid_fraction_values <- values(summary$valid_month_fraction)[, 1]
check("QA-aware annual mean averages only accepted monthly observations",
      abs(mean_values[[1]] - 0.6) < 1e-3 &&
        abs(mean_values[[2]] - 0.6) < 1e-3)
check("annual summary reports monthly QA completeness",
      abs(valid_fraction_values[[1]] - 1) < 1e-6 &&
        abs(valid_fraction_values[[2]] - 0.5) < 1e-6)

strict <- ndvi_annual_summary_4326(
  list(
    list(month = "M01", r = r, qa = qa_month1),
    list(month = "M02", r = r2, qa = qa_month2)
  ),
  accepted_quality = 0L,
  min_valid_month_fraction = 0.75
)
strict_values <- values(strict$mean)[, 1]
check("minimum monthly completeness masks cells below the configured threshold",
      is.finite(strict_values[[1]]) && is.na(strict_values[[2]]))

cat(sprintf("\n=== MOD13A3 QA policy: %d passed, 0 failed ===\n", passed))
