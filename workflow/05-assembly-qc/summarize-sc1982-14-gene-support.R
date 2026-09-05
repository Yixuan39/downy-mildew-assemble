#!/usr/bin/env Rscript

# ----------------------------------------------------------------------------------------
# Purpose : Summarise the annotation and read support for the 14 genes in the SC1982 region of interest, as
#           reported in the text.
# Inputs  : data/sc1982_gap_tail_coverage/ and the annotation tables under data/
# Outputs : the summary table used in the manuscript text
# Runs on : local, R
# Usage   : Rscript workflow/05-assembly-qc/summarize-sc1982-14-gene-support.R
# ----------------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(GenomicAlignments)
  library(Rsamtools)
})

bam <- "data/sc1982_gap_tail_coverage/SC1982_hifi_to_Pcub-SC1982_002.primary.bam"
gff <- "$HOME/project_data/downy/contigs-renamed/helixer/Pseudoperonospora_cubensis_SC1982.gff"
proteins <- "data/sc1982_gap_tail_coverage/Pcub-SC1982_002_14_fungal_hit_proteins.faa"
output <- "data/sc1982_gap_tail_coverage/Pcub-SC1982_002_14_genes_coverage_and_read_support.tsv"
contig <- "Pcub-SC1982_002"
mapq <- 20L
flank <- 1000L

stopifnot(file.exists(bam), file.exists(gff), file.exists(proteins))

protein_ids <- sub("^>([^[:space:]]+).*$", "\\1", grep("^>", readLines(proteins), value = TRUE))
stopifnot(length(protein_ids) == 14L, !anyDuplicated(protein_ids))

gff_data <- read.delim(
  gff, sep = "\t", header = FALSE, comment.char = "#", quote = "",
  col.names = c("contig", "source", "type", "start", "end", "score", "strand", "phase", "attributes")
)
models <- gff_data[gff_data$contig == contig & gff_data$type == "mRNA", ]
models$protein_id <- sub("^ID=([^;]+).*$", "\\1", models$attributes)
models <- models[match(protein_ids, models$protein_id), ]
stopifnot(!anyNA(models$protein_id))

target_lengths <- scanBamHeader(bam)[[1]]$targets
stopifnot(contig %in% names(target_lengths))
contig_length <- unname(target_lengths[[contig]])
target <- GRanges(contig, IRanges(1L, contig_length))

primary_reads <- scanBamFlag(
  isUnmappedQuery = FALSE,
  isSecondaryAlignment = FALSE,
  isSupplementaryAlignment = FALSE,
  isNotPassingQualityControls = FALSE,
  isDuplicate = FALSE
)

# Exact per-base depth; deletions are not counted as covered bases.
pile <- pileup(
  bam,
  scanBamParam = ScanBamParam(which = target, flag = primary_reads),
  pileupParam = PileupParam(
    max_depth = 1000000L,
    min_base_quality = 0L,
    min_mapq = mapq,
    distinguish_strands = FALSE,
    distinguish_nucleotides = FALSE,
    include_deletions = FALSE,
    include_insertions = FALSE
  )
)
depth <- integer(contig_length)
depth[pile$pos] <- pile$count

# Alignment coordinates are used to count distinct reads spanning each locus.
alignments <- readGAlignments(
  bam,
  use.names = TRUE,
  param = ScanBamParam(which = target, mapqFilter = mapq, flag = primary_reads)
)

summarize_depth <- function(values) {
  c(
    mean_depth_mapq20 = mean(values),
    median_depth_mapq20 = median(values),
    covered_fraction_mapq20 = mean(values > 0L)
  )
}

contig_stats <- summarize_depth(depth)
gene_stats <- t(vapply(
  seq_len(nrow(models)),
  function(i) summarize_depth(depth[models$start[i]:models$end[i]]),
  numeric(3)
))

alignment_start <- start(alignments)
alignment_end <- end(alignments)
read_names <- names(alignments)

count_reads <- function(i, with_flanks = FALSE) {
  extra <- if (with_flanks) flank else 0L
  keep <- alignment_start <= models$start[i] - extra &
    alignment_end >= models$end[i] + extra
  length(unique(read_names[keep]))
}

results <- data.frame(
  feature_type = "gene",
  feature_id = models$protein_id,
  contig = models$contig,
  start_1based = models$start,
  end_1based = models$end,
  strand = models$strand,
  length_bp = models$end - models$start + 1L,
  mean_depth_mapq20 = round(gene_stats[, "mean_depth_mapq20"], 3),
  median_depth_mapq20 = gene_stats[, "median_depth_mapq20"],
  covered_fraction_mapq20 = round(gene_stats[, "covered_fraction_mapq20"], 6),
  full_gene_spanning_reads_mapq20 = vapply(seq_len(nrow(models)), count_reads, integer(1)),
  gene_internal_in_read_with_1kb_flanks_mapq20 = vapply(
    seq_len(nrow(models)), count_reads, integer(1), with_flanks = TRUE
  )
)

contig_row <- data.frame(
  feature_type = "contig",
  feature_id = contig,
  contig = contig,
  start_1based = 1L,
  end_1based = contig_length,
  strand = ".",
  length_bp = contig_length,
  mean_depth_mapq20 = round(contig_stats[["mean_depth_mapq20"]], 3),
  median_depth_mapq20 = contig_stats[["median_depth_mapq20"]],
  covered_fraction_mapq20 = round(contig_stats[["covered_fraction_mapq20"]], 6),
  full_gene_spanning_reads_mapq20 = NA_integer_,
  gene_internal_in_read_with_1kb_flanks_mapq20 = NA_integer_
)

write.table(
  rbind(contig_row, results), output, sep = "\t", row.names = FALSE,
  col.names = TRUE, quote = FALSE, na = "NA"
)

message("Created ", output)
