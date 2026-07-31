#!/usr/bin/env Rscript

# Generate journal figures directly from the archived release data.
# The script uses only base R and sf, both recorded in renv.lock.

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
  colours <- hcl.colors(length(breaks) - 1L, palette = "Viridis", rev = FALSE)
  classes <- cut(values, breaks = breaks, include.lowest = TRUE, labels = FALSE)
  labels <- paste0(
    format_number(head(breaks, -1L), spec$digits),
    "–",
    format_number(tail(breaks, -1L), spec$digits)
  )
  list(breaks = breaks, colours = colours, classes = classes, labels = labels)
}

draw_map <- function(x, spec, title_prefix = TRUE, legend_cex = 0.62, border_lwd = 0.35) {
  style <- map_style(x[[spec$field]], spec)
  plot(
    st_geometry(x),
    col = style$colours[style$classes],
    border = "grey30",
    lwd = border_lwd,
    axes = FALSE,
    reset = FALSE
  )
  title_text <- if (title_prefix) paste0(spec$panel, ") ", spec$label) else spec$label
  title(main = title_text, adj = 0, line = 0.25, cex.main = 0.88)
  legend(
    "bottomright",
    legend = style$labels,
    fill = style$colours,
    border = NA,
    bty = "n",
    cex = legend_cex,
    inset = 0.01,
    x.intersp = 0.45,
    y.intersp = 0.85
  )
}

layers <- lapply(specs, read_checked_layer)

# Figure 1: data and verification architecture.
svg(
  filename = file.path(output_dir, "Fig1_workflow_architecture.svg"),
  width = 10,
  height = 6,
  pointsize = 10,
  onefile = TRUE
)
par(mar = rep(0, 4))
plot.new()
plot.window(xlim = c(0, 10), ylim = c(0, 6))

box <- function(xleft, ybottom, xright, ytop, label, cex = 0.82) {
  rect(xleft, ybottom, xright, ytop, lwd = 1.2)
  text((xleft + xright) / 2, (ybottom + ytop) / 2, label, cex = cex)
}
arrow <- function(x0, y0, x1, y1) arrows(x0, y0, x1, y1, length = 0.08, lwd = 1.1)

box(0.25, 4.65, 2.05, 5.45, "CHIRPS\nrainfall")
box(0.25, 3.55, 2.05, 4.35, "ERA5-Land\ntemperature")
box(0.25, 2.45, 2.05, 3.25, "MODIS\nNDVI")
box(0.25, 1.35, 2.05, 2.15, "Global HAND\nterrain")

box(2.65, 3.85, 4.65, 5.10, "Provider-specific\nacquisition, masking,\nscaling and temporal\naggregation")
box(2.65, 1.90, 4.65, 3.15, "Synthetic fixture\nexercises the same\ntransformation paths")
box(5.15, 3.30, 7.10, 4.55, "Coverage-fraction-\nweighted district\naggregation\n(30 districts)")
box(5.15, 1.45, 7.10, 2.70, "Fail-closed\nprovenance contract\nand licence metadata")
box(7.60, 3.30, 9.60, 4.55, "Standardised\nGeoJSON layers")
box(7.60, 1.45, 9.60, 2.70, "CI assertions,\nSHA-256 integrity and\nZenodo archive")

for (y in c(5.05, 3.95, 2.85, 1.75)) arrow(2.05, y, 2.65, 4.45)
arrow(4.65, 4.45, 5.15, 3.95)
arrow(4.65, 2.52, 5.15, 2.08)
arrow(7.10, 3.95, 7.60, 3.95)
arrow(7.10, 2.08, 7.60, 2.08)
arrow(6.13, 3.30, 6.13, 2.70)
arrow(8.60, 3.30, 8.60, 2.70)
text(5, 5.72, "Cross-provider Earth-data preparation and auditable release contract", cex = 1.05, font = 2)
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
par(mfrow = c(2, 2), mar = c(0.25, 0.25, 1.55, 0.25), oma = c(0.15, 0.15, 0.15, 0.15))
for (nm in names(specs)) {
  draw_map(layers[[nm]], specs[[nm]], title_prefix = TRUE, legend_cex = 0.54, border_lwd = 0.24)
}
dev.off()

# Individual vector maps are retained for editorial layout flexibility.
for (nm in names(specs)) {
  spec <- specs[[nm]]
  svg(
    filename = file.path(output_dir, paste0("Fig2", spec$panel, "_", nm, ".svg")),
    width = 6.4,
    height = 6.4,
    pointsize = 10,
    onefile = TRUE
  )
  par(mar = c(0.3, 0.3, 1.05, 0.3))
  draw_map(layers[[nm]], spec, title_prefix = FALSE, legend_cex = 0.75, border_lwd = 0.38)
  dev.off()
}

# Figure 3: standardized district distributions permit cross-layer comparison
# without implying that the four variables share physical units.
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

# Sort districts by the first principal component of the standardized matrix.
pc <- prcomp(values, center = FALSE, scale. = FALSE)
ord <- order(pc$x[, 1])
values <- values[ord, , drop = FALSE]

tiff(
  filename = file.path(output_dir, "Fig3_standardized_district_profiles.tiff"),
  width = 4800,
  height = 3300,
  units = "px",
  res = 600,
  compression = "lzw"
)
par(mar = c(7.8, 4.2, 0.7, 0.5))
matplot(
  seq_len(nrow(values)),
  values,
  type = "b",
  pch = c(16, 17, 15, 18),
  lty = c(1, 2, 3, 4),
  xaxt = "n",
  xlab = "District",
  ylab = "Standardized district value (z score)",
  cex = 0.55,
  lwd = 0.85
)
axis(1, at = seq_len(nrow(values)), labels = rownames(values), las = 2, cex.axis = 0.52)
abline(h = 0, lty = 3)
legend(
  "topleft",
  legend = colnames(values),
  pch = c(16, 17, 15, 18),
  lty = c(1, 2, 3, 4),
  bty = "n",
  cex = 0.68
)
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
