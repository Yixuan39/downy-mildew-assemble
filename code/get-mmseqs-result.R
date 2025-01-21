library(argparser)
library(data.table)
library(Biostrings)
library(fs)

p <- arg_parser("convert mmseqs result to fasta")
p <- add_argument(p, "--file", help = "file name of original data")
p <- add_argument(p, "--mmseq", help = "file name of mmseqs result")
p <- add_argument(p, "--evalue", help = "evalue threshold")
p <- add_argument(p, "--output", help = "output file")
argv <- parse_args(p)


message('Processing ', p$mmseq)
# read tsv file
data <- fread(p$mmseq)
# filter by evalue
data <- data[evalue <= p$evalue]
seq <- readDNAStringSet(p$file)
# write to fasta
out.path <- file.path(dirname(p$output))
if (!dir.exists(out.path)) {dir.create(out.path, recursive = TRUE)}
writeXStringSet(seq, file.path(p$output), format = 'fasta', compress = TRUE)