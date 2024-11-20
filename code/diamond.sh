#!/bin/bash
#SBATCH -c 32
#SBATCH --mem=0

# Define the arrays of files and reference files
FILES=("MSU1" "Phumuli" "SC1982")
WORK_PATH="/data/run/yyang"
REF_FILE="oomycete.dmnd"
threads=32
        
for INPUT_FILE in "${FILES[@]}"; do

    echo "Running DIAMOND for ${INPUT_FILE} against ${REF_FILE}..."

    # Run DIAMOND blastx
    diamond blastx \
        --db ${WORK_PATH}/project_data/downy/diamond/${REF_FILE} \
        --query ${WORK_PATH}/project_data/downy/meta-asm/${INPUT_FILE}/contigs.fasta.gz \
        --out ${WORK_PATH}/project_data/downy/diamond/${INPUT_FILE}.csv \
        --al ${WORK_PATH}/project_data/downy/diamond/${INPUT_FILE}.fasta \
        --evalue 1e-10 \
        --max-target-seqs 1 \
        --max-hsps 1 \
        --very-sensitive \
        --outfmt 6 \
        --threads ${threads}

    # run busco
    busco -i ${WORK_PATH}/project_data/downy/diamond/${INPUT_FILE}.fasta \
        --out_path ${WORK_PATH}/project_data/downy/diamond \
        --out ${INPUT_FILE}_busco \
        --mode genome \
        --auto-lineage-euk \
        --download_path ${WORK_PATH}/project_data/downy/busco_downloads \
        --cpu ${threads} \
        --force \
        --tar

    # run quast
    quast.py --output-dir ${WORK_PATH}/project_data/downy/diamond/${INPUT_FILE}_quast \
        --threads ${threads} \
        --eukaryote \
        ${WORK_PATH}/project_data/downy/diamond/${INPUT_FILE}.fasta


done