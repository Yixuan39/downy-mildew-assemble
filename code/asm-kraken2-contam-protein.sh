#!/bin/bash

INPUT_FOLDER="/data/run/yyang/project_data/downy/metaMDBG"
RESULT_PATH="/data/run/yyang/project_data/downy/asm-kraken2-contam-protein/CS0"
KrakenDB="/data/run/yyang/project_data/downy/KrakenDB-contam-protein"
FILES=$(ls ${INPUT_FOLDER} | grep .fasta | sed 's/.fasta//g')
threads=32
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw reads
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --unclassified-out ${RESULT_PATH}/${FILE}.fasta \
        --confidence 0 \
        ${INPUT_FOLDER}/${FILE}.fasta
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
done
