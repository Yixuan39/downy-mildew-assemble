#!/bin/bash

INPUT_FOLDER=/data/run/yyang/project_data/downy/metaMDBG
FILES=$(ls ${INPUT_FOLDER}/*.fastq.gz 2>/dev/null | xargs -n 1 basename)

# assemble sequence first, then extract oomycota sequence use genome search

DB=/data/run/yyang/project_data/downy/ref-seq/oomycota-genome.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/oomycota-genome
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.tsv \
    tmp \
    -e 10 \
    --max-seqs 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query,qseq,evalue
done

# assemble sequence first, then extract oomycota sequence use protein search

DB=/data/run/yyang/project_data/downy/ref-seq/oomycota-protein.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/oomycota-protein
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.tsv \
    tmp \
    -e 10 \
    --max-seqs 1 \
    --search-type 2 \
    --translation-mode 1 \
    --format-mode 4 \
    --format-output query,qseq,evalue
done

# assemble sequence first, then extract oomycota sequence use genome search
cat /data/run/yyang/project_data/downy/ref-seq/contam-genome.fasta.gz \
    /data/run/yyang/project_data/downy/ref-seq/genome-bfh.fasta.gz > /data/run/yyang/project_data/downy/ref-seq/contam-large-genome.fasta.gz
DB=/data/run/yyang/project_data/downy/ref-seq/contam-large-genome.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/contam-genome
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.tsv \
    tmp \
    -e 10 \
    --max-seqs 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query,qseq,evalue
done

# assemble sequence first, then extract oomycota sequence use protein search
cat /data/run/yyang/project_data/downy/ref-seq/contam-protein.fasta.gz \
    /data/run/yyang/project_data/downy/ref-seq/protein-bfh.fasta.gz > /data/run/yyang/project_data/downy/ref-seq/contam-large-protein.fasta.gz
DB=/data/run/yyang/project_data/downy/ref-seq/contam-large-protein.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/contam-protein
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.tsv \
    tmp \
    -e 10 \
    --max-seqs 1 \
    --search-type 2 \
    --translation-mode 1 \
    --format-mode 4 \
    --format-output query,qseq,evalue
done