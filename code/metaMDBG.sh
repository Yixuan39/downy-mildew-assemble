#!/bin/bash

INPUT_FOLDER="/data/run/yyang/project_data/downy/data"
RESULT_PATH="/data/run/yyang/project_data/downy/metaMDBG"
FILES=$(ls ${INPUT_FOLDER}/*.fasta.gz)
threads=32
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    echo "Processing ${FILE}"
    # Assemble the raw reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}.asm \
        --in-hifi ${INPUT_FOLDER}/${FILE} \
        --threads ${threads}
    gzip -d ${RESULT_PATH}/${FILE}.asm/contigs.fasta.gz
    mv ${RESULT_PATH}/${FILE}.asm/contigs.fasta.gz ${RESULT_PATH}/${FILE}
    # remove unnecessary files
    rm -rf ${RESULT_PATH}/${FILE}.asm
done