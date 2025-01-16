library(Biostrings)
library(stringr)

combine.genomes <- function(input.folder, output.file, AA = FALSE) {
    if (str_detect(output.file, 'gz')) {output.file <- fs::path_ext_remove(output.file)}
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
        pattern = "(fasta|fna)"
    )
    
    # Stop if no files are found
    if (length(ref.seq.files) == 0) {
        stop("No .fasta or .fna files found in the input folder!")
    }
    message('Processing files: ')
    message(str_c(ref.seq.files, collapse = '\n'))
    # read in files parallel
    genome.list <- lapply(ref.seq.files, function(file) {
        if(AA) {readAAStringSet(file)} else {readDNAStringSet(file)}
    })
    genome.list <- DNAStringSetList(genome.list)
    writeXStringSet(unlist(genome.list), output.file)
    system(paste0('pigz ', output.file))
}
combine.genomes('~/project_data/downy/oomycota-genome/', '~/project_data/downy/test/oomycota-genome.fasta.gz')
# combine.genomes('/data/run/yyang/project_data/downy/KrakenDB-contam-genome', '/data/run/yyang/project_data/downy/mmseqsDB/contam-genome.fasta.gz')
# combine.genomes('/data/run/yyang/project_data/downy/ref-seq', '/data/run/yyang/project_data/downy/mmseqsDB/extract-genome.fasta.gz')
# 
# combine.genomes('/data/run/yyang/project_data/downy/KrakenDB-contam-protein', '/data/run/yyang/project_data/downy/mmseqsDB/contam-protein.fasta.gz')
# combine.genomes('/data/run/yyang/project_data/downy/ref-seq-prot', '/data/run/yyang/project_data/downy/mmseqsDB/extract-protein.fasta.gz')