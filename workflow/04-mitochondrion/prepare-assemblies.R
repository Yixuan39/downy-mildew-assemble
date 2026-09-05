#!/usr/bin/env Rscript
# Rename targetasm contigs by length and partition mitochondrial candidates before nuclear QC.
# Run from the repository root: Rscript workflow/04-mitochondrion/prepare-assemblies.R
library(Biostrings)
source(here::here("analysis", "lib", "paths.R"))

samples <- data.frame(
  run = c("UA202013", "Quesada_SQIIe_MSU1", "Quesada_SQIIe_SC1982", "Quesada_SQIIe_Phumuli"),
  prefix = c("Peff-26", "Pcub-MSU1", "Pcub-SC1982", "Phum-OR502AA"),
  assembly = c("Peronospora_effusa_UA202013_star", "Pseudoperonospora_cubensis_MSU1",
               "Pseudoperonospora_cubensis_SC1982", "Pseudoperonospora_humuli_OR502AA")
)
root <- project_path("results/assembly-qc")
renamed <- file.path(root, "renamed")
mito <- file.path(root, "mitochondrial")
clean <- file.path(root, "nuclear-presplit")
reference <- project_path("inputs/reference-mitochondria", "KT072718.1.fna")
inputs <- project_path("results/assembly", samples$run, paste0(samples$run, ".fasta.gz"))
outputs <- file.path(clean, paste0(samples$assembly, ".fasta.gz"))
stopifnot(file.exists(reference), all(file.exists(inputs)))
if (any(file.exists(outputs))) stop("Cleaned assemblies already exist; use a fresh results tree to rebuild.")
for (dir in c(root, renamed, mito, clean)) dir.create(dir, recursive = TRUE, showWarnings = FALSE)

partition_assembly <- function(i) {
  seqs <- readDNAStringSet(inputs[i])
  seqs <- seqs[order(width(seqs), decreasing = TRUE)]
  names(seqs) <- sprintf("%s_%03d", samples$prefix[i], seq_along(seqs))
  filename <- paste0(samples$assembly[i], ".fasta.gz")
  writeXStringSet(seqs, file.path(renamed, filename), compress = TRUE)
  query <- tempfile(fileext = ".fasta")
  on.exit(unlink(query))
  writeXStringSet(seqs, query)
  hits_file <- file.path(mito, paste0(samples$assembly[i], ".mito.tsv"))
  status <- system2("blastn", c("-query", shQuote(query), "-subject", shQuote(reference),
    "-outfmt", shQuote("6 qseqid sseqid pident length qlen slen evalue"),
    "-max_target_seqs", "1", "-max_hsps", "1", "-out", shQuote(hits_file)))
  if (status != 0) stop("BLASTN failed for ", samples$assembly[i])
  ids <- character()
  if (file.info(hits_file)$size > 0) {
    hits <- read.delim(hits_file, header = FALSE)
    # Apply the 10% threshold before rounding for display.
    ids <- hits$V1[hits$V4 / hits$V5 >= 0.1]
  }
  is_mito <- names(seqs) %in% ids
  writeXStringSet(seqs[!is_mito], file.path(clean, filename), compress = TRUE)
  writeXStringSet(seqs[is_mito], file.path(mito, filename), compress = TRUE)
  data.frame(assembly = samples$assembly[i], mitochondrial_contigs = sum(is_mito),
             mitochondrial_bases = sum(width(seqs)[is_mito]))
}
summary <- do.call(rbind, lapply(seq_len(nrow(samples)), partition_assembly))
write.table(summary, file.path(mito, "partition-summary.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
