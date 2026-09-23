library(tidyverse)
library(Biostrings)
library(rtracklayer)
library(here)

# samples
samples <- c(
  "Peronospora_effusa_UA202013_star",
  "Pseudoperonospora_cubensis_MSU1",
  "Pseudoperonospora_humuli_OR502AA",
  "Pseudoperonospora_cubensis_SC1982"
)
requested <- Sys.getenv("SAMPLE", "")
if (nzchar(requested)) {
  stopifnot(requested %in% samples)
  samples <- requested
}

project_root <- path.expand(Sys.getenv("PROJECT_DATA", "~/project_data/downy"))
base_dir <- file.path(project_root, "results/functional-annotation")
proteome_dir <- file.path(project_root, "results/repeatmask-gene-prediction/focal/helixer")
rnaseq_result_dir <- file.path(project_root, "results/rnaseq-support")
secretome_result_dir <- file.path(project_root, "results/secretome-effectome")

isolate_patterns <- c(
  Peronospora_effusa_UA202013_star = "^Peff-",
  Pseudoperonospora_cubensis_MSU1 = "^Pcub-MSU1_",
  Pseudoperonospora_humuli_OR502AA = "^Phum-OR502AA_",
  Pseudoperonospora_cubensis_SC1982 = "^Pcub-SC1982_"
)

rnaseq_prefixes <- c(
  Peronospora_effusa_UA202013_star = NA_character_,
  Pseudoperonospora_cubensis_MSU1 = "Pcub_MSU1",
  Pseudoperonospora_humuli_OR502AA = "Phum_OR502AA",
  Pseudoperonospora_cubensis_SC1982 = "Pcub_SC1982"
)
remove_final_period <- function(description) {
  str_replace(str_trim(description), "\\.+$", "")
}

keep_first_sentence <- function(description) {
  str_replace(description, "\\.\\s+.*$", "")
}

normalize_eggnog_description <- function(description) {
  description <- case_when(
    is.na(description) ~ "unknown function",
    description == "-" ~ "unknown function",
    TRUE ~ description
  ) |>
    str_squish() |>
    remove_final_period()
  
  case_when(
    str_detect(description, regex("\\bdomain$", ignore_case = TRUE)) ~ "domain-containing protein",
    str_detect(description, regex("\\bdomains$", ignore_case = TRUE)) ~ "domain-containing protein",
    str_length(description) > 50 ~ keep_first_sentence(description),
    TRUE ~ description
  )
}

format_blastp_description <- function(sseqid, sspecies) {
  sspecies <- str_squish(str_replace_na(sspecies, "N/A"))
  
  if_else(
    sspecies == "N/A" | sspecies == "",
    str_c("Homology to predicted protein ", sseqid),
    str_c("Homology to ", sspecies, " predicted protein ", sseqid)
  )
}

read_id_set <- function(file) {
  read_lines(file, progress = FALSE) |>
    str_trim() |>
    discard(~ !nzchar(.x)) |>
    unique()
}

read_rnaseq_max_tpm <- function(rnaseq_dir, prefix) {
  if (is.na(prefix)) {
    return(tibble(gene_id = character(), max_tpm = double()))
  }

  file <- file.path(rnaseq_dir, prefix, "star_salmon", "salmon.merged.gene_tpm.tsv")
  tpm <- read_tsv(file, comment = "#", show_col_types = FALSE)
  tpm_columns <- setdiff(names(tpm), c("gene_id", "gene_name"))
  values <- tpm |>
    select(all_of(tpm_columns)) |>
    mutate(across(everything(), as.numeric)) |>
    as.matrix()

  tibble(
    gene_id = str_replace(tpm$gene_id, "[.]\\d+$", ""),
    max_tpm = apply(values, 1, max, na.rm = TRUE)
  ) |>
    mutate(max_tpm = if_else(is.infinite(max_tpm), NA_real_, max_tpm))
}

add_secretome_effectome_flags <- function(annotation_table, isolate) {
  flag_files <- c(
    soluble_secretome = file.path(secretome_result_dir, isolate, "soluble_secretome.ids"),
    effectome = file.path(secretome_result_dir, isolate, "effectome.ids")
  )

  flag_sets <- map(flag_files, read_id_set)
  annotation_table |>
    mutate(
      soluble_secretome = id %in% flag_sets$soluble_secretome,
      effectome = id %in% flag_sets$effectome
    )
}

build_annotation_support_table <- function(annotation_table) {
  map_dfr(samples, function(isolate) {
    isolate_table <- annotation_table |>
      filter(str_detect(id, isolate_patterns[isolate])) |>
      mutate(
        isolate = isolate,
        gene_id = str_replace(id, "[.]\\d+$", "")
      ) |>
      left_join(
        read_rnaseq_max_tpm(rnaseq_result_dir, rnaseq_prefixes[isolate]),
        by = "gene_id"
      ) |>
      mutate(rna_supported_tpm_ge_2 = !is.na(max_tpm) & max_tpm >= 2)

    add_secretome_effectome_flags(isolate_table, isolate)
  })
}

protein.function.tb <- data.frame()

for (sample in samples) {
  
  message("Summarizing functions: ", sample)
  eggnog_file       <- file.path(base_dir,"eggnog-mapper",sample,paste0(sample, ".emapper.annotations"))
  interproscan_file <- file.path(base_dir,"interproscan",sample,paste0(sample, ".faa.gff3"))
  blastp_file       <- file.path(base_dir,"blastp",paste0(sample, ".tsv"))
  faa_file          <- file.path(proteome_dir,paste0(sample, ".faa"))
  
  protein_ids <- sub(" .*", "", names(readAAStringSet(faa_file)))
  blastp.table <- read_tsv(blastp_file,show_col_types = FALSE) |> 
    filter(evalue < 1e-10) |>
    filter(length/slen >= 0.5) # for blstp, we also require at least 50% coverage of the subject sequence
  eggnog.table <- read_tsv(eggnog_file,show_col_types = FALSE,comment = "##") |> filter(evalue < 1e-10)
  interproscan.table <- readGFF(interproscan_file) |>
    as.data.frame() |>
    as_tibble() |>
    mutate(
      seqid = as.character(seqid),
      score = as.numeric(score),
      Name = as.character(Name),
      signature_desc = as.character(signature_desc),
      signature_desc = na_if(signature_desc, "character(0)"),
      Name = na_if(Name, "character(0)")
    ) |>
    filter(!is.na(score), score < 1e-10)
  
  sample_protein_function.tb <- data.frame()
  
  # ponytail: per-protein scan is adequate for ~20k proteins; use ranked joins for larger proteomes.
  for (id in protein_ids) {
    has_eggnog <- id %in% eggnog.table$`#query`
    eggnog_descriptions <- eggnog.table$Description[eggnog.table$`#query` == id]
    if (has_eggnog && any(eggnog_descriptions != "-", na.rm = TRUE)) {
      row <- eggnog.table |> 
        filter(`#query` == id, Description != "-") |>
        arrange(evalue) |>
        dplyr::slice(1) |> 
        transmute(
          id = id,
          source = "eggnog",
          Description = str_c(
            normalize_eggnog_description(Description),
            if_else(
              !is.na(Preferred_name) & Preferred_name != "-",
              str_c(" (", Preferred_name, ")"),
              ""
            )
          )
        )
      sample_protein_function.tb <- bind_rows(sample_protein_function.tb, row)
    } else if (id %in% interproscan.table$seqid) {
      
      row <- interproscan.table |>
        filter(seqid == id) |>
        arrange(score) |>
        dplyr::slice(1) |>
        transmute(
          id = id,
          source = "interproscan",
          Description = case_when(
            !is.na(signature_desc) & !is.na(Name) ~ str_c(signature_desc, " (", Name, ")"),
            !is.na(signature_desc) ~ signature_desc,
            !is.na(Name) ~ str_c(Name, " domain-containing protein"),
            TRUE ~ "InterProScan hit with no functional description"
          )
        )
      
      sample_protein_function.tb <- bind_rows(sample_protein_function.tb, row)
      
    } else if (id %in% blastp.table$qseqid) {
      
      row <- blastp.table |>
        filter(qseqid == id) |>
        arrange(evalue) |>
        dplyr::slice(1) |>
        transmute(
          id = id,
          source = "blastp",
          Description = format_blastp_description(sseqid, sspecies)
        )
      
      sample_protein_function.tb <- bind_rows(sample_protein_function.tb, row)
      
    } else {
      
      row <- data.frame(
        id = id,
        source = "unannotated",
        Description = "Hypothetical protein of unknown function"
      )
      
      sample_protein_function.tb <- bind_rows(sample_protein_function.tb, row)
    }
  }
  
  sample_protein_function.tb <- sample_protein_function.tb |>
    mutate(Description = remove_final_period(Description))
  
  protein.function.tb <- bind_rows(protein.function.tb, sample_protein_function.tb)
}

annotation_support <- build_annotation_support_table(protein.function.tb) |>
  select(
    id,
    isolate,
    gene_id,
    source,
    Description,
    max_tpm,
    rna_supported_tpm_ge_2,
    soluble_secretome,
    effectome
  )

write_tsv(annotation_support, here("data", "annotation_support.tsv"))
