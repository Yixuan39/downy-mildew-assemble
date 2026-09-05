source(here::here("analysis", "lib", "paths.R"))
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

base_dir <- project_path("results/functional-annotation")
proteome_dir <- project_path("results/repeatmask-gene-prediction/focal/helixer")
rnaseq_result_dir <- project_path("results/rnaseq-support")
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

read_rnaseq_gene_counts <- function(rnaseq_dir) {
  count_files <- list.files(
    rnaseq_dir,
    pattern = "^salmon[.]merged[.]gene_counts[.]tsv$",
    recursive = TRUE,
    full.names = TRUE
  )

  if (length(count_files) == 0) {
    return(tibble(gene_id = character()))
  }

  count_files |>
    map(\(file) {
      counts <- read_tsv(file, comment = "#", show_col_types = FALSE)
      count_columns <- setdiff(names(counts), c("gene_id", "gene_name"))

      counts |>
        select(gene_id, all_of(count_columns)) |>
        rename_with(
          \(column) str_c("rnaseq_gene_count_", column),
          all_of(count_columns)
        )
    }) |>
    purrr::reduce(full_join, by = "gene_id")
}

add_rnaseq_gene_counts <- function(annotation_table, rnaseq_dir) {
  rnaseq_gene_counts <- read_rnaseq_gene_counts(rnaseq_dir)
  annotation_table <- annotation_table |>
    select(
      -starts_with("rnaseq_tpm_"),
      -starts_with("rnaseq_count_"),
      -starts_with("rnaseq_gene_count_"),
      -any_of("rnaseq_gene_id"),
      -any_of("rnaseq_join_id")
    )

  if (length(intersect(annotation_table$id, rnaseq_gene_counts$gene_id)) > 0) {
    annotation_table <- annotation_table |>
      mutate(rnaseq_join_id = id)
  } else {
    annotation_table <- annotation_table |>
      mutate(rnaseq_join_id = str_replace(id, "[.][0-9]+$", ""))
  }

  annotation_table |>
    left_join(rnaseq_gene_counts, by = c("rnaseq_join_id" = "gene_id")) |>
    select(-rnaseq_join_id)
}

write_isolate_annotation_tables <- function(annotation_table, output_dir) {
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  
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
  
  for (isolate in samples) {
    isolate_table <- annotation_table |>
      filter(str_detect(id, isolate_patterns[isolate]))
    
    rnaseq_prefix <- rnaseq_prefixes[isolate]
    if (!is.na(rnaseq_prefix)) {
      isolate_table <- isolate_table |>
        select(
          id,
          source,
          Description,
          contains(str_c("rnaseq_gene_count_", rnaseq_prefix))
        )
    } else {
      isolate_table <- isolate_table |>
        select(id, source, Description)
    }
    
    write_tsv(isolate_table, file.path(output_dir, str_c(isolate, "_protein_function_summary.tsv")))
  }
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

protein.function.tb <- add_rnaseq_gene_counts(protein.function.tb, rnaseq_result_dir)

write_isolate_annotation_tables(protein.function.tb, here("data", "protein_function_by_isolate"))
