library(data.table)
library(Biostrings)
library(fs)

path <- '/data/run/yyang/project_data/downy/mmseqs_result/'
# set evalue
evalues <- c(1e-5, 1e-10, 1e-15, 1e-20)

files <- list.files(path = path, full.names = TRUE, recursive = TRUE, pattern = '.tsv')
if (length(files) == 0) {stop('No .tsv files found in the input folder!')}

for (ev in evalues) {
    for (file in files) {
        message('Processing ', file)
        # read tsv file
        data <- fread(file)
        # filter by evalue
        data <- data[evalue <= ev]
        seq <- DNAStringSet(data$qseq)
        names(seq) <- data$query
        # write to fasta
        out.path <- file.path(dirname(file), ev)
        if (!dir.exists(out.path)) {dir.create(out.path, recursive = TRUE)}
        writeXStringSet(seq, file.path(out.path, paste0(fs::path_ext_remove(basename(file)), '.fasta.gz')), format = 'fasta', compress = TRUE)
    }
}