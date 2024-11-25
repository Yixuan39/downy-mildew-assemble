#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
WORK_PATH="/data/run/yyang"
threads=32
mkdir -p ${WORK_PATH}/project_data/downy/strategy1

for FILE in "${FILES[@]}"; do
    # Run kraken2 on raw reads
    kraken2 --db ${WORK_PATH}/project_data/downy/KrakenDB-prot \
        --threads ${threads} \
        --output ${WORK_PATH}/project_data/downy/strategy1/${FILE}.kraken \
        --report ${WORK_PATH}/project_data/downy/strategy1/${FILE}.kreport \
        --gzip-compressed \
        ${WORK_PATH}/project_data/downy/data/${FILE}.fastq.gz
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
        -k ${WORK_PATH}/project_data/downy/strategy1/${FILE}.kraken \
        -s ${WORK_PATH}/project_data/downy/data/${FILE}.fastq.gz \
        --taxid 4762 \
        --output ${WORK_PATH}/project_data/downy/strategy1/${FILE}.oomycota.fastq \
        --report ${WORK_PATH}/project_data/downy/strategy1/${FILE}.kreport \
        --include-children \
        --fastq-output
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${WORK_PATH}/project_data/downy/strategy1/${FILE}_asm \
        --in-hifi ${WORK_PATH}/project_data/downy/strategy1/${FILE}.oomycota.fastq \
        --threads ${threads}
    # busco
    busco -i ${WORK_PATH}/project_data/downy/strategy1/${FILE}_asm/contigs.fasta \
        --out_path ${WORK_PATH}/project_data/downy/strategy1 \
        --out ${FILE}_busco \
        --mode genome \
        --auto-lineage-euk \
        --download_path ${WORK_PATH}/project_data/downy/busco_downloads \
        --cpu ${threads} \
        --force \
        --tar
    # quast
    quast.py --output-dir ${WORK_PATH}/project_data/downy/strategy1/${FILE}_quast \
        --threads ${threads} \
        --eukaryote \
        ${WORK_PATH}/project_data/downy/strategy1/${FILE}_asm/contigs.fasta
done