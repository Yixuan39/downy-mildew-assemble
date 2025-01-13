#!/bin/bash

INPUT_FOLDER="/data/run/yyang/project_data/downy/data"
RESULT_PATH="/data/run/yyang/project_data/downy/kraken2-asm-contam-protein/CS0"
KrakenDB="/data/run/yyang/project_data/downy/KrakenDB-contam-protein"
FILES=$(ls ${INPUT_FOLDER} | grep .fastq.gz | sed 's/.fastq.gz//g')
threads=32
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw reads
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --unclassified-out ${RESULT_PATH}/${FILE}.unclassified.fastq.gz \
        --confidence 0 \
        --gzip-compressed \
        ${INPUT_FOLDER}/${FILE}.fastq.gz
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}_asm \
        --in-hifi ${RESULT_PATH}/${FILE}.unclassified.fastq.gz \
        --threads ${threads}
    gzip -d ${RESULT_PATH}/${FILE}_asm/contigs.fasta.gz
    mv ${RESULT_PATH}/${FILE}_asm/contigs.fasta ${RESULT_PATH}/${FILE}.fasta
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    rm ${RESULT_PATH}/${FILE}.unclassified.fastq.gz
    rm -rf ${RESULT_PATH}/${FILE}_asm
done
