#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
WORK_PATH="/data/run/yyang"
threads=32

for FILE in "${FILES[@]}"; do
    # Assemble the raw reads
    metaMDBG asm \
        --out-dir ${WORK_PATH}/project_data/downy/strategy3/${FILE}_asm \
        --in-hifi  ${WORK_PATH}/project_data/downy/data/${FILE}.fastq.gz \
        --threads ${threads}
    # Run kraken2 on raw assembly
    kraken2 --db ${WORK_PATH}/project_data/downy/KrakenDB-prot \
        --threads ${threads} \
        --output ${WORK_PATH}/project_data/downy/strategy3/${FILE}.kraken \
        --report ${WORK_PATH}/project_data/downy/strategy3/${FILE}.kreport \
        --gzip-compressed \
        ${WORK_PATH}/project_data/downy/strategy3/${FILE}_asm/contigs.fasta
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
        -k ${WORK_PATH}/project_data/downy/strategy3/${FILE}.kraken \
        -s ${WORK_PATH}/project_data/downy/data/${FILE}.fastq.gz \
        -t 4762 \
        -o ${WORK_PATH}/project_data/downy/strategy3/${FILE}.oomycota.fasta
        -r ${WORK_PATH}/project_data/downy/strategy3/${FILE}.kreport \
        --include-children
    # busco
    busco -i ${WORK_PATH}/project_data/downy/strategy3/${FILE}.oomycota.fasta \
        --out_path ${WORK_PATH}/project_data/downy/strategy3 \
        --out ${FILE}_busco \
        --mode genome \
        --auto-lineage-euk \
        --download_path ${WORK_PATH}/project_data/downy/busco_downloads \
        --cpu ${threads} \
        --force \
        --tar
    # quast
    quast.py --output-dir ${WORK_PATH}/project_data/downy/strategy3/${FILE}_quast \
        --threads ${threads} \
        --eukaryote \
        ${WORK_PATH}/project_data/downy/strategy3/${FILE}.oomycota.fasta
done