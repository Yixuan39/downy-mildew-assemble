
# ----------------------------------------------------------------------------------------
# Purpose : Plot the tidk telomere-repeat density along each long contig. Called at the end of tidk-
#           telomere-long-contigs.sh.
# Inputs  : ${PROJECT_DATA}/results/telomeres/*/
# Outputs : ${PROJECT_DATA}/results/telomeres/figures/
# Runs on : ncsu-brc login node or the short partition; R with ggplot2.
# Usage   : Rscript workflow/06-telomeres/plot-tidk-telomeres.R (needs PROJECT_DATA set - source workflow/paths.sh first)
# ----------------------------------------------------------------------------------------
library(ggplot2)

project_data <- Sys.getenv("PROJECT_DATA", unset = NA)
if (is.na(project_data)) stop("PROJECT_DATA not set - source workflow/paths.sh first")
out <- file.path(project_data, "results", "telomeres")
fig_out <- file.path(out, "figures")
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
