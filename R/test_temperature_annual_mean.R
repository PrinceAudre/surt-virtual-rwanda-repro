#!/usr/bin/env Rscript
# Controlled verification of the ERA5-Land annual-temperature statistic.

suppressWarnings(suppressMessages({ library(terra) }))
file_arg <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
here <- dirname(normalizePath(file_arg, winslash = "/", mustWork = TRUE))
source(file.path(here, "relief_temp_transform.R"))

passed <- 0L
check <- function(label, condition) {
  if (!isTRUE(condition)) stop(sprintf("[FAIL] %s", label), call. = FALSE)
  passed <<- passed + 1L
  cat(sprintf("[PASS] %s\n", label))
}

check("2023 calendar has 365 days", sum(temp_month_days(2023)) == 365L)
check("2024 calendar has 366 days", sum(temp_month_days(2024)) == 366L)
check("Gregorian century 1900 is not leap", !temp_is_leap_year(1900))
check("Gregorian century 2000 is leap", temp_is_leap_year(2000))

# One-cell monthly stack with exact values 1..12. The weighted numerators are
# 2382 for 2023 and 2384 for 2024, yielding fixed controlled expectations.
template <- rast(xmin = 0, xmax = 1, ymin = 0, ymax = 1,
                 ncols = 1, nrows = 1, crs = "EPSG:4326")
monthly <- rast(lapply(1:12, function(value) setValues(template, value)))
y2023 <- values(temp_calendar_day_weighted_mean(monthly, 2023))[[1]]
y2024 <- values(temp_calendar_day_weighted_mean(monthly, 2024))[[1]]
check("2023 monthly means use exact calendar-day weights",
      abs(y2023 - 2382 / 365) < 1e-12)
check("2024 monthly means use exact leap-year calendar-day weights",
      abs(y2024 - 2384 / 366) < 1e-12)
check("leap-day weighting changes the annual statistic when February differs",
      abs(y2023 - y2024) > 1e-3)
check("calendar-day annual mean is not the unweighted 12-month mean",
      abs(y2023 - mean(1:12)) > 1e-3)

kelvin <- setValues(template, 273.15)
celsius <- temp_kelvin_to_celsius(kelvin)
check("Kelvin to Celsius conversion maps 273.15 K to 0 C",
      abs(values(celsius)[[1]]) < 1e-12)

incomplete <- rast(lapply(1:11, function(value) setValues(template, value)))
rejected <- tryCatch({
  temp_calendar_day_weighted_mean(incomplete, 2023)
  FALSE
}, error = function(error) grepl("expected 12", conditionMessage(error), fixed = TRUE))
check("incomplete monthly stack fails closed", rejected)

cat(sprintf("\n=== ERA5 annual temperature statistic: %d passed, 0 failed ===\n", passed))
