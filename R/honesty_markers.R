# =====================================================================
# honesty_markers.R -- shared "illustrative / synthetic" display markers
# ---------------------------------------------------------------------
# PROVENANCE: reproduced from the SuRT-Virtual Rwanda application source
# (05_dashboard/honesty_markers.R). Logic unchanged; two em-dashes in the banner
# display string were normalized (to a hyphen and a comma). The application gate
# referenced below (tools/verify_research_methods.R) is not part of this reduced artifact.
# ---------------------------------------------------------------------
# Small htmltools helpers that render the on-screen honesty markers for
# any output whose METHOD is still illustrative (see research_methods.R:
# surt_output_is_illustrative(), keyed to the methodology register, fail
# closed). They live as standalone, dependency-light functions so the
# RENDERED markup can be verified headlessly (tools/verify_research_
# methods.R) without booting Shiny -- exercising the render pipeline, not
# just parse/boot.
#
# htmltools only (already a core Shiny dependency; NO new package). No
# data load, no network.
# =====================================================================

# Section-level banner: states the cards are illustrative synthetic
# scenarios shown under real source NAMES. Returns NULL when the output
# is not illustrative, so it disappears only when the METHOD is genuinely
# elevated in the register (never on a mere data swap).
surt_illustrative_banner <- function(is_illustrative) {
  if (!isTRUE(is_illustrative)) return(NULL)
  htmltools::tags$div(
    class = "surt-illustrative-banner",
    role = "note",
    style = paste0(
      "margin:0.35rem 0 0.75rem 0;padding:0.55rem 0.7rem;border-radius:10px;",
      "background:#fef3c7;border:1px solid #f59e0b;color:#7c2d12;",
      "font-size:0.82rem;line-height:1.4;"
    ),
    htmltools::tags$strong("Illustrative - synthetic scenarios. "),
    paste(
      "Source names (e.g. WHO Disease Outbreak News) denote the TYPE of",
      "source a real signal would come from; the relevance scores, the",
      "reported case and death counts, and the hazard details shown here",
      "are synthetic and SuRT-generated for demonstration, not real",
      "reports or assessments from the named sources. Verify every detail",
      "through RBC/MOH channels before any use."
    )
  )
}

# Per-card score badge. When illustrative, an "ILLUSTRATIVE" chip is
# prepended so the number never stands bare beside a real source name.
# `score_label` is the already-formatted string, e.g. "88/100".
surt_illustrative_score_badge <- function(score_label, is_illustrative) {
  base_style <- paste0(
    "white-space:nowrap;border-radius:999px;padding:0.25rem 0.55rem;",
    "font-size:0.78rem;font-weight:800;"
  )
  if (isTRUE(is_illustrative)) {
    htmltools::tags$span(
      title = paste(
        "Illustrative SuRT score computed on synthetic data -",
        "not an assessment from the named source"
      ),
      style = paste0(
        base_style,
        "background:#fffbeb;border:1px solid #f59e0b;color:#7c2d12;"
      ),
      htmltools::tags$span(
        style = paste0(
          "font-size:0.62rem;font-weight:900;letter-spacing:0.05em;",
          "text-transform:uppercase;margin-right:0.32rem;opacity:0.85;"
        ),
        "Illustrative"
      ),
      score_label
    )
  } else {
    htmltools::tags$span(
      style = paste0(
        base_style,
        "background:#f1f5f9;border:1px solid #cbd5e1;color:#0f172a;"
      ),
      score_label
    )
  }
}
