#!/bin/bash

INPUT_FOLDER="/data/run/yyang/project_data/downy/metaMDBG"
RESULT_PATH="/data/run/yyang/project_data/downy/asm-blast-contam-genome"
DB="/data/run/yyang/project_data/downy/combined_seqs/contam-genome.fasta"
FILES=$(ls ${INPUT_FOLDER} | grep .fasta | sed 's/.fasta//g')
mkdir -p ${RESULT_PATH}
threads=32

makeblastdb -in ${DB} -dbtype nucl

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    blastn \
    -query ${INPUT_FOLDER}/${FILE}.fasta \
    -db ${DB} \
    -outfmt "6 qseqid" \
    -out ${RESULT_PATH}/${FILE}.txt \
    -evalue 1e-10 \
    -max_target_seqs 1 \
    -max_hsps 1 \
    -num_threads ${threads}
    # remove mapped reads
    python remove_seq.py ${INPUT_FOLDER}/${FILE}.fasta ${RESULT_PATH}/${FILE}.txt ${RESULT_PATH}/${FILE}.fasta
    rm ${RESULT_PATH}/${FILE}.txt
done