#!/bin/bash

INPUT_FOLDER="/Users/yixuanyang/project_data/downy/metaMDBG"
RESULT_PATH="/Users/yixuanyang/project_data/downy/asm-mmseqs2-extract-protein"
DB="/Users/yixuanyang/project_data/downy/combined_seqs/oomycete-protein.fasta"
FILES=$(ls ${INPUT_FOLDER} | grep .fasta | sed 's/.fasta//g')
mkdir -p ${RESULT_PATH}
threads=$(nproc --all)

makeblastdb -in ${DB} -dbtype prot

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    blastx \
    -query ${INPUT_FOLDER}/${FILE}.fasta \
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
done