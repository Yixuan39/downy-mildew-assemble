#!/bin/bash

# input folder argument
input_folder=$HOME/project_data/downy/Kraken-result/
GX_DB=$HOME/project_data/downy/fcs-db/
# get the fasta file full name
files=$(find ${input_folder} -name "*.fasta.gz")
dirs=$(dirname ${files} | sort | uniq)

for dir in ${dirs}; do
    out_dir=${dir}/verification
    mkdir -p ${out_dir}
    echo "Processing ${dir}"
    files=$(find ${dir} -name "*.fasta.gz")
    for file in ${files}; do
        run_gx.py --fasta ${file} \
                  --tax-id 4762 \
                  --gx-db ${GX_DB} \
                  --out-dir ${out_dir} \
                  --out-basename $(basename ${file%.fasta.gz}) 
    done
done