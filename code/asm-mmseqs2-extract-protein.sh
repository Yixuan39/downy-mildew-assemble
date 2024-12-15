#!/bin/bash

INPUT_FOLDER="/data/run/yyang/project_data/downy/metaMDBG"
RESULT_PATH="/data/run/yyang/project_data/downy/asm-mmseqs2-extract-protein"
DB="/data/run/yyang/project_data/downy/combined_seqs/oomycota.fasta.gz"
FILES=$(ls ${INPUT_FOLDER} | grep .fasta | sed 's/.fasta//g')
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
        ${INPUT_FOLDER}/${FILE}.fasta \
        ${DB} \
        ${RESULT_PATH}/${FILE}.sam \
        ${RESULT_PATH}/${FILE}.tmp \
        --search-type 2 --translation-mode 1 --format-mode 1
    # extract the reads
    samtools fasta ${RESULT_PATH}/${FILE}.sam > ${RESULT_PATH}/${FILE}.fasta
    rm ${RESULT_PATH}/${FILE}.sam
    rm -rf ${RESULT_PATH}/${FILE}.tmp
done