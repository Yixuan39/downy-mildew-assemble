
path.in <- '~/project_data/downy/oomycota-genome'
path.out <- '~/project_data/downy/oomycota-protein'
dir.create(path.out, recursive = TRUE, showWarnings = FALSE)

# List all input files
files <- list.files(path.in, full.names = TRUE)

# Loop through each file
for (file in files) {
    message('Processing ', file)
    command <- paste0("gzip -d --to-stdout ",file, " | transeq -sequence stdin -outseq ", file.path(path.out, basename(file)))
    system(command)
}


path.in <- '~/project_data/downy/contam-genome'
path.out <- '~/project_data/downy/contam-protein'
dir.create(path.out, recursive = TRUE, showWarnings = FALSE)

files <- list.files(path.in, full.names = TRUE)

for (file in files) {
    message('Processing ', file)
    command <- paste0("gzip -d --to-stdout ",file, " | transeq -sequence stdin -outseq ", file.path(path.out, basename(file)))
    system(command)
}

