#!/bin/bash

INPUT_FOLDER="/data/run/yyang/project_data/downy/data"
RESULT_PATH="/data/run/yyang/project_data/downy/kraken2-asm-extract-protein/CS0"
KrakenDB="/data/run/yyang/project_data/downy/KrakenDB-whole-protein"
FILES=$(ls ${INPUT_FOLDER} | grep .fastq.gz | sed 's/.fastq.gz//g')
threads=32
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw reads
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --confidence 0 \
        --gzip-compressed \
        ${INPUT_FOLDER}/${FILE}.fastq.gz
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
        -k ${RESULT_PATH}/${FILE}.kraken \
        -s ${INPUT_FOLDER}/${FILE}.fastq.gz \
        --taxid 4762 \
        --output ${RESULT_PATH}/${FILE}.oomycota.fastq \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --include-children \
        --fastq-output
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}_asm \
        --in-hifi ${RESULT_PATH}/${FILE}.oomycota.fastq \
        --threads ${threads}
    gzip -d ${RESULT_PATH}/${FILE}_asm/contigs.fasta.gz
    mv ${RESULT_PATH}/${FILE}_asm/contigs.fasta ${RESULT_PATH}/${FILE}.fasta
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    rm ${RESULT_PATH}/${FILE}.oomycota.fastq
    rm -rf ${RESULT_PATH}/${FILE}_asm
done