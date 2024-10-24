library(Biostrings)
library(here)

dna.path <- here('~/Desktop/ref-seq/')
protein.path <- here('~/Desktop/ref-seq-protein/')
if (!dir.exists(protein.path)) {dir.create(protein.path, showWarnings = FALSE)}
dna.files <- list.files(dna.path, full.names = TRUE)


for (i in 1:length(dna.files)) {
  dna <- readDNAStringSet(dna.files[i])
  protein <- translate(dna, if.fuzzy.codon = 'solve')
  writeXStringSet(protein, file.path(protein.path, basename(dna.files[i])))
}


