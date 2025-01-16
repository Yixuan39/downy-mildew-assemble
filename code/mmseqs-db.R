library(tidyverse)

combine.genomes <- function(input.folder, output.file, AA = FALSE) {
    # Check if output file exists and remove it
    if (file.exists(output.file)) {file.remove(output.file)}
    # Ensure the output directory exists
    dir.create(dirname(output.file), recursive = TRUE, showWarnings = FALSE)
    
    # List relevant files
    ref.seq.files <- list.files(
        input.folder,
        full.names = TRUE,
        recursive = TRUE,
        pattern = "(fasta|fna)"
    ) %>% str_subset('.masked', negate = TRUE)
    
    # Stop if no files are found
    if (length(ref.seq.files) == 0) {stop("No .fasta or .fna files found in the input folder!")}
    message('Processing files: ', str_c(ref.seq.files, collapse = '\n'))
    # concate files
    system(paste0('cat ', str_c(ref.seq.files, collapse = ' '), ' | pigz > ', output.file))
}

combine.genomes('/data/run/yyang/project_data/downy/KrakenDB-contam-genome', '/data/run/yyang/project_data/downy/mmseqsDB/contam-genome.fasta.gz')
combine.genomes('/data/run/yyang/project_data/downy/ref-seq', '/data/run/yyang/project_data/downy/mmseqsDB/extract-genome.fasta.gz')

combine.genomes('/data/run/yyang/project_data/downy/KrakenDB-contam-protein', '/data/run/yyang/project_data/downy/mmseqsDB/contam-protein.fasta.gz', AA = TRUE)
combine.genomes('/data/run/yyang/project_data/downy/ref-seq-prot', '/data/run/yyang/project_data/downy/mmseqsDB/extract-protein.fasta.gz', AA = TRUE)