library(Biostrings)

combine.genomes <- function(input.folder, output.file, AA = FALSE) {
    if (file.exists(output.file)) {file.remove(output.file)}
    ref.seq.files <- list.files(input.folder, full.names = TRUE, recursive = TRUE, pattern = "\\.(fasta|fna)$")
    for (file in ref.seq.files) {
        message('Processing ', file)
        if (AA) {
            seq <- readAAStringSet(file)
        } else {
            seq <- readDNAStringSet(file)
        }
        writeXStringSet(seq, output.file, format = 'fasta', append = TRUE, compress = TRUE)
    }
}


combine.genomes('/archive/yyang/project_data/downy/KrakenDB-contam-genome', '/data/run/yyang/project_data/downy/mmseqsDB/contam-genome.fasta.gz')
combine.genomes('/archive/yyang/project_data/downy/ref-seq', '/data/run/yyang/project_data/downy/mmseqsDB/extract-genome.fasta.gz')

combine.genomes('/archive/yyang/project_data/downy/KrakenDB-contam-protein', '/data/run/yyang/project_data/downy/mmseqsDB/contam-protein.fasta.gz', AA = TRUE)
combine.genomes('/archive/yyang/project_data/downy/ref-seq-prot', '/data/run/yyang/project_data/downy/mmseqsDB/extract-protein.fasta.gz', AA = TRUE)