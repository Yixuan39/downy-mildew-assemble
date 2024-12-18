#!/bin/bash

INPUT_FOLDER="/data/run/yyang/project_data/downy/metaMDBG"
RESULT_PATH="/data/run/yyang/project_data/downy/asm-mmseq-contam-genome"
DB="/data/run/yyang/project_data/downy/combined_seqs/contam-genome.fasta"
FILES=$(ls ${INPUT_FOLDER} | grep .fasta | sed 's/.fasta//g')
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE}.fasta \
    ${DB} \
    ${RESULT_PATH}/${FILE}.txt \
    ${INPUT_FOLDER}/${FILE} \
    -e 1e-10 \
    --max-seqs 1 \
    --search-type 3 \
    --format-mode 0 \
    --format-output query

    python get_seq.py remove ${INPUT_FOLDER}/${FILE}.fasta ${RESULT_PATH}/${FILE}.txt ${RESULT_PATH}/${FILE}.fasta
done