#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
INPUT_FOLDER="/data/run/yyang/project_data/downy/data"
RESULT_PATH="/data/run/yyang/project_data/downy/strategy6"
DB="/data/run/yyang/project_data/downy/diamond/oomycete.mmi"
BUSCO_DB="/data/run/yyang/project_data/downy/BUSCO_DB"
threads=32
mkdir -p ${RESULT_PATH}

for FILE in "${FILES[@]}"; do
    # Assemble the raw reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}_asm \
        --in-hifi  ${INPUT_FOLDER}/${FILE}.fastq.gz \
        --threads ${threads}
    # Run minimap2 on raw assembly
    minimap2 -ax asm20 \
        -t ${threads} \
        ${DB} \
        ${RESULT_PATH}/${FILE}_asm/contigs.fasta.gz | \
        samtools fasta -F 4 - | \
        gzip > ${RESULT_PATH}/${FILE}_asm.fasta
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