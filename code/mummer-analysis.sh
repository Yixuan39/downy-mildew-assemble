#!/bin/bash

INPUT_DIR=$HOME/project_data/downy/result/asm-fcs-kraken2/oomycota-genomic/0.5
FILES=($(find "$INPUT_DIR" -type f -name "*kraken.fasta.gz"))
Peffusa=$HOME/project_data/downy/oomycota-genome/Peronospora-effusa.fna
OUTPUT_DIR=$INPUT_DIR/mummer
mkdir -p $OUTPUT_DIR

for FILE in ${FILES[@]}; do
    BASENAME=$(basename ${FILE})  
    BASENAME=${BASENAME%.fasta.gz}
    gzip -d -k -c $FILE > ${OUTPUT_DIR}/${BASENAME}.fasta
    nucmer \
    --threads=24 \
    --delta=${OUTPUT_DIR}/${BASENAME}.delta \
    ${Peffusa} \
    ${OUTPUT_DIR}/${BASENAME}.fasta
    mummerplot \
    -R ${Peffusa} \
    -Q ${OUTPUT_DIR}/${BASENAME}.fasta \
    --filter \
    --layout \
    --large \
    -t png \
    -p ${OUTPUT_DIR}/${BASENAME} \
    ${OUTPUT_DIR}/${BASENAME}.delta
    rm ${OUTPUT_DIR}/${BASENAME}.fasta
done