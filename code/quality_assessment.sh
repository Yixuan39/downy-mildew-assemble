#!/bin/bash

# input folder argument
input_folder=$1
threads=32
BUSCO_DB="/data/run/yyang/project_data/downy/BUSCO_DB"
# get the fasta file full name
files=$(find ${input_folder} -maxdepth 1 -name "*.fasta")

# busco
for file in ${files}; do
    busco --in ${file} \
          --out_path ${input_folder}/busco \
          --out $(basename ${file}) \
          --mode genome \
          --auto-lineage-euk \
          --download_path ${BUSCO_DB} \
          --cpu ${threads} \
          --force \
          --tar
done

# quast
quast.py --output-dir ${input_folder}/quast \
        --threads ${threads} \
        --eukaryote \
        ${files}