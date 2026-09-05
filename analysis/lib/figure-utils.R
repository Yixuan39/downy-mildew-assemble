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
