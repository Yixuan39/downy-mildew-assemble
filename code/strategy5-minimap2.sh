#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
INPUT_FOLDER="/data/run/yyang/project_data/downy/data"
RESULT_PATH="/data/run/yyang/project_data/downy/strategy5"
DB="/data/run/yyang/project_data/downy/diamond/oomycete.mmi"
BUSCO_DB="/data/run/yyang/project_data/downy/BUSCO_DB"
threads=32
mkdir -p ${RESULT_PATH}

for FILE in "${FILES[@]}"; do
    # Run minimap2 on raw reads
    minimap2 -ax map-hifi \
        -t ${threads} \
        ${DB} \
        ${INPUT_FOLDER}/${FILE}.fastq.gz | \
        samtools fastq -F 4 - | \
        gzip > ${RESULT_PATH}/${FILE}.oomycota.fastq.gz
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}_asm \
        --in-hifi ${RESULT_PATH}/${FILE}.oomycota.fastq.gz \
        --threads ${threads}
    gzip -d ${RESULT_PATH}/${FILE}_asm/contigs.fasta.gz
    mv ${RESULT_PATH}/${FILE}_asm/contigs.fasta ${RESULT_PATH}/${FILE}_asm.fasta
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.oomycota.fastq.gz
    rm -rf ${RESULT_PATH}/${FILE}_asm
    # busco
    busco -i  ${RESULT_PATH}/${FILE}_asm.fasta \
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