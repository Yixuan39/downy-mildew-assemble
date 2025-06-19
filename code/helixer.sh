#!/bin/bash
#SBATCH --cpus-per-task=32

INPUT_DIR=$HOME/project_data/downy/result/asm-fcs-kraken2/oomycota-genomic/0.5
FILES=($(find "$INPUT_DIR" -type f -name "*kraken.fasta.gz"))
Peffusa=$HOME/project_data/downy/oomycota-genome/Peronospora-effusa.fna
OUTPUT_DIR=$INPUT_DIR/helixer
mkdir -p $OUTPUT_DIR

for FILE in ${FILES[@]}; do
    BASENAME=$(basename ${FILE})  
    BASENAME=${BASENAME%.fasta.gz}
    gzip -d -k -c $FILE > ${OUTPUT_DIR}/${BASENAME}.fasta
    helixerlite \
    --cpus 32 \
    --lineage fungi \
    --fasta ${OUTPUT_DIR}/${BASENAME}.fasta \
    --out ${OUTPUT_DIR}/${BASENAME}.gff3
    gffread \
    ${OUTPUT_DIR}/${BASENAME}.gff3 \
    -g ${OUTPUT_DIR}/${BASENAME}.fasta \
    -y ${OUTPUT_DIR}/${BASENAME}.faa
done