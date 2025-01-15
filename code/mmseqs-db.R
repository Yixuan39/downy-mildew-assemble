library(stringr)


combine.genomes <- function(input.folder, output.file) {
    # Check if output file exists and remove it
    if (file.exists(output.file)) {
        file.remove(output.file)
    }
    
    # Ensure the output directory exists
    output.dir <- dirname(output.file)
    if (!dir.exists(output.dir)) {
        dir.create(output.dir, recursive = TRUE)
    }
    
    # List relevant files
    ref.seq.files <- list.files(
        input.folder,
        full.names = TRUE,
        recursive = TRUE,
        pattern = "\\.(fasta|fna)$"
    )
    
    # Stop if no files are found
    if (length(ref.seq.files) == 0) {
        stop("No .fasta or .fna files found in the input folder!")
    }
    message(str_c("processing ", ref.seq.files))
    # Quote file paths to handle spaces and special characters
    quoted_files <- str_c(shQuote(ref.seq.files), collapse = " ")
    
    # Build and execute the system command
    command <- str_glue("cat {quoted_files} | gzip > {shQuote(output.file)}")
    system(command)
}

combine.genomes('/data/run/yyang/project_data/downy/KrakenDB-contam-genome', '/data/run/yyang/project_data/downy/mmseqsDB/contam-genome.fasta.gz')
combine.genomes('/data/run/yyang/project_data/downy/ref-seq', '/data/run/yyang/project_data/downy/mmseqsDB/extract-genome.fasta.gz')

combine.genomes('/data/run/yyang/project_data/downy/KrakenDB-contam-protein', '/data/run/yyang/project_data/downy/mmseqsDB/contam-protein.fasta.gz')
combine.genomes('/data/run/yyang/project_data/downy/ref-seq-prot', '/data/run/yyang/project_data/downy/mmseqsDB/extract-protein.fasta.gz')