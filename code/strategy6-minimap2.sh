#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")
INPUT_FOLDER="/data/run/yyang/project_data/downy/metaMDBG"
RESULT_PATH="/data/run/yyang/project_data/downy/strategy6"
DB="/data/run/yyang/project_data/downy/combined_seqs/oomycota-genome.fasta.gz"
threads=32
mkdir -p ${RESULT_PATH}

for FILE in "${FILES[@]}"; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
        ${INPUT_FOLDER}/${FILE}.fasta \
        ${DB} \
        ${RESULT_PATH}/${FILE}.sam \
        /tmp \
        --search-type 3 --format-mode 1
    # extract the reads
    samtools fasta ${RESULT_PATH}/${FILE}.sam > ${RESULT_PATH}/${FILE}.fasta
done