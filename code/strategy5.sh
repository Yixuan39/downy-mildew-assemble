#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
WORK_PATH="/data/run/yyang"
threads=32

for FILE in "${FILES[@]}"; do
    # Run diamond blastx on raw reads
    diamond blastx \
        --db ${WORK_PATH}/project_data/downy/diamond/${REF_FILE} \
        --query ${WORK_PATH}/project_data/downy/data/${FILE}.fastq.gz \
        --out ${WORK_PATH}/project_data/downy/strategy5/${INPUT_FILE}.csv \
        --al ${WORK_PATH}/project_data/downy/strategy5/${FILE}.oomycota.fastq.gz \
        --alfmt fastq \
        --header \
        --long-reads \
        --evalue 1e-10 \
        --max-target-seqs 1 \
        --max-hsps 1 \
        --very-sensitive \
        --outfmt 6 \
        --threads ${threads}
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${WORK_PATH}/project_data/downy/strategy5/${FILE}_asm \
        --in-hifi ${WORK_PATH}/project_data/downy/strategy5/${FILE}.oomycota.fastq.gz \
        --threads ${threads}
    # busco
    busco -i ${WORK_PATH}/project_data/downy/strategy5/${FILE}_asm/contigs.fasta \
        --out_path ${WORK_PATH}/project_data/downy/strategy5 \
        --out ${FILE}_busco \
        --mode genome \
        --auto-lineage-euk \
        --download_path ${WORK_PATH}/project_data/downy/busco_downloads \
        --cpu ${threads} \
        --force \
        --tar
    # quast
    quast.py --output-dir ${WORK_PATH}/project_data/downy/strategy5/${FILE}_quast \
        --threads ${threads} \
        --eukaryote \
        ${WORK_PATH}/project_data/downy/strategy5/${FILE}_asm/contigs.fasta
done