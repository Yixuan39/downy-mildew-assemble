#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
INPUT_FOLDER="/data/run/yyang/project_data/downy/data"
RESULT_PATH="/data/run/yyang/project_data/downy/strategy3"
KrakenDB="/data/run/yyang/project_data/downy/KrakenDB-prot"
BUSCO_DB="/data/run/yyang/project_data/downy/BUSCO_DB"
threads=32
mkdir -p ${RESULT_PATH}

for FILE in "${FILES[@]}"; do
    # Assemble the raw reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}_asm \
        --in-hifi  ${INPUT_FOLDER}/${FILE}.fastq.gz \
        --threads ${threads}
    # Run kraken2 on raw assembly
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --confidence 0.8 \
        --gzip-compressed \
        ${RESULT_PATH}/${FILE}_asm/contigs.fasta.gz
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
        -k ${RESULT_PATH}/${FILE}.kraken \
        -s ${INPUT_FOLDER}/${FILE}.fastq.gz \
        --taxid 4762 \
        --output ${RESULT_PATH}/${FILE}_asm.fasta \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --include-children
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    rm -rf ${RESULT_PATH}/${FILE}_asm
    # busco
    busco -i ${RESULT_PATH}/${FILE}_asm.fasta \
        --out_path ${RESULT_PATH} \
        --out ${FILE}_busco \
        --mode genome \
        --auto-lineage-euk \
        --download_path ${BUSCO_DB} \
        --cpu ${threads} \
        --force \
        --tar
    # quast
    quast.py --output-dir ${RESULT_PATH}/${FILE}_quast \
        --threads ${threads} \
        --eukaryote \
        ${RESULT_PATH}/${FILE}_asm.fasta
done