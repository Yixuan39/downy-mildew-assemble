#!/bin/bash

# input folder argument
input_folder=$1
threads=32
# get the fasta file full name
files=$(find ${input_folder} -name "*.fasta")
dirs=$(dirname ${files} | sort | uniq)

for dir in ${dirs}; do
    echo "Processing ${dir}"
    files=$(find ${dir} -name "*.fasta")
    quast.py --output-dir ${dir}/quast \
            --threads ${threads} \
            --eukaryote \
            ${files}
done
