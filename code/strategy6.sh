#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
INPUT_FOLDER="/data/run/yyang/project_data/downy/data"
RESULT_PATH="/data/run/yyang/project_data/downy/strategy6"
DIAMOND_DB="/data/run/yyang/project_data/downy/diamond/oomycete.dmnd"
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
    diamond blastx \
        --db ${DIAMOND_DB} \
        --query ${RESULT_PATH}/${FILE}_asm/contigs.fasta \
        --out ${RESULT_PATH}/${FILE}.csv \
        --al ${RESULT_PATH}/${FILE}_asm.fasta \
        --alfmt fasta \
        --header \
        --long-reads \
        --evalue 1e-10 \
        --max-target-seqs 1 \
        --max-hsps 1 \
        --very-sensitive \
        --outfmt 6 \
        --threads ${threads}
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