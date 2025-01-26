#!/bin/bash

EV=1e-15
threads=32
INPUT_FOLDER=/data/run/yyang/project_data/downy/metaMDBG
FILES=$(ls ${INPUT_FOLDER}/*.fasta.gz 2>/dev/null | xargs -n 1 basename)

# assemble sequence first, then extract oomycota sequence use protein search

DB=/data/run/yyang/project_data/downy/ref-seq/oomycota-protein.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/assemble-classify-oomycota-protein
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    gzip -d -c ${INPUT_FOLDER}/${FILE} | transeq -sequence - -outseq ${RESULT_PATH}/${FILE%.fasta.gz}.tmp.fasta -frame 6
    
    mmseqs easy-search \
    ${RESULT_PATH}/${FILE%.fasta.gz}.tmp.fasta \
    ${DB} \
    ${RESULT_PATH}/${FILE}.txt \
    ${RESULT_PATH}/tmp \
    -e ${EV} \
    --max-accept 1 \
    --search-type 1 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE} \
    ${INPUT_FOLDER}/${FILE} 
    
    rm ${RESULT_PATH}/${FILE}.txt     
    rm -rf ${RESULT_PATH}/tmp
done