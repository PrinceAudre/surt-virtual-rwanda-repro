#!/usr/bin/env Rscript
# demo_value_class.R
# ---------------------------------------------------------------------
# Minimal, self-contained demonstration and checks for the value-class discipline, run
# against the ILLUSTRATIVE example_register (example_register.R). These checks mirror the
# register-shape and fail-closed properties described in the paper. They are the generic,
# application-independent subset; the full application gate (which also verifies
# application wiring against private synthetic data) is not part of this reduced artifact.
#
# USAGE:  Rscript demo_value_class.R      (exit 0 = all checks pass)
# ---------------------------------------------------------------------
.fa  <- grep("^--file=", commandArgs(FALSE), value = TRUE)
here <- if (length(.fa)) dirname(sub("^--file=", "", .fa[1])) else "."
source(file.path(here, "provenance_value_class.R"))
source(file.path(here, "example_register.R"))

pass <- 0L; fail <- 0L
ck <- function(name, cond) {
  if (isTRUE(cond)) { pass <<- pass + 1L; cat("[PASS] ", name, "\n", sep = "") }
  else              { fail <<- fail + 1L; cat("[FAIL] ", name, "\n", sep = "") }
}

reg <- example_register()

ck("example register is well-formed (all fields, legal classes)", surt_method_register_ok(reg))
ck("register_ok REJECTS a sound+placeholder entry (a hand-baked method may not be 'sound')",
   isFALSE(surt_method_register_ok(list(list(id = "x", display = "x", method = "x", palette = "x",
     evidence_class = "sound", method_class = "placeholder", citation = "x")))))
ck("real climate layer is NOT illustrative (evidence_class sound)",
   isFALSE(surt_output_is_illustrative("climate_temperature_layer", reg)))
ck("synthetic signal IS illustrative",
   surt_output_is_illustrative("synthetic_disease_signal", reg))
ck("fail-closed: an unknown id is treated as illustrative",
   surt_output_is_illustrative("no_such_id", reg))
ck("illustrative note is empty for the sound output (auto-lifts)",
   identical(surt_illustrative_note("climate_temperature_layer", register = reg), ""))
ck("illustrative note is non-empty for the synthetic output",
   nzchar(surt_illustrative_note("synthetic_disease_signal", register = reg)))
ck("CVD palettes: viridis hex of length n, and Okabe-Ito has 8 colours",
   { p <- surt_cvd_sequential(5L); length(p) == 5L && all(grepl("^#", p)) && length(surt_okabe_ito) == 8L })
ck("quantile breaks: unique and sorted, safe on ties and on a single value",
   { b <- surt_quantile_breaks(1:10, 5L); s <- surt_quantile_breaks(rep(5, 9), 5L)
     !anyDuplicated(b) && !is.unsorted(b) && length(s) == 2L && s[1] < s[2] })

cat(sprintf("\n=== value-class demo: %d passed, %d failed ===\n", pass, fail))
quit(status = if (fail == 0L) 0L else 1L)
