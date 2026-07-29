# provenance_value_class.R
# ---------------------------------------------------------------------
# The generic provenance / value-class discipline from SuRT-Virtual Rwanda.
#
# These functions implement the value-class discipline described in the accompanying
# paper: a methodology register in which every displayed output declares an
# evidence_class (source-derived = a documented method on real/public data; illustrative =
# any output computed on synthetic or placeholder data) and a method_class (documented /
# placeholder), validated for shape, with a FAIL-CLOSED rule that an output is treated as
# illustrative unless the register explicitly declares it "source-derived".
#
# PROVENANCE: the function definitions below are reproduced from the SuRT-Virtual Rwanda
# application source (05_dashboard/research_methods.R). The function logic is unchanged.
# Two edits, both disclosed: (1) the `register` default argument, which in the application
# points at the application's real register, here points at example_register() (see
# example_register.R), a small clearly-labelled ILLUSTRATIVE SCHEMA EXAMPLE, so these
# functions are runnable without shipping the application's register; and (2) an em-dash was
# normalized to a hyphen in two human-readable display strings. Surrounding comments have
# been lightly edited for this standalone extract.
#
# SCOPE OF THIS PUBLIC ARTIFACT: this is the reduced, honestly-scoped reproducibility
# artifact for the paper. The full SuRT-Virtual Rwanda application, including its real
# methodology register (which enumerates the application's full set of outputs, some of
# them operational-adjacent) and that operational-adjacent layer itself, is NOT included
# here and remains a private, non-operational prototype (operational_use_allowed = FALSE).
#
# Base R only (grDevices / stats). No data load, no network.
# ---------------------------------------------------------------------

# Colourblind-safe sequential palette: viridis (perceptually uniform, robust to common
# colour-vision deficiencies) via base grDevices (no dependency).
surt_cvd_sequential <- function(n) grDevices::hcl.colors(max(1L, as.integer(n)), "viridis")

# Colourblind-safe qualitative palette: the Okabe-Ito 8-colour set (Wong 2011, Nature
# Methods 8:441; Okabe & Ito 2008), recycled across the levels present.
surt_okabe_ito <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
                    "#0072B2", "#D55E00", "#CC79A7", "#000000")
surt_cvd_qualitative <- function(n) rep(surt_okabe_ito, length.out = max(1L, as.integer(n)))

# Stated classification: quantile (equal-count) breaks, a standard, stated choropleth
# method (Slocum et al., Thematic Cartography & Geovisualization), as opposed to arbitrary
# hard-coded bins. Guards ties / few distinct values / a single distinct value.
surt_quantile_breaks <- function(x, k = 5L) {
  x <- x[is.finite(x)]
  if (!length(x)) return(c(0, 1))
  k  <- max(2L, as.integer(k))
  br <- unique(as.numeric(stats::quantile(x, probs = seq(0, 1, length.out = k + 1L),
                                          names = FALSE, type = 7L)))
  if (length(br) < 2L) {                       # single distinct value
    v <- x[1]
    br <- c(v, v + if (v == 0) 1 else abs(v) * 0.01)
  }
  br
}

# Value-class vocabulary.
#   evidence_class: "source-derived" (documented method, real/public data) |
#                   "illustrative" (synthetic/placeholder)
#   method_class:   "documented" (a real, stated/cited method) | "placeholder" (hand-baked / ad-hoc)
surt_evidence_classes <- c("source-derived", "illustrative")
surt_method_classes   <- c("documented", "placeholder")

# Fetch one register entry by id (NULL if absent).
surt_method_of <- function(id, register = example_register()) {
  for (e in register) if (identical(e$id, id)) return(e)
  NULL
}

# Validate the register shape: every entry has all fields, each a single non-empty string,
# and a legal evidence_class / method_class. A placeholder (hand-baked) method can NEVER be
# a source-derived output: that combination would make surt_output_is_illustrative() FALSE and hide
# the honesty marker on a hand-baked score, so it is rejected (fail-closed).
surt_method_register_ok <- function(register = example_register()) {
  if (!length(register)) return(FALSE)
  req <- c("id", "display", "method", "palette", "evidence_class", "method_class", "citation")
  ok1 <- function(x) is.character(x) && length(x) == 1L && nzchar(x)   # single non-empty string
  all(vapply(register, function(e) {
    all(req %in% names(e)) &&
      all(vapply(req, function(f) ok1(e[[f]]), logical(1))) &&
      e$evidence_class %in% surt_evidence_classes &&
      e$method_class %in% surt_method_classes &&
      !(identical(e$evidence_class, "source-derived") &&
        identical(e$method_class, "placeholder"))
  }, logical(1)))
}

# Is a displayed output's method still illustrative (vs source-derived)?
# FAIL CLOSED: illustrative unless the register explicitly declares evidence_class "source-derived"
# for the id. Unknown / missing id -> illustrative. This ties the on-screen "illustrative"
# marker to the METHOD's honesty (the register), not to whether the input data are real.
surt_output_is_illustrative <- function(id, register = example_register()) {
  e <- surt_method_of(id, register)
  is.null(e) || !identical(e$evidence_class, "source-derived")
}

# Short human-readable "illustrative" note; "" when the output is source-derived (auto-lifts when a
# method is elevated). A placeholder output is never described as "a documented method".
surt_illustrative_note <- function(id, short = FALSE, register = example_register()) {
  if (!surt_output_is_illustrative(id, register)) return("")
  if (isTRUE(short)) return("illustrative")
  e <- surt_method_of(id, register)
  if (!is.null(e) && identical(e$method_class, "documented"))
    "Illustrative - a documented method on synthetic data; not a validated operational output."
  else
    "Illustrative - a synthetic or placeholder output; not a validated operational output."
}
