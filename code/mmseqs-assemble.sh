#!/bin/bash

EV=$1
threads=32
INPUT_FOLDER=/data/run/yyang/project_data/downy/metaMDBG
FILES=$(ls ${INPUT_FOLDER}/*.fasta.gz 2>/dev/null | xargs -n 1 basename)

# assemble sequence first, then extract oomycota sequence use genome search

DB=/data/run/yyang/project_data/downy/ref-seq/oomycota-genome.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/assemble-classify-oomycota-genome
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.txt \
    tmp \
    -e ${EV} \
    --max-seqs 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE} \
    ${INPUT_FOLDER}/${FILE} 
done

# assemble sequence first, then extract oomycota sequence use protein search

DB=/data/run/yyang/project_data/downy/ref-seq/oomycota-protein.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/assemble-classify-oomycota-protein
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.txt \
    tmp \
    -e ${EV} \
    --max-seqs 1 \
    --search-type 2 \
    --translation-mode 1 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE} \
    ${INPUT_FOLDER}/${FILE} 
done

# assemble sequence first, then remove contamination sequence use genome search
cat /data/run/yyang/project_data/downy/ref-seq/contam-genome.fasta.gz \
    /data/run/yyang/project_data/downy/ref-seq/genome-bfh.fasta.gz > /data/run/yyang/project_data/downy/ref-seq/contam-large-genome.fasta.gz
DB=/data/run/yyang/project_data/downy/ref-seq/contam-large-genome.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/assemble-classify-contam-genome
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.txt \
    tmp \
    -e ${EV} \
    --max-seqs 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --invert-match \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE} \
    ${INPUT_FOLDER}/${FILE} 
done

# assemble sequence first, then remove contamination sequence use protein search
cat /data/run/yyang/project_data/downy/ref-seq/contam-protein.fasta.gz \
    /data/run/yyang/project_data/downy/ref-seq/protein-bfh.fasta.gz > /data/run/yyang/project_data/downy/ref-seq/contam-large-protein.fasta.gz
DB=/data/run/yyang/project_data/downy/ref-seq/contam-large-protein.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/assemble-classify-contam-protein
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.txt \
    tmp \
    -e ${EV} \
    --max-seqs 1 \
    --search-type 2 \
    --translation-mode 1 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --invert-match \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE} \
    ${INPUT_FOLDER}/${FILE} 
done




###########################################################################
# classify sequence first, then assemble

INPUT_FOLDER=/data/run/yyang/project_data/downy/data
FILES=$(ls ${INPUT_FOLDER}/*.fastq.gz 2>/dev/null | xargs -n 1 basename)

# assemble sequence first, then extract oomycota sequence use genome search

DB=/data/run/yyang/project_data/downy/ref-seq/oomycota-genome.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/assemble-classify-oomycota-genome
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.txt \
    tmp \
    -e ${EV} \
    --max-seqs 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz \
    ${INPUT_FOLDER}/${FILE} 
    
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm \
        --in-hifi ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz \
        --threads ${threads}
    mv ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm/contigs.fasta.gz ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz
    rm -rf ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm
    rm ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz
    rm ${RESULT_PATH}/${FILE}.txt
done

# assemble sequence first, then extract oomycota sequence use protein search

DB=/data/run/yyang/project_data/downy/ref-seq/oomycota-protein.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/assemble-classify-oomycota-protein
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.txt \
    tmp \
    -e ${EV} \
    --max-seqs 1 \
    --search-type 2 \
    --translation-mode 1 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz \
    ${INPUT_FOLDER}/${FILE}
    
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm \
        --in-hifi ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz \
        --threads ${threads}
    mv ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm/contigs.fasta.gz ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz
    rm -rf ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm
    rm ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz
    rm ${RESULT_PATH}/${FILE}.txt
done

# assemble sequence first, then remove contamination sequence use genome search
cat /data/run/yyang/project_data/downy/ref-seq/contam-genome.fasta.gz \
    /data/run/yyang/project_data/downy/ref-seq/genome-bfh.fasta.gz > /data/run/yyang/project_data/downy/ref-seq/contam-large-genome.fasta.gz
DB=/data/run/yyang/project_data/downy/ref-seq/contam-large-genome.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/assemble-classify-contam-genome
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.txt \
    tmp \
    -e ${EV} \
    --max-seqs 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --invert-match \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz \
    ${INPUT_FOLDER}/${FILE}
    
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm \
        --in-hifi ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz \
        --threads ${threads}
    mv ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm/contigs.fasta.gz ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz
    rm -rf ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm
    rm ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz
    rm ${RESULT_PATH}/${FILE}.txt
done

# assemble sequence first, then remove contamination sequence use protein search
cat /data/run/yyang/project_data/downy/ref-seq/contam-protein.fasta.gz \
    /data/run/yyang/project_data/downy/ref-seq/protein-bfh.fasta.gz > /data/run/yyang/project_data/downy/ref-seq/contam-large-protein.fasta.gz
DB=/data/run/yyang/project_data/downy/ref-seq/contam-large-protein.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/assemble-classify-contam-protein
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.txt \
    tmp \
    -e ${EV} \
    --max-seqs 1 \
    --search-type 2 \
    --translation-mode 1 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --invert-match \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz \
    ${INPUT_FOLDER}/${FILE}
    
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm \
        --in-hifi ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz \
        --threads ${threads}
    mv ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm/contigs.fasta.gz ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz
    rm -rf ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.fasta.gz_asm
    rm ${RESULT_PATH}/${EV}/${FILE%fastq.gz}.tmp.fasta.gz
    rm ${RESULT_PATH}/${FILE}.txt
done


