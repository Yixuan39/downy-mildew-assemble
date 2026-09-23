# Nature Plants figure text guidance: 5-7 pt sans-serif for standard labelling
# (https://www.nature.com/nplants/submission-guidelines/aip-and-formatting).
theme_pub <- function(base_size = 7, base_family = "Helvetica") {
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) %+replace%
    ggplot2::theme(
      axis.title = ggplot2::element_text(size = 7),
      axis.text = ggplot2::element_text(size = 6, colour = "black"),
      strip.text = ggplot2::element_text(size = 7),
      legend.title = ggplot2::element_text(size = 7),
      legend.text = ggplot2::element_text(size = 6),
      legend.key.size = grid::unit(3, "mm"),
      plot.title = ggplot2::element_text(size = 7)
    )
}

# Shared colorblind-safe (Okabe-Ito-derived) palette for the Kraken2 phylum-level
# taxon categories used across Figure 1 (analysis/read-distribution.Rmd) and the
# read-level GC/coverage panel (analysis/read-distribution.Rmd), so both panels use
# an identical taxon -> color mapping.
taxon_palette <- c(
  "Oomycota"       = "#000000", # target genus - bold black
  "Streptophyta"   = "#0072B2", # host plant
  "Pseudomonadota" = "#D55E00", # major bacterial contaminant
  "Bacteroidota"   = "#009E73",
  "Ascomycota"     = "#CC79A7",
  "Chordata"       = "#E69F00",
  "unclassified"   = "#56B4E9",
  "Other"          = "#999999"
)

figure_path <- function(filename) {
  if (requireNamespace("here", quietly = TRUE)) {
    path <- here::here("figures", filename)
  } else {
    path <- file.path("figures", filename)
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  path
}

save_pub_r <- function(
  plot,
  filename,
  width_mm,
  height_mm,
  dpi = 600,
  allowed_width_mm = c(90, 180),
  max_height_mm = 170,
  allow_nonstandard = FALSE
) {
  if (!allow_nonstandard && !any(abs(width_mm - allowed_width_mm) < 0.01)) {
    stop(
      "Nature export width must be 90 mm or 180 mm. ",
      "Got ", width_mm, " mm for ", filename, ".",
      call. = FALSE
    )
  }
  if (height_mm > max_height_mm) {
    stop(
      "Figure height exceeds ", max_height_mm, " mm: ",
      height_mm, " mm for ", filename, ".",
      call. = FALSE
    )
  }

  base <- tools::file_path_sans_ext(figure_path(filename))
  width_in <- width_mm / 25.4
  height_in <- height_mm / 25.4

  ggplot2::ggsave(
    filename = paste0(base, ".svg"),
    plot = plot,
    device = svglite::svglite,
    width = width_in,
    height = height_in,
    units = "in"
  )

  ggplot2::ggsave(
    filename = paste0(base, ".pdf"),
    plot = plot,
    device = grDevices::pdf,
    width = width_in,
    height = height_in,
    units = "in",
    family = "Helvetica",
    useDingbats = FALSE
  )

  ggplot2::ggsave(
    filename = paste0(base, ".tiff"),
    plot = plot,
    device = ragg::agg_tiff,
    width = width_in,
    height = height_in,
    units = "in",
    dpi = dpi,
    compression = "lzw"
  )

  ggplot2::ggsave(
    filename = paste0(base, ".png"),
    plot = plot,
    device = ragg::agg_png,
    width = width_in,
    height = height_in,
    units = "in",
    dpi = dpi
  )
}
