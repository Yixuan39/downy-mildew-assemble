#!/bin/bash

INPUT_FOLDER=$HOME/project_data/downy/data
RESULT_PATH=$HOME/project_data/downy/metaMDBG
FILES=$(ls ${INPUT_FOLDER}/*.fastq.gz 2>/dev/null | xargs -n 1 basename)
threads=24
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    echo "Processing ${FILE}"
    # Assemble the raw reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}.asm \
        --in-hifi ${INPUT_FOLDER}/${FILE} \
        --threads ${threads}
    mv ${RESULT_PATH}/${FILE}.asm/contigs.fasta.gz ${RESULT_PATH}/${FILE%.fastq.gz}.fasta.gz
    # remove unnecessary files
    rm -rf ${RESULT_PATH}/${FILE}.asm
done