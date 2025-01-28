#!/bin/bash

CS=$1
threads=24

# Use metaMDBG assemble pacbio

INPUT_FOLDER=/data/run/yyang/project_data/downy/metaMDBG
FILES=$(ls ${INPUT_FOLDER}/*.fasta.gz 2>/dev/null | xargs -n 1 basename)

# assemble sequence first, then extract oomycota sequence use genome search

KrakenDB=/data/run/yyang/project_data/downy/KrakenDB/oomycota-genome
RESULT_PATH=/data/run/yyang/project_data/downy/Kraken-result/assemble-classify-oomycota-genome/${CS}
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw assembly
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --confidence ${CS} \
        ${INPUT_FOLDER}/${FILE}
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
        -k ${RESULT_PATH}/${FILE}.kraken \
        -s ${INPUT_FOLDER}/${FILE} \
        --taxid 4762 \
        --output ${RESULT_PATH}/${FILE%.gz} \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --include-children
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    gzip ${RESULT_PATH}/${FILE%.gz}
done

# assemble sequence first, then extract oomycota sequence use protein search

KrakenDB=/data/run/yyang/project_data/downy/KrakenDB/oomycota-protein
RESULT_PATH=/data/run/yyang/project_data/downy/Kraken-result/assemble-classify-oomycota-protein/${CS}
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw assembly
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --confidence ${CS} \
        ${INPUT_FOLDER}/${FILE}
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
        -k ${RESULT_PATH}/${FILE}.kraken \
        -s ${INPUT_FOLDER}/${FILE} \
        --taxid 4762 \
        --output ${RESULT_PATH}/${FILE%.gz} \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --include-children
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    gzip ${RESULT_PATH}/${FILE%.gz}
done

# assemble sequence first, then remove contamination sequence use genome search.

KrakenDB=/data/run/yyang/project_data/downy/KrakenDB/contam-genome
RESULT_PATH=/data/run/yyang/project_data/downy/Kraken-result/assemble-classify-contam-genome/${CS}
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw reads
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --unclassified-out ${RESULT_PATH}/${FILE%.gz} \
        --confidence ${CS} \
        ${INPUT_FOLDER}/${FILE}
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    gzip ${RESULT_PATH}/${FILE%.gz}
done

# assemble sequence first, then remove contamination sequence use protein search.

KrakenDB=/data/run/yyang/project_data/downy/KrakenDB/contam-protein
RESULT_PATH=/data/run/yyang/project_data/downy/Kraken-result/assemble-classify-contam-protein/${CS}
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw reads
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --unclassified-out ${RESULT_PATH}/${FILE%.gz} \
        --confidence ${CS} \
        ${INPUT_FOLDER}/${FILE}
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    gzip ${RESULT_PATH}/${FILE%.gz}
done


INPUT_FOLDER=/data/run/yyang/project_data/downy/data
FILES=$(ls ${INPUT_FOLDER}/*.fastq.gz 2>/dev/null | xargs -n 1 basename)

# extract oomycota sequence with kraken2 using genome search, then assemble the genome.

KrakenDB=/data/run/yyang/project_data/downy/KrakenDB/oomycota-genome
RESULT_PATH=/data/run/yyang/project_data/downy/Kraken-result/classify-assemble-oomycota-genome/${CS}
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw reads
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --confidence ${CS} \
        ${INPUT_FOLDER}/${FILE}
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
        -k ${RESULT_PATH}/${FILE}.kraken \
        -s ${INPUT_FOLDER}/${FILE} \
        --taxid 4762 \
        --output ${RESULT_PATH}/${FILE}.tmp.fastq \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --include-children \
        --fastq-output
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}_asm \
        --in-hifi ${RESULT_PATH}/${FILE}.tmp.fastq \
        --threads ${threads}
    mv ${RESULT_PATH}/${FILE}_asm/contigs.fasta.gz ${RESULT_PATH}/${FILE%.fastq.gz}.fasta.gz
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    rm ${RESULT_PATH}/${FILE}.tmp.fastq
    rm -rf ${RESULT_PATH}/${FILE}_asm
done


# extract oomycota sequence with kraken2 using protein search, then assemble the genome.

KrakenDB=/data/run/yyang/project_data/downy/KrakenDB/oomycota-protein
RESULT_PATH=/data/run/yyang/project_data/downy/Kraken-result/classify-assemble-oomycota-protein/${CS}
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw reads
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --confidence ${CS} \
        ${INPUT_FOLDER}/${FILE}
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
        -k ${RESULT_PATH}/${FILE}.kraken \
        -s ${INPUT_FOLDER}/${FILE} \
        --taxid 4762 \
        --output ${RESULT_PATH}/${FILE}.tmp.fastq \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --include-children \
        --fastq-output
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}_asm \
        --in-hifi ${RESULT_PATH}/${FILE}.tmp.fastq \
        --threads ${threads}
    mv ${RESULT_PATH}/${FILE}_asm/contigs.fasta.gz ${RESULT_PATH}/${FILE%.fastq.gz}.fasta.gz
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    rm ${RESULT_PATH}/${FILE}.tmp.fastq
    rm -rf ${RESULT_PATH}/${FILE}_asm
done

# exclude the contamination sequences first with kraken2 using genome search, then assemble the genome.

KrakenDB=/data/run/yyang/project_data/downy/KrakenDB/contam-genome
RESULT_PATH=/data/run/yyang/project_data/downy/Kraken-result/classify-assemble-contam-genome/${CS}
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw reads
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --unclassified-out ${RESULT_PATH}/${FILE}.tmp.fastq \
        --confidence ${CS} \
        ${INPUT_FOLDER}/${FILE}
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}_asm \
        --in-hifi ${RESULT_PATH}/${FILE}.tmp.fastq \
        --threads ${threads}
    mv ${RESULT_PATH}/${FILE}_asm/contigs.fasta.gz ${RESULT_PATH}/${FILE%.fastq.gz}.fasta.gz
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    rm ${RESULT_PATH}/${FILE}.tmp.fastq
    rm -rf ${RESULT_PATH}/${FILE}_asm
done

# exclude the contamination sequences first with kraken2 using protein search, then assemble the genome.

KrakenDB=/data/run/yyang/project_data/downy/KrakenDB/contam-protein
RESULT_PATH=/data/run/yyang/project_data/downy/Kraken-result/classify-assemble-contam-protein/${CS}
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # Run kraken2 on raw reads
    kraken2 --db ${KrakenDB} \
        --threads ${threads} \
        --output ${RESULT_PATH}/${FILE}.kraken \
        --report ${RESULT_PATH}/${FILE}.kreport \
        --unclassified-out ${RESULT_PATH}/${FILE}.tmp.fastq \
        --confidence ${CS} \
        ${INPUT_FOLDER}/${FILE}
    # Assemble the extracted reads
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/${FILE}_asm \
        --in-hifi ${RESULT_PATH}/${FILE}.tmp.fastq \
        --threads ${threads}
    mv ${RESULT_PATH}/${FILE}_asm/contigs.fasta.gz ${RESULT_PATH}/${FILE%.fastq.gz}.fasta.gz
    # remove unnecessary files
    rm ${RESULT_PATH}/${FILE}.kraken
    rm ${RESULT_PATH}/${FILE}.tmp.fastq
    rm -rf ${RESULT_PATH}/${FILE}_asm
done
