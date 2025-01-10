#!/bin/bash

# input folder argument
input_folder=$1
threads=32
BUSCO_DB="/data/run/yyang/project_data/downy/BUSCO_DB"
# get the fasta file full name
files=$(find ${input_folder} -name "*.fasta")
out_dirs=$(dirname ${files} | sort | uniq)
echo ${out_dirs}

for out_dir in ${out_dirs}; do
    mkdir -p ${out_dir}/busco
    mkdir -p ${out_dir}/quast
    busco --in ${out_dir} \
          --out_path ${out_dir}/busco \
          --mode genome \
          --auto-lineage-euk \
          --download_path ${BUSCO_DB} \
          --cpu ${threads} \
          --force \
          --tar
    quast.py --output-dir ${out_dir}/quast \
            --threads ${threads} \
            --eukaryote \
            ${out_dir}
done