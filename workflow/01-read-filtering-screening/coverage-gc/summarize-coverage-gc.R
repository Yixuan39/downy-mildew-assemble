#!/usr/bin/env Rscript

# ----------------------------------------------------------------------------------------
# Purpose : Join per-read Kraken2 taxonomy, per-read GC content (seqkit fx2tab) and per-read
#           21-mer self-coverage (KAT sect) into the two tables analysis/read-distribution.Rmd
#           plots for the coverage-vs-GC blob plot (Supp. Fig. S3): a stratified per-isolate,
#           per-category read subsample for the scatter, and per-category summary statistics
#           computed from the full read sets. A read's category is its Kraken2 phylum-level
#           ancestor, with any phylum below 5% of that isolate's reads collapsed to "Other" -
#           the same rule the taxonomy-composition-bar figure in the same notebook uses.
# Inputs  : ${PROJECT_DATA}/results/read-filtering-screening/taxonomy/<sample>.{kraken,kreport}
#           ${PROJECT_DATA}/results/read-filtering-screening/coverage-gc/<sample>-gc.tsv (seqkit)
#           ${PROJECT_DATA}/results/read-filtering-screening/coverage-gc/<sample>-sect-stats.tsv (KAT)
#           ${DB_ROOT}/kraken2/PlusPFP/{nodes,names}.dmp (the taxonomy dump Kraken2 itself used)
# Outputs : data/blobplot-read-coverage-gc-subsample.tsv
#           data/blobplot-category-summary-by-isolate.tsv
# Runs on : NCSU BRC (needs the real, cluster-side per-read Kraken2/coverage-gc data and the
#           PlusPFP taxonomy dump); local R plus `taxonkit` on PATH (or set TAXONKIT_BIN)
# Usage   : Rscript workflow/01-read-filtering-screening/coverage-gc/summarize-coverage-gc.R
# Notes   : Matches read IDs on the first whitespace-delimited token of the KAT/seqkit "name"
#           field, not the whole field - the SRA-derived P. effusa reads carry extra
#           space-separated description text after the accession that Kraken2 itself ignores.
# ----------------------------------------------------------------------------------------

source(here::here("analysis", "lib", "paths.R"))
suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(here)
})
source(here("analysis", "lib", "read-kraken-report.R"))
clean_taxon <- function(x) str_remove(x, "^[a-z]_")

# isolate short code (matches the "isolate" column consumed by read-distribution.Rmd) ->
# Kraken2 taxonomy basename -> coverage-gc basename (differ only for P. effusa).
isolates <- tibble::tribble(
  ~isolate,   ~taxonomy_sample,        ~coverage_sample,
  "MSU1",     "Quesada_SQIIe_MSU1",    "Quesada_SQIIe_MSU1",
  "SC1982",   "Quesada_SQIIe_SC1982",  "Quesada_SQIIe_SC1982",
  "Phumuli",  "Quesada_SQIIe_Phumuli", "Quesada_SQIIe_Phumuli",
  "UA202013", "p_effusa",              "p_effusa"
)

# taxID -> phylum name, resolved once for every distinct taxID Kraken2 assigned across all
# four isolates, via taxonkit against the same PlusPFP taxonomy dump Kraken2 itself used.
#
# An earlier version of this script tried to get this mapping "for free" from
# read_report2(..., collapse = FALSE) - the per-isolate .kreport already carries a phylum
# ancestor column for every KEPT-rank row. That only works by accident when collapse = TRUE:
# collapsing first removes the "no rank" clades NCBI's taxonomy is full of between named
# ranks, so every surviving row's immediate predecessor in the flattened report is guaranteed
# to be its true parent at a kept rank. Skip the collapse step and that guarantee disappears -
# most read-level taxIDs (whose immediate ancestor in the RAW report is a "no rank" node, not
# a kept-rank one) silently got no phylum at all, inflating "Other" and erasing whole phyla
# (Streptophyta, Chordata) that the taxonomy-composition-bar figure elsewhere on this page
# shows are real double-digit percentages of these libraries. taxonkit walks the actual
# parent-child tree instead of a flattened report, so it isn't affected by rank sparsity.
TAXONKIT_BIN <- Sys.getenv("TAXONKIT_BIN", file.path(Sys.getenv("HOME"), "miniforge3/envs/downy/bin/taxonkit"))
TAXDUMP_DIR <- db_path("kraken2/PlusPFP")

message("=== resolving taxID -> phylum via taxonkit ===")
all_taxids <- isolates$taxonomy_sample |>
  map(\(s) fread(project_path("results/read-filtering-screening/taxonomy", paste0(s, ".kraken")),
                 select = 3, col.names = "taxID", showProgress = FALSE)$taxID) |>
  unlist() |>
  unique()
all_taxids <- all_taxids[all_taxids != 0]
message("  ", length(all_taxids), " distinct non-zero taxIDs across all isolates")

taxid_file <- tempfile(fileext = ".txt")
writeLines(as.character(all_taxids), taxid_file)
phylum_lines <- system2(
  TAXONKIT_BIN,
  c("reformat", "-I", "1", "-f", shQuote("{p}"), "--data-dir", TAXDUMP_DIR, taxid_file),
  stdout = TRUE, stderr = FALSE
)
unlink(taxid_file)
taxid_phylum <- fread(text = phylum_lines, header = FALSE, sep = "\t",
                       col.names = c("taxID", "phylum"), colClasses = "character", showProgress = FALSE) |>
  mutate(phylum = na_if(phylum, ""))

set.seed(1)
MAX_PER_CATEGORY <- 3000

subsample_list <- list()
summary_list <- list()

for (i in seq_len(nrow(isolates))) {
  isolate <- isolates$isolate[i]
  tax_sample <- isolates$taxonomy_sample[i]
  cov_sample <- isolates$coverage_sample[i]
  message("=== ", isolate, " ===")

  kreport_file <- project_path("results/read-filtering-screening/taxonomy", paste0(tax_sample, ".kreport"))
  kraken_file  <- project_path("results/read-filtering-screening/taxonomy", paste0(tax_sample, ".kraken"))
  gc_file      <- project_path("results/read-filtering-screening/coverage-gc", paste0(cov_sample, "-gc.tsv"))
  sect_file    <- project_path("results/read-filtering-screening/coverage-gc", paste0(cov_sample, "-sect-stats.tsv"))

  # Phylum-level percentages from the (default, collapsed) report - identical rule to the
  # taxonomy-composition-bar chunk: any phylum below 5% of this isolate's reads is "Other".
  rpt_collapsed <- read_report2(kreport_file, add_taxRank_columns = TRUE)
  phylum_category <- rpt_collapsed |>
    filter(taxRank == "P") |>
    transmute(phylum = clean_taxon(name), category = if_else(percentage < 5, "Other", phylum))

  # Per-read category: look up each read's assigned taxID -> phylum (via taxonkit, above) ->
  # Other/kept category. Unclassified reads (taxID 0) and reads with no phylum-rank ancestor
  # (e.g. assigned above phylum, at "cellular organisms" or root) both fall out of the phylum
  # join; unclassified is kept as its own category, no-phylum-ancestor reads become "Other".
  reads <- fread(kraken_file, select = c(1, 2, 3, 4),
                 col.names = c("status", "read_id", "taxID", "length"), showProgress = FALSE) |>
    mutate(taxID = as.character(taxID)) |>
    left_join(taxid_phylum, by = "taxID") |>
    left_join(phylum_category, by = "phylum") |>
    mutate(category = case_when(
      taxID == "0" ~ "unclassified",
      is.na(category) ~ "Other",
      TRUE ~ category
    )) |>
    select(read_id, category)

  gc <- fread(gc_file, header = FALSE, col.names = c("read_id", "gc_pct"), showProgress = FALSE) |>
    mutate(read_id = word(read_id, 1))
  cov <- fread(sect_file, select = c("seq_name", "median"), showProgress = FALSE) |>
    rename(read_id = seq_name, cov_median = median) |>
    mutate(read_id = word(read_id, 1))

  joined <- reads |>
    inner_join(gc, by = "read_id") |>
    inner_join(cov, by = "read_id") |>
    mutate(isolate = isolate)

  summary_list[[isolate]] <- joined |>
    group_by(isolate, category) |>
    summarise(
      n_reads = n(),
      gc_mean = mean(gc_pct),
      cov_mean_of_medians = mean(cov_median),
      .groups = "drop"
    )

  subsample_list[[isolate]] <- joined |>
    group_by(category) |>
    group_modify(~ slice_sample(.x, n = min(MAX_PER_CATEGORY, nrow(.x)))) |>
    ungroup() |>
    select(isolate, read_id, category, gc_pct, cov_median)

  message("  ", nrow(joined), " reads joined across taxonomy/GC/coverage")
}

subsample <- bind_rows(subsample_list)
summary_tbl <- bind_rows(summary_list)

write_tsv(subsample, here("data", "blobplot-read-coverage-gc-subsample.tsv"))
write_tsv(summary_tbl, here("data", "blobplot-category-summary-by-isolate.tsv"))

message("wrote ", nrow(subsample), " subsampled reads and ", nrow(summary_tbl), " category summary rows")
