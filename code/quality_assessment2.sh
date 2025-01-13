#!/bin/bash

# input folder argument
input_folder=$1
threads=4
BUSCO_DB="/data/run/yyang/project_data/downy/BUSCO_DB"
# get the fasta file full name
files=$(find ${input_folder} -name "*.fasta")
dirs=$(dirname ${files} | sort | uniq)

for dir in ${dirs}; do
    echo "Processing ${dir}"
    busco --in ${dir} \
          --mode genome \
          --auto-lineage-euk \
          --download_path ${BUSCO_DB} \
          --cpu ${threads} \
          --force \
          --tar
    quast.py --output-dir ${dir}/quast \
            --threads ${threads} \
            --eukaryote \
            ${files}
done
