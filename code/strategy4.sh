#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
WORK_PATH="/data/run/yyang"
threads=32
mkdir -p ${WORK_PATH}/project_data/downy/strategy4

for FILE in "${FILES[@]}"; do
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${WORK_PATH}/project_data/downy/strategy4/${FILE}_asm \
        --in-hifi ${WORK_PATH}/project_data/downy/data/${FILE}.fastq.gz \
        --threads ${threads}
    # Run kraken2 on raw reads
    kraken2 --db ${WORK_PATH}/project_data/downy/KrakenDB-contam \
        --threads ${threads} \
        --output ${WORK_PATH}/project_data/downy/strategy4/${FILE}.kraken \
        --report ${WORK_PATH}/project_data/downy/strategy4/${FILE}.kreport \
        --unclassified-out ${WORK_PATH}/project_data/downy/strategy4/${FILE}.unclassified.fasta \
        --gzip-compressed \
        ${WORK_PATH}/project_data/downy/strategy4/${FILE}_asm/contigs.fasta
    # busco
    busco -i ${WORK_PATH}/project_data/downy/strategy4/${FILE}.unclassified.fasta \
        --out_path ${WORK_PATH}/project_data/downy/strategy4 \
        --out ${FILE}_busco \
        --mode genome \
        --auto-lineage-euk \
        --download_path ${WORK_PATH}/project_data/downy/busco_downloads \
        --cpu ${threads} \
        --force \
        --tar
    # quast
    quast.py --output-dir ${WORK_PATH}/project_data/downy/strategy4/${FILE}_quast \
        --threads ${threads} \
        --eukaryote \
        ${WORK_PATH}/project_data/downy/strategy4/${FILE}.unclassified.fasta
done