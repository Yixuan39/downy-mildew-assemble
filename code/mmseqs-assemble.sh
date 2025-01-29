#!/bin/bash

EV=$1
threads=24

###########################################################################
# classify sequence first, then assemble with metaMDBG                    #
###########################################################################

INPUT_FOLDER=$HOME/project_data/downy/data
FILES=$(ls ${INPUT_FOLDER}/*.fastq.gz 2>/dev/null | xargs -n 1 basename)

# assemble sequence first, then extract oomycota sequence use genome search

DB=$HOME/project_data/downy/ref-seq/oomycota-genome.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-oomycota-genome
mkdir -p ${RESULT_PATH}/${EV}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${EV}/${FILE}.txt \
    ${RESULT_PATH}/${EV}/tmp \
    -e ${EV} \
    --max-accept 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz \
    ${INPUT_FOLDER}/${FILE} 
    
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm \
        --in-hifi ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz \
        --threads ${threads}
        
    mv ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm/contigs.fasta.gz ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz
    rm -rf ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm
    rm ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz
    rm ${RESULT_PATH}/${EV}/${FILE}.txt     
    rm -rf ${RESULT_PATH}/${EV}/tmp
done

# assemble sequence first, then extract oomycota sequence use protein search

DB=$HOME/project_data/downy/ref-seq/oomycota-protein.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-oomycota-protein
mkdir -p ${RESULT_PATH}/${EV}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${EV}/${FILE}.txt \
    ${RESULT_PATH}/${EV}/tmp \
    -e ${EV} \
    --max-accept 1 \
    --search-type 2 \
    --translation-mode 1 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz \
    ${INPUT_FOLDER}/${FILE}
    
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm \
        --in-hifi ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz \
        --threads ${threads}
        
    mv ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm/contigs.fasta.gz ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz
    rm -rf ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm
    rm ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz
    rm ${RESULT_PATH}/${EV}/${FILE}.txt     rm -rf ${RESULT_PATH}/${EV}/tmp
done

# assemble sequence first, then remove contamination sequence use genome search
cat $HOME/project_data/downy/ref-seq/contam-genome.fasta.gz \
    $HOME/project_data/downy/ref-seq/genome-bfh.fasta.gz > $HOME/project_data/downy/ref-seq/contam-large-genome.fasta.gz
DB=$HOME/project_data/downy/ref-seq/contam-large-genome.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-contam-genome
mkdir -p ${RESULT_PATH}/${EV}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${EV}/${FILE}.txt \
    ${RESULT_PATH}/${EV}/tmp \
    -e ${EV} \
    --max-accept 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --invert-match \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz \
    ${INPUT_FOLDER}/${FILE}
    
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm \
        --in-hifi ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz \
        --threads ${threads}
        
    mv ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm/contigs.fasta.gz ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz
    rm -rf ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm
    rm ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz
    rm ${RESULT_PATH}/${EV}/${FILE}.txt     
    rm -rf ${RESULT_PATH}/${EV}/tmp
done

# assemble sequence first, then remove contamination sequence use protein search
cat $HOME/project_data/downy/ref-seq/contam-protein.fasta.gz \
    $HOME/project_data/downy/ref-seq/protein-bfh.fasta.gz > $HOME/project_data/downy/ref-seq/contam-large-protein.fasta.gz
DB=$HOME/project_data/downy/ref-seq/contam-large-protein.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-contam-protein
mkdir -p ${RESULT_PATH}/${EV}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${EV}/${FILE}.txt \
    ${RESULT_PATH}/${EV}/tmp \
    -e ${EV} \
    --max-accept 1 \
    --search-type 2 \
    --translation-mode 1 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --invert-match \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz \
    ${INPUT_FOLDER}/${FILE}
    
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm \
        --in-hifi ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz \
        --threads ${threads}
        
    mv ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm/contigs.fasta.gz ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz
    rm -rf ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm
    rm ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz
    rm ${RESULT_PATH}/${EV}/${FILE}.txt     
    rm -rf ${RESULT_PATH}/${EV}/tmp
done

###########################################################################
# assemble with metaMDBG first, then classify sequence                    #
###########################################################################

INPUT_FOLDER=$HOME/project_data/downy/metaMDBG
FILES=$(ls ${INPUT_FOLDER}/*.fasta.gz 2>/dev/null | xargs -n 1 basename)

# assemble sequence first, then extract oomycota sequence use genome search

DB=$HOME/project_data/downy/ref-seq/oomycota-genome.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-oomycota-genome
mkdir -p ${RESULT_PATH}/${EV}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${EV}/${FILE}.txt \
    ${RESULT_PATH}/${EV}/tmp \
    -e ${EV} \
    --max-accept 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE} \
    ${INPUT_FOLDER}/${FILE} 
    
    rm ${RESULT_PATH}/${EV}/${FILE}.txt
    rm -rf ${RESULT_PATH}/${EV}/tmp
done

# assemble sequence first, then extract oomycota sequence use protein search

DB=$HOME/project_data/downy/ref-seq/oomycota-protein.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-oomycota-protein
mkdir -p ${RESULT_PATH}/${EV}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${EV}/${FILE}.txt \
    ${RESULT_PATH}/${EV}/tmp \
    -e ${EV} \
    --max-accept 1 \
    --search-type 2 \
    --translation-mode 1 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE} \
    ${INPUT_FOLDER}/${FILE} 
    
    rm ${RESULT_PATH}/${EV}/${FILE}.txt     
    rm -rf ${RESULT_PATH}/${EV}/tmp
done

# assemble sequence first, then remove contamination sequence use genome search
cat $HOME/project_data/downy/ref-seq/contam-genome.fasta.gz \
    $HOME/project_data/downy/ref-seq/genome-bfh.fasta.gz > $HOME/project_data/downy/ref-seq/contam-large-genome.fasta.gz
DB=$HOME/project_data/downy/ref-seq/contam-large-genome.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-contam-genome
mkdir -p ${RESULT_PATH}/${EV}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${EV}/${FILE}.txt \
    ${RESULT_PATH}/${EV}/tmp \
    -e ${EV} \
    --max-accept 1 \
    --search-type 3 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --invert-match \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE} \
    ${INPUT_FOLDER}/${FILE} 
    
    rm ${RESULT_PATH}/${EV}/${FILE}.txt     
    rm -rf ${RESULT_PATH}/${EV}/tmp
done

# assemble sequence first, then remove contamination sequence use protein search
cat $HOME/project_data/downy/ref-seq/contam-protein.fasta.gz \
    $HOME/project_data/downy/ref-seq/protein-bfh.fasta.gz > $HOME/project_data/downy/ref-seq/contam-large-protein.fasta.gz
DB=$HOME/project_data/downy/ref-seq/contam-large-protein.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-contam-protein
mkdir -p ${RESULT_PATH}/${EV}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${EV}/${FILE}.txt \
    ${RESULT_PATH}/${EV}/tmp \
    -e ${EV} \
    --max-accept 1 \
    --search-type 2 \
    --translation-mode 1 \
    --format-mode 4 \
    --format-output query
    
    seqkit grep \
    --invert-match \
    --threads ${threads} \
    --pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
    --out-file ${RESULT_PATH}/${EV}/${FILE} \
    ${INPUT_FOLDER}/${FILE} 
    
    rm ${RESULT_PATH}/${EV}/${FILE}.txt     
    rm -rf ${RESULT_PATH}/${EV}/tmp
done







