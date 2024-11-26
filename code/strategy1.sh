#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
INPUT_FOLDER="/data/run/yyang/project_data/downy/data"
RESULT_PATH="/data/run/yyang/project_data/downy/strategy1"
KrakenDB="/data/run/yyang/project_data/downy/KrakenDB-prot"
BUSCO_DB="/data/run/yyang/project_data/downy/BUSCO_DB"
threads=32
mkdir -p RESULT_PATH

for FILE in "${FILES[@]}"; do
    # Run kraken2 on raw reads
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
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
    mv ${RESULT_PATH}/${FILE}_asm/contigs.fasta ${RESULT_PATH}/${FILE}_asm.fasta
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    rm ${RESULT_PATH}/${FILE}.oomycota.fastq
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