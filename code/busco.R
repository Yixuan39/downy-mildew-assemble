#!/usr/bin/env Rscript
library(cogeqc)

files <- list.files('~/project_data/downy/ref-seq/', full.names = TRUE)
outpath <- '~/project_data/downy/busco_results'
if (!dir.exists(outpath)) {dir.create(outpath)}
max.core <- 24

for (file in files){
    run_busco(file,
              outlabel = basename(file),
              mode = 'genome', auto_lineage = 'prok',
              outpath = outpath, 
              force = TRUE, 
              threads = max.core,
              download_path = '~/project_data/downy/busco_downloads')
}
