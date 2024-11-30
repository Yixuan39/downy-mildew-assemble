#!/bin/bash

# input folder argument
input_folder=$1
threads=32
BUSCO_DB="/data/run/yyang/project_data/downy/BUSCO_DB"
# get the fasta file full name
files=$(find ${input_folder} -maxdepth 1 -name "*.fasta")

# busco
busco -i  ${input_folder} \
        --out_path ${input_folder} \
        --out busco \
        --mode genome \
        --auto-lineage-euk \
        --download_path ${BUSCO_DB} \
        --cpu ${threads} \
        --force \
        --tar

# quast
quast.py --output-dir ${input_folder}/quast \
        --threads ${threads} \
        --eukaryote \
        ${files}