#!/usr/bin/env Rscript

max.core <- parallel::detectCores()
files <- list.files('~/project_data/downy/ref-seq/', full.names = TRUE)
outpath <- '~/project_data/downy/busco_results/'
if (!dir.exists(outpath)) {dir.create(outpath)}
download_path <- '~/project_data/downy/busco_downloads'

for (file in files){
    cmd <- paste0('busco ', 
                  '--in ', file, ' ',
                  '--out ', fs::path_ext_remove(basename(file)), ' ',
                  '--out_path ', outpath, ' ',
                  '--mode genome ',
                  '--auto-lineage-euk ',
                  '--force ',
                  '--offline ',
                  '--cpu ', max.core, ' ',
                  '--tar ',
                  '--download_path ', download_path)
    message(cmd);system(cmd)
}