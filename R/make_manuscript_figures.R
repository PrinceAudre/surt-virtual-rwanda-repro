#!/usr/bin/env Rscript

# Generate journal figures directly from the archived release data.
# Artwork contains no article title or full caption; captions remain in the
# manuscript. Combination art is exported at 600 dpi, while line art and
# individual maps are also exported as SVG and EPS for editorial flexibility.

suppressPackageStartupMessages(library(sf))

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1]]) else "R/make_manuscript_figures.R"
repo_root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
output_dir <- file.path(repo_root, "paper", "figures", "generated")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

specs <- list(
  rainfall = list(
    path = file.path(repo_root, "data", "relief_climate_rainfall.geojson"),
    field = "annual_rainfall_mm",
    label = "Annual rainfall (mm)",
    panel = "a",
    digits = 0
  ),
  temperature = list(
    path = file.path(repo_root, "data", "relief_climate_temp.geojson"),
    field = "mean_temp_c",
    label = "Mean temperature (degrees C)",
    panel = "b",
    digits = 1
  ),
  ndvi = list(
    path = file.path(repo_root, "data", "relief_climate_ndvi.geojson"),
    field = "mean_ndvi",
    label = "Mean NDVI",
    panel = "c",
    digits = 2
  ),
  hand = list(
    path = file.path(repo_root, "data", "relief_low_lying_hand.geojson"),
    field = "low_lying_share_pct",
    label = "HAND <= 5 m share (%)",
    panel = "d",
    digits = 1
  )
)

read_checked_layer <- function(spec) {
  if (!file.exists(spec$path)) stop("Missing release layer: ", spec$path)
  x <- st_read(spec$path, quiet = TRUE, stringsAsFactors = FALSE)
  if (nrow(x) != 30L) stop("Expected 30 districts in ", basename(spec$path), "; found ", nrow(x))
  if (!all(c("district", spec$field) %in% names(x))) {
    stop("Required fields are missing from ", basename(spec$path))
  }
  if (any(!is.finite(x[[spec$field]]))) stop("Non-finite values found in ", basename(spec$path))
  x
}

format_number <- function(x, digits) {
  formatC(x, format = "f", digits = digits, big.mark = ",")
}

map_style <- function(values, spec, n_classes = 6L) {
  breaks <- pretty(range(values, finite = TRUE), n = n_classes)
  if (length(breaks) < 3L) {
    breaks <- seq(min(values), max(values), length.out = n_classes + 1L)
  }
  breaks[1] <- min(breaks[1], min(values))
  breaks[length(breaks)] <- max(breaks[length(breaks)], max(values))
  breaks <- unique(breaks)

  # Cividis has monotonic luminance and remains interpretable when printed in
  # greyscale. Numeric interval labels provide redundant non-colour encoding.
  colours <- hcl.colors(length(breaks) - 1L, palette = "Cividis", rev = FALSE)
  classes <- cut(values, breaks = breaks, include.lowest = TRUE, labels = FALSE)
  labels <- paste0(
    format_number(head(breaks, -1L), spec$digits),
    "–",
    format_number(tail(breaks, -1L), spec$digits)
  )
  list(breaks = breaks, colours = colours, classes = classes, labels = labels)
}

draw_map <- function(x, spec, legend_cex = 0.66, border_lwd = 0.35, panel_label = TRUE) {
  style <- map_style(x[[spec$field]], spec)
  plot(
    st_geometry(x),
    col = style$colours[style$classes],
    border = "grey25",
    lwd = border_lwd,
    axes = FALSE,
    reset = FALSE
  )
  if (panel_label) {
    mtext(paste0("(", spec$panel, ")"), side = 3, line = 0.15, adj = 0,
          cex = 0.9, font = 2)
  }
  legend(
    "bottomright",
    legend = style$labels,
    title = spec$label,
    fill = style$colours,
    border = "grey35",
    bty = "n",
    cex = legend_cex,
    inset = 0.01,
    x.intersp = 0.50,
    y.intersp = 0.88,
    title.adj = 0
  )
}

open_eps <- function(filename, width, height, pointsize = 10) {
  postscript(
    file = filename,
    width = width,
    height = height,
    pointsize = pointsize,
    onefile = FALSE,
    horizontal = FALSE,
    paper = "special",
    family = "sans"
  )
}

layers <- lapply(specs, read_checked_layer)

# Figure 1: a clean production path plus independent evidence band. Evidence
# boxes are not connected back into individual production nodes because each
# gate addresses a different claim class and crossing arrows reduce readability.
draw_architecture <- function() {
  par(mar = rep(0, 4))
  plot.new()
  plot.window(xlim = c(0, 11), ylim = c(0, 7.2))

  box <- function(xleft, ybottom, xright, ytop, label, cex = 0.76, lwd = 1.15) {
    rect(xleft, ybottom, xright, ytop, lwd = lwd)
    text((xleft + xright) / 2, (ybottom + ytop) / 2, label, cex = cex)
  }
  arrow <- function(x0, y0, x1, y1, lty = 1) {
    arrows(x0, y0, x1, y1, length = 0.07, lwd = 1.05, lty = lty)
  }

  # Source products.
  box(0.15, 5.85, 1.75, 6.55, "CHIRPS\nrainfall")
  box(0.15, 4.95, 1.75, 5.65, "ERA5-Land\ntemperature")
  box(0.15, 4.05, 1.75, 4.75, "MODIS\nNDVI")
  box(0.15, 3.15, 1.75, 3.85, "Global HAND\nterrain")

  # Core production path.
  box(2.20, 4.55, 4.05, 6.05,
      "Provider-specific\nacquisition, masking,\nscaling, mosaicking and\ntemporal aggregation")
  box(4.50, 4.55, 6.35, 6.05,
      "Polygon extraction\nand coverage-fraction-\nweighted administrative\naggregation")
  box(6.80, 4.55, 8.65, 6.05,
      "Common GeoJSON\nschema, provenance\nstrings and per-file\nsource terms")
  box(9.10, 4.55, 10.85, 6.05,
      "Versioned release\nmetadata, integrity\nmanifest and archive")

  for (y in c(6.20, 5.30, 4.40, 3.50)) arrow(1.75, y, 2.20, 5.30)
  arrow(4.05, 5.30, 4.50, 5.30)
  arrow(6.35, 5.30, 6.80, 5.30)
  arrow(8.65, 5.30, 9.10, 5.30)

  text(5.50, 3.03, "Independent executable evidence and validation", cex = 0.82, font = 2)

  evidence_centres <- c(1.22, 3.37, 5.52, 7.67, 9.82)
  box(0.30, 1.55, 2.15, 2.65,
      "Positive synthetic\ntransformation fixture\n(9 assertions)")
  box(2.45, 1.55, 4.30, 2.65,
      "Projected arbitrary-\nidentifier portability\nfixture (6 assertions)")
  box(4.60, 1.55, 6.45, 2.65,
      "Transformation\nfailure injection\n(7 assertions)")
  box(6.75, 1.55, 8.60, 2.65,
      "Independent release\ncontract and corruption\ntests (10 outcomes)")
  box(8.90, 1.55, 10.75, 2.65,
      "Public CHIRPS\nreproduction and\nweighting sensitivity")

  box(0.30, 0.30, 10.75, 1.05,
      "Clean continuous integration records machine-readable outcomes; listed-file SHA-256 checks establish integrity, not scientific validity",
      cex = 0.72)
  for (x in evidence_centres) arrow(x, 1.55, x, 1.05, lty = 2)
}

svg(
  filename = file.path(output_dir, "Fig1_workflow_architecture.svg"),
  width = 11,
  height = 7.2,
  pointsize = 10,
  onefile = TRUE
)
draw_architecture()
dev.off()

open_eps(file.path(output_dir, "Fig1_workflow_architecture.eps"), 11, 7.2, 10)
draw_architecture()
dev.off()

# Figure 2: deterministic four-panel district maps. Explicit geometry plotting is
# used instead of sf's automatic key layout, which can override par(mfrow).
tiff(
  filename = file.path(output_dir, "Fig2_environmental_layers.tiff"),
  width = 4200,
  height = 3600,
  units = "px",
  res = 600,
  compression = "lzw"
)
par(mfrow = c(2, 2), mar = c(0.25, 0.25, 1.15, 0.25), oma = c(0.15, 0.15, 0.15, 0.15))
for (nm in names(specs)) {
  draw_map(layers[[nm]], specs[[nm]], legend_cex = 0.66, border_lwd = 0.24)
}
dev.off()

# Individual vector maps retain panel labels and numeric interval legends, but
# no figure title or caption.
for (nm in names(specs)) {
  spec <- specs[[nm]]
  svg_path <- file.path(output_dir, paste0("Fig2", spec$panel, "_", nm, ".svg"))
  eps_path <- file.path(output_dir, paste0("Fig2", spec$panel, "_", nm, ".eps"))

  svg(filename = svg_path, width = 6.4, height = 6.4, pointsize = 10, onefile = TRUE)
  par(mar = c(0.3, 0.3, 0.85, 0.3))
  draw_map(layers[[nm]], spec, legend_cex = 0.76, border_lwd = 0.38)
  dev.off()

  open_eps(eps_path, 6.4, 6.4, 10)
  par(mar = c(0.3, 0.3, 0.85, 0.3))
  draw_map(layers[[nm]], spec, legend_cex = 0.76, border_lwd = 0.38)
  dev.off()
}

# Figure 3: three independent provenance controls. The layout mirrors the
# callable functions in R/provenance_value_class.R and deliberately does not
# imply that register validation is an enforced prerequisite for the display
# classification or note-selection functions.
draw_provenance_decision <- function() {
  par(mar = rep(0, 4))
  plot.new()
  plot.window(xlim = c(0, 11), ylim = c(0, 9))

  box <- function(xleft, ybottom, xright, ytop, label,
                  cex = 0.67, lwd = 1.05, font = 1) {
    rect(xleft, ybottom, xright, ytop, lwd = lwd)
    text((xleft + xright) / 2, (ybottom + ytop) / 2,
         label, cex = cex, font = font)
  }
  diamond <- function(cx, cy, width, height, label, cex = 0.61, lwd = 1.05) {
    polygon(
      x = c(cx, cx + width / 2, cx, cx - width / 2),
      y = c(cy + height / 2, cy, cy - height / 2, cy),
      lwd = lwd
    )
    text(cx, cy, label, cex = cex)
  }
  arrow <- function(x0, y0, x1, y1, label = NULL,
                    label_x = (x0 + x1) / 2, label_y = (y0 + y1) / 2,
                    lty = 1) {
    arrows(x0, y0, x1, y1, length = 0.065, lwd = 0.95, lty = lty)
    if (!is.null(label)) text(label_x, label_y, label, cex = 0.56)
  }
  control_heading <- function(cx, number, title, function_name) {
    text(cx, 8.55, paste0("Control ", number, ": ", title),
         cex = 0.79, font = 2)
    text(cx, 8.18, function_name, cex = 0.62)
  }

  segments(3.67, 1.08, 3.67, 8.82, lty = 3, col = "grey45")
  segments(7.34, 1.08, 7.34, 8.82, lty = 3, col = "grey45")

  # Control 1: register validation.
  control_heading(1.84, 1, "register validation", "surt_method_register_ok()")
  box(0.45, 7.15, 3.22, 7.78, "Method register supplied")
  arrow(1.84, 7.15, 1.84, 6.73)
  diamond(
    1.84, 6.13, 2.50, 1.12,
    "Required fields present,\nsingle non-empty strings,\nand legal class values?"
  )
  box(0.08, 4.78, 1.14, 5.42, "FALSE:\ninvalid shape", cex = 0.60)
  arrow(0.59, 6.13, 0.59, 5.42, "No", 0.38, 5.78)
  arrow(1.84, 5.57, 1.84, 5.12, "Yes", 2.08, 5.35)
  diamond(
    1.84, 4.45, 2.42, 1.08,
    "source-derived AND\nplaceholder?"
  )
  box(0.08, 3.05, 1.14, 3.69, "FALSE:\nprohibited pair", cex = 0.57)
  arrow(0.63, 4.45, 0.63, 3.69, "Yes", 0.39, 4.06)
  box(1.20, 2.78, 3.18, 3.58, "TRUE:\nregister accepted", cex = 0.64)
  arrow(1.84, 3.91, 2.18, 3.58, "No", 2.18, 3.78)
  box(
    0.30, 1.38, 3.38, 2.20,
    "Validates declaration shape and the prohibited class\ncombination; it does not prove a citation or data source.",
    cex = 0.57
  )

  # Control 2: display classification.
  control_heading(5.51, 2, "display classification", "surt_output_is_illustrative()")
  box(4.03, 7.15, 7.00, 7.78, "Output identifier and register")
  arrow(5.51, 7.15, 5.51, 6.71)
  diamond(
    5.51, 6.02, 2.82, 1.28,
    "Identifier is present AND\nevidence_class is exactly\nsource-derived?"
  )
  box(3.89, 4.63, 5.13, 5.35, "TRUE:\nillustrative", cex = 0.64)
  arrow(4.10, 6.02, 4.51, 5.35, "No", 4.12, 5.67)
  box(5.89, 4.63, 7.14, 5.35, "FALSE:\nsource-derived", cex = 0.62)
  arrow(6.92, 6.02, 6.52, 5.35, "Yes", 6.91, 5.67)
  box(
    4.00, 3.20, 7.03, 4.12,
    "Fail closed: unknown, missing, or non-source-derived\nentries remain illustrative.",
    cex = 0.59
  )
  box(
    4.00, 1.38, 7.03, 2.68,
    "Does not inspect method_class and does not independently\nverify use of real or public data.",
    cex = 0.57
  )

  # Control 3: illustrative note selection.
  control_heading(9.18, 3, "illustrative-note selection", "surt_illustrative_note()")
  box(7.70, 7.15, 10.67, 7.78, "Output identifier, register,\nand optional short flag")
  arrow(9.18, 7.15, 9.18, 6.77)
  diamond(9.18, 6.25, 2.48, 1.00, "Output is illustrative?")
  box(9.70, 5.03, 10.91, 5.62, "Return empty string", cex = 0.58)
  arrow(10.42, 6.25, 10.30, 5.62, "No", 10.57, 5.94)
  arrow(9.18, 5.75, 9.18, 5.34, "Yes", 9.41, 5.54)
  diamond(9.18, 4.81, 2.30, 0.94, "short is TRUE?")
  box(9.71, 3.80, 10.91, 4.39, "Return \"illustrative\"", cex = 0.55)
  arrow(10.33, 4.81, 10.30, 4.39, "Yes", 10.51, 4.59)
  arrow(9.18, 4.34, 9.18, 3.91, "No", 9.41, 4.12)
  diamond(
    9.18, 3.32, 2.40, 1.04,
    "Known entry AND\nmethod_class documented?"
  )
  box(
    7.49, 1.73, 8.79, 2.64,
    "Documented method\non synthetic data note",
    cex = 0.54
  )
  arrow(7.98, 3.32, 8.14, 2.64, "Yes", 7.80, 2.97)
  box(
    9.58, 1.73, 10.91, 2.64,
    "Synthetic or placeholder\noutput note",
    cex = 0.54
  )
  arrow(10.38, 3.32, 10.24, 2.64, "No", 10.55, 2.97)

  box(
    0.30, 0.18, 10.70, 0.88,
    "The functions are callable independently; register validity is not an enforced prerequisite for display classification or note selection.",
    cex = 0.62
  )
}

svg(
  filename = file.path(output_dir, "Fig3_provenance_decision.svg"),
  width = 11,
  height = 9,
  pointsize = 10,
  onefile = TRUE
)
draw_provenance_decision()
dev.off()

open_eps(file.path(output_dir, "Fig3_provenance_decision.eps"), 11, 9, 10)
draw_provenance_decision()
dev.off()

# Supplementary Figure S1: standardized district distributions permit
# cross-layer comparison without implying that the four variables share
# physical units. Distinct line types and symbols avoid reliance on colour.
values <- do.call(
  cbind,
  lapply(names(specs), function(nm) {
    spec <- specs[[nm]]
    x <- layers[[nm]]
    z <- as.numeric(scale(x[[spec$field]]))
    names(z) <- x$district
    z
  })
)
colnames(values) <- c("Rainfall", "Temperature", "NDVI", "HAND share")

pc <- prcomp(values, center = FALSE, scale. = FALSE)
ord <- order(pc$x[, 1])
values <- values[ord, , drop = FALSE]

draw_profiles <- function() {
  par(mar = c(8.4, 4.2, 2.2, 0.5), xpd = NA)
  matplot(
    seq_len(nrow(values)),
    values,
    type = "b",
    pch = c(16, 17, 15, 18),
    lty = c(1, 2, 3, 4),
    xaxt = "n",
    xlab = "District",
    ylab = "Standardized district value (z score)",
    cex = 0.60,
    lwd = 0.90,
    col = rep("black", 4)
  )
  axis(1, at = seq_len(nrow(values)), labels = rownames(values), las = 2, cex.axis = 0.58)
  abline(h = 0, lty = 3)
  legend(
    "top",
    inset = c(0, -0.12),
    legend = colnames(values),
    pch = c(16, 17, 15, 18),
    lty = c(1, 2, 3, 4),
    ncol = 4,
    horiz = TRUE,
    bty = "n",
    cex = 0.72,
    seg.len = 1.5,
    x.intersp = 0.55,
    col = rep("black", 4)
  )
}

tiff(
  filename = file.path(output_dir, "FigS1_standardized_district_profiles.tiff"),
  width = 4800,
  height = 3300,
  units = "px",
  res = 600,
  compression = "lzw"
)
draw_profiles()
dev.off()

open_eps(file.path(output_dir, "FigS1_standardized_district_profiles.eps"), 8, 5.5, 10)
draw_profiles()
dev.off()

summary_rows <- lapply(names(specs), function(nm) {
  spec <- specs[[nm]]
  v <- layers[[nm]][[spec$field]]
  data.frame(
    layer = nm,
    field = spec$field,
    minimum = min(v),
    first_quartile = unname(quantile(v, 0.25)),
    median = median(v),
    mean = mean(v),
    third_quartile = unname(quantile(v, 0.75)),
    maximum = max(v),
    stringsAsFactors = FALSE
  )
})
write.csv(
  do.call(rbind, summary_rows),
  file = file.path(output_dir, "environmental_layer_summary.csv"),
  row.names = FALSE
)

message("Generated manuscript figures in: ", output_dir)
