# Stage 2 of 3. NetGPI 1.1 GPI-anchor prediction through the DTU web server (ragp client).
# Run on the login node: compute nodes have no internet. Sends each isolate's
# signalp_no_mtp_no_tm.faa to services.healthtech.dtu.dk.
library(ragp)

project_data <- Sys.getenv("PROJECT_DATA", file.path(Sys.getenv("HOME"), "project_data/downy"))
assemblies <- c("Pseudoperonospora_cubensis_MSU1",
                "Pseudoperonospora_cubensis_SC1982",
                "Pseudoperonospora_humuli_OR502AA")

for (asm in assemblies) {
  out <- file.path(project_data, "results/secretome-effectome", asm)
  faa <- file.path(out, "signalp_no_mtp_no_tm.faa")
  res <- get_netGPI(data = faa)
  n_in <- length(grep("^>", readLines(faa)))
  stopifnot(nrow(res) == n_in, !anyNA(res$is.gpi))
  write.table(res, file.path(out, "netgpi.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
  message(asm, ": ", sum(res$is.gpi), " GPI-anchored of ", n_in)
}
