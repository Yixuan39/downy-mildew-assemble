#!/bin/bash

INPUT_FOLDER=/data/run/yyang/project_data/downy/metaMDBG
RESULT_PATH=/data/run/yyang/project_data/downy/result/asm-mmseq-extract-genome/
DB=/data/run/yyang/project_data/downy/mmseqsDB/oomycota-genome.fasta.gz
FILES=$(ls ${INPUT_FOLDER} | grep .fasta | sed 's/.fasta//g')
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE}.fasta \
    ${DB} \
    ${RESULT_PATH}/${FILE}.tsv \
    ${INPUT_FOLDER}/${FILE} \
    -e 10 \
    --max-seqs 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query,qseq,evalue
done