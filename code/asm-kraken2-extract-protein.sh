#!/bin/bash

INPUT_FOLDER="/data/run/yyang/project_data/downy/metaMDBG"
RESULT_PATH="/data/run/yyang/project_data/downy/asm-kraken2-extract-protein/CS0"
KrakenDB="/data/run/yyang/project_data/downy/KrakenDB-whole-protein"
FILES=$(ls ${INPUT_FOLDER} | grep .fasta | sed 's/.fasta//g')
threads=32
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw assembly
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --confidence 0 \
        ${INPUT_FOLDER}/${FILE}.fasta
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
        -k ${RESULT_PATH}/${FILE}.kraken \
        -s ${INPUT_FOLDER}/${FILE}.fasta \
        --taxid 4762 \
        --output ${RESULT_PATH}/${FILE}.fasta \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --include-children
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
done