library(ggplot2)

out <- "data/tidk_telomeres"
fig_out <- "figures/tidk_telomeres"
dir.create(fig_out, recursive = TRUE, showWarnings = FALSE)

focal <- c("Pseudoperonospora_cubensis_MSU1",
           "Pseudoperonospora_cubensis_SC1982",
           "Pseudoperonospora_humuli_OR502AA")

plot_data <- do.call(rbind, lapply(file.path(out, focal), function(dir) {
  sample <- basename(dir)
  x <- read.delim(file.path(dir, paste0(sample, ".TTTAGGG_telomeric_repeat_windows.tsv")))
  keep <- head(read.delim(file.path(dir, "lengths.tsv"), header = FALSE)[[1]], 20)
  x <- x[x$id %in% keep, ]
  x$sample <- sample
  x$count <- x$forward_repeat_number + x$reverse_repeat_number
  x$position_Mb <- x$window / 1e6
  x
}))

p <- ggplot(plot_data, aes(position_Mb, count)) +
  geom_col(width = 0.01, position = "identity") +
  facet_wrap(~id, scales = "free_x", ncol = 1) +
  theme_bw() +
  labs(x = "Position on contig (Mb)", y = "TTTAGGG / CCCTAAA count")

ggsave(file.path(fig_out, "tidk_telomere_profiles_top20_contigs.pdf"), p, width = 7, height = 60, limitsize = FALSE)
