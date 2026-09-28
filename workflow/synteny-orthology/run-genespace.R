#!/usr/bin/env Rscript
# GENESPACE over the genomes staged by stage-genomes.sh.
# OrthoFinder is not on PATH in the R environment, so the first run stops after writing tmp/;
# run orthofinder-contigs.sh, then run this script again to finish the synteny steps.
library(GENESPACE)

wd <- file.path(path.expand(Sys.getenv("PROJECT_DATA", "~/project_data/downy")), "results/synteny-orthology")
genomes <- sort(list.dirs(file.path(wd, "genomes"), full.names = FALSE, recursive = FALSE))
stopifnot(length(genomes) == 15)
path2mcscanx <- Sys.getenv("MCSCANX_DIR", dirname(Sys.which("MCScanX")))
stopifnot(file.exists(file.path(path2mcscanx, "MCScanX")))

if (!dir.exists(file.path(wd, "peptide"))) {
  parse_annotations(
    rawGenomeRepo = file.path(wd, "genomes"),
    genomeDirs = genomes,
    genomeIDs = genomes,
    headerSep = NA,
    headerEntryIndex = 1,
    gffIdColumn = "ID",
    genespaceWd = wd
  )
}
gpar <- init_genespace(wd = wd, nCores = 10, dotplots = "never", path2mcscanx = path2mcscanx)
run_genespace(gpar)
