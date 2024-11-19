library(Biostrings)

ref.seq.files <- list.files(file.path('/data/run/yyang/project_data/downy/ref-seq-prot'), full.names = TRUE)
db.path <- file.path('/data/run/yyang/project_data/downy/diamond/oomycete')
genome.list <- AAStringSetList()
fasta.file <- tempfile(fileext = '.fasta')


for (file in ref.seq.files) {
    # annotate names
    seq <- readAAStringSet(file)
    names(seq) <- paste0(fs::path_ext_remove(basename(file)),'$', names(seq))
    genome.list[[file]] <- seq
}

writeXStringSet(unlist(unname(genome.list)), fasta.file)
build.diamond <- paste0('diamond makedb --in ', fasta.file, ' --db ', db.path, ' --threads 10')
message(build.diamond); system(build.diamond)