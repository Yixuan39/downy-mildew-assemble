#!/usr/bin/env Rscript
# Proteins kept at each secretome/effectome step, per isolate -> results/secretome-effectome/secretome_counts.tsv
project_root <- path.expand(Sys.getenv("PROJECT_DATA", "~/project_data/downy"))
out_dir <- file.path(project_root, "results/secretome-effectome")
proteome_dir <- file.path(project_root, "results/repeatmask-gene-prediction/focal/helixer")
assemblies <- c("Pseudoperonospora_cubensis_MSU1", "Pseudoperonospora_cubensis_SC1982", "Pseudoperonospora_humuli_OR502AA")

n_ids <- function(file) length(readLines(file))
n_seqs <- function(file) sum(startsWith(readLines(file), ">"))

counts <- do.call(rbind, lapply(assemblies, function(asm) {
  step <- function(file) file.path(out_dir, asm, file)
  data.frame(
    isolate = asm,
    proteins = n_seqs(file.path(proteome_dir, paste0(asm, ".faa"))),
    signalp_cs10_40 = n_ids(step("signalp_cs10-40.ids")),
    no_mtp = n_ids(step("signalp_no_mtp.ids")),
    no_tm = n_ids(step("signalp_no_mtp_no_tm.ids")),
    gpi_anchored = n_ids(step("netgpi_gpi.ids")),
    soluble_secretome = n_seqs(step("soluble_secretome.faa")),
    effectorp3_effectors = n_seqs(step("effectorp3_effectors.faa"))
  )
}))
write.table(counts, file.path(out_dir, "secretome_counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
print(counts)
