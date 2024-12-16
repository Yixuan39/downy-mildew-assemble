#!/bin/bash

INPUT_FOLDER="/data/run/yyang/project_data/downy/metaMDBG"
RESULT_PATH="/data/run/yyang/project_data/downy/asm-blast-contam-protein"
DB="/data/run/yyang/project_data/downy/combined_seqs/contam-protein.fasta"
FILES=$(ls ${INPUT_FOLDER} | grep .fasta | sed 's/.fasta//g')
mkdir -p ${RESULT_PATH}
threads=32

makeblastdb -in ${DB} -dbtype prot

for FILE in ${FILES}; do
    # convert input to protein
    transeq -sequence ${INPUT_FOLDER}/${FILE}.fasta -outseq ${RESULT_PATH}/${FILE}.faa -frame 6
    # run mmseqs2 on the assembly
    blastp \
    -query ${RESULT_PATH}/${FILE}.faa \
    -db ${DB} \
    -outfmt "6 qseqid" \
    -out ${RESULT_PATH}/${FILE}.txt \
    -evalue 1e-10 \
    -max_target_seqs 1 \
    -max_hsps 1 \
    -num_threads ${threads}
    # extract the reads
    seqtk subseq ${INPUT_FOLDER}/${FILE}.fasta ${RESULT_PATH}/${FILE}.txt > ${RESULT_PATH}/${FILE}.fasta
    rm ${RESULT_PATH}/${FILE}.txt
    rm ${RESULT_PATH}/${FILE}.faa
done