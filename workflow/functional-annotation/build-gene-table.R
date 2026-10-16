#!/usr/bin/env Rscript
# One Excel sheet per isolate, one row per gene: location, protein length, functional annotation
# (data/annotation_support.tsv from summarize-functions.R), RNA-seq TPM per sample, and the
# secretome/effectome steps (SignalP 6, TargetP 2, DeepTMHMM, NetGPI, EffectorP 3).
# Run in the R environment (env/R.yml); writes data/gene_annotation_summary.xlsx.
library(tidyverse)
library(Biostrings)
library(here)
library(writexl)

project_root <- path.expand(Sys.getenv("PROJECT_DATA", "~/project_data/downy"))
helixer_dir <- file.path(project_root, "results/repeatmask-gene-prediction/focal/helixer")
rnaseq_dir <- file.path(project_root, "results/rnaseq-support")
secretome_dir <- file.path(project_root, "results/secretome-effectome")

isolates <- tribble(
  ~sheet,    ~assembly,                           ~rnaseq,
  "MSU1",    "Pseudoperonospora_cubensis_MSU1",   "Pcub_MSU1",
  "SC1982",  "Pseudoperonospora_cubensis_SC1982", "Pcub_SC1982",
  "OR502AA", "Pseudoperonospora_humuli_OR502AA",  "Phum_OR502AA"
)
not_tested <- "not tested"
annotation <- read_tsv(here("data", "annotation_support.tsv"), show_col_types = FALSE)

read_ids <- function(file) readLines(file)
first_number <- function(x) as.numeric(str_match(x, "([0-9.]+)")[, 2])

build_sheet <- function(assembly, rnaseq) {
  out <- file.path(secretome_dir, assembly)

  genes <- read_tsv(file.path(helixer_dir, paste0(assembly, ".gff")), comment = "#", col_names = FALSE,
                    col_types = "cccii-c-c") |>
    filter(X3 == "gene") |>
    transmute(gene_id = str_match(X9, "ID=([^;]+)")[, 2], contig = X1, start = X4, end = X5, strand = X7)

  proteins <- readAAStringSet(file.path(helixer_dir, paste0(assembly, ".faa")))
  proteins <- tibble(
    protein_id = sub(" .*", "", names(proteins)),
    protein_length_aa = nchar(str_remove(as.character(proteins), "[.*]$"))
  ) |>
    mutate(gene_id = str_remove(protein_id, "[.]\\d+$"))

  tpm <- read_tsv(file.path(rnaseq_dir, rnaseq, "star_salmon", "salmon.merged.gene_tpm.tsv"),
                  show_col_types = FALSE) |>
    select(-gene_name) |>
    rename_with(~ str_c("TPM_", .x), -gene_id)

  signalp <- read_tsv(file.path(out, "signalp6", "prediction_results.txt"), skip = 2, col_names = FALSE,
                      col_types = "ccddc") |>
    transmute(protein_id = X1, SignalP6_prediction = X2, SignalP6_SP_probability = X4,
              SignalP6_cleavage_site = first_number(X5))
  signalp_pass <- read_ids(file.path(out, "signalp_cs10-40.ids"))

  targetp <- read_tsv(file.path(out, "targetp2", paste0(assembly, "_summary.targetp2")), skip = 2,
                      col_names = FALSE, col_types = "ccdddc") |>
    transmute(protein_id = X1, TargetP2_prediction = X2, TargetP2_mTP_probability = X5)
  no_mtp <- read_ids(file.path(out, "signalp_no_mtp.ids"))

  topo <- read_lines(file.path(out, "deeptmhmm", "predicted_topologies.3line"))
  deeptmhmm <- tibble(header = topo[str_starts(topo, ">")]) |>
    transmute(protein_id = str_match(header, "^>(\\S+)")[, 2],
              DeepTMHMM_topology = str_trim(str_match(header, "\\|\\s*(.+)$")[, 2]))
  tm_after_cs <- read_ids(file.path(out, "deeptmhmm_tm.ids"))
  no_tm <- read_ids(file.path(out, "signalp_no_mtp_no_tm.ids"))

  netgpi <- read_tsv(file.path(out, "netgpi.tsv"), show_col_types = FALSE) |>
    transmute(protein_id = id, NetGPI_GPI_anchored = if_else(is.gpi, "yes", "no"), NetGPI_omega_site = omega_site)
  soluble <- read_ids(file.path(out, "soluble_secretome.ids"))

  effectorp <- read_tsv(file.path(out, "effectorp3.tsv"), comment = "#", col_names = FALSE, col_types = "ccccc") |>
    transmute(protein_id = X1, EffectorP3_prediction = X5, EffectorP3_cytoplasmic = first_number(X2),
              EffectorP3_apoplastic = first_number(X3), EffectorP3_non_effector = first_number(X4))

  sheet <- proteins |>
    left_join(genes, by = "gene_id") |>
    left_join(annotation |> select(protein_id = id, annotation_source = source,
                                   functional_description = Description, max_TPM = max_tpm,
                                   RNA_supported_TPM_ge_2 = rna_supported_tpm_ge_2), by = "protein_id") |>
    left_join(tpm, by = "gene_id") |>
    left_join(signalp, by = "protein_id") |>
    mutate(SignalP_cleavage_10_40 = if_else(protein_id %in% signalp_pass, "yes", "no")) |>
    left_join(targetp, by = "protein_id") |>
    left_join(deeptmhmm, by = "protein_id") |>
    mutate(DeepTMHMM_TM_after_cleavage = case_when(protein_id %in% tm_after_cs ~ "yes",
                                                   protein_id %in% no_tm ~ "no",
                                                   TRUE ~ not_tested)) |>
    left_join(netgpi, by = "protein_id") |>
    mutate(soluble_secretome = if_else(protein_id %in% soluble, "yes", "no")) |>
    left_join(effectorp, by = "protein_id") |>
    mutate(across(c(TargetP2_prediction, DeepTMHMM_topology, NetGPI_GPI_anchored, EffectorP3_prediction),
                  ~ replace_na(.x, not_tested))) |>
    select(gene_id, protein_id, contig, start, end, strand, protein_length_aa, annotation_source,
           functional_description, starts_with("TPM_"), max_TPM, RNA_supported_TPM_ge_2,
           starts_with("SignalP"), starts_with("TargetP"), starts_with("DeepTMHMM"), starts_with("NetGPI"),
           soluble_secretome, starts_with("EffectorP")) |>
    arrange(contig, start)

  # every protein is in SignalP; each later tool saw exactly the proteins that passed the step before
  stopifnot(nrow(sheet) == nrow(proteins), !anyNA(sheet$functional_description), !anyNA(sheet$SignalP6_prediction),
            sum(sheet$TargetP2_prediction != not_tested) == length(signalp_pass),
            sum(sheet$DeepTMHMM_topology != not_tested) == length(no_mtp),
            sum(sheet$NetGPI_GPI_anchored != not_tested) == length(no_tm),
            sum(sheet$EffectorP3_prediction != not_tested) == length(soluble))
  sheet
}

sheets <- setNames(map2(isolates$assembly, isolates$rnaseq, build_sheet), isolates$sheet)
write_xlsx(sheets, here("data", "gene_annotation_summary.xlsx"))
walk2(names(sheets), sheets, ~ message(.x, ": ", nrow(.y), " genes, ", sum(.y$soluble_secretome == "yes"),
                                       " soluble secretome, ", sum(.y$EffectorP3_prediction %in% c("Cytoplasmic effector",
                                       "Apoplastic effector", "Apoplastic/cytoplasmic effector", "Cytoplasmic/apoplastic effector")),
                                       " EffectorP effectors"))
