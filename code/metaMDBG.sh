#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
INPUT_FOLDER="/data/run/yyang/project_data/downy/data"
RESULT_PATH="/data/run/yyang/project_data/downy/metaMDBG"

threads=32
mkdir -p ${RESULT_PATH}

for FILE in "${FILES[@]}"; do
    # Assemble the raw reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}_asm \
        --in-hifi ${INPUT_FOLDER}/${FILE}.fastq.gz \
        --threads ${threads}
    gzip -d ${RESULT_PATH}/${FILE}_asm/contigs.fasta.gz
    mv ${RESULT_PATH}/${FILE}_asm/contigs.fasta ${RESULT_PATH}/${FILE}.fasta
    # remove unnecessary files
    rm -rf ${RESULT_PATH}/${FILE}_asm
done