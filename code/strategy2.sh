#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
WORK_PATH="/data/run/yyang"
threads=32

for FILE in "${FILES[@]}"; do
    # Run kraken2 on raw reads
    kraken2 --db ${WORK_PATH}/project_data/downy/KrakenDB-contam \
        --threads ${threads} \
        --output ${WORK_PATH}/project_data/downy/strategy2/${FILE}.kraken \
        --report ${WORK_PATH}/project_data/downy/strategy2/${FILE}.kreport \
        --unclassified-out ${WORK_PATH}/project_data/downy/strategy2/${FILE}.unclassified.fastq.gz \
        --gzip-compressed \
        ${WORK_PATH}/project_data/downy/data/${FILE}.fastq.gz
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${WORK_PATH}/project_data/downy/strategy2/${FILE}_asm \
        --in-hifi ${WORK_PATH}/project_data/downy/strategy2/${FILE}.unclassified.fastq.gz \
        --threads ${threads}
    # busco
    busco -i ${WORK_PATH}/project_data/downy/strategy2/${FILE}_asm/contigs.fasta \
        --out_path ${WORK_PATH}/project_data/downy/strategy2 \
        --out ${FILE}_busco \
        --mode genome \
        --auto-lineage-euk \
        --download_path ${WORK_PATH}/project_data/downy/busco_downloads \
        --cpu ${threads} \
        --force \
        --tar
    # quast
    quast.py --output-dir ${WORK_PATH}/project_data/downy/strategy2/${FILE}_quast \
        --threads ${threads} \
        --eukaryote \
        ${WORK_PATH}/project_data/downy/strategy2/${FILE}_asm/contigs.fasta
done