#!/bin/bash

THREADS=24
INPUT_FOLDER=$HOME/project_data/downy/hifi-simulation/fastq
FILES=$(find ${INPUT_FOLDER} -name "*.fq.gz")
RESULT_PATH=$HOME/project_data/downy/fcs-cleaning-simulation/
GX_DB=$HOME/project_data/downy/fcs-db/
KrakenDB=$HOME/project_data/downy/KrakenDB/oomycota-genome
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
CS=0.5
export GX_NUM_CORES=$THREADS

for file in ${FILES}; do
    metaMDBG asm \
        --out-dir ${RESULT_PATH}/$(basename ${file%.fq.gz}).asm \
        --in-hifi ${file} \
        --threads ${THREADS}

    # check contamination in the genome, 4762 is the tax id for oomycota.
    run_gx.py --fasta ${RESULT_PATH}/$(basename ${file%.fq.gz}).asm/contigs.fasta.gz \
              --tax-id 4762 \
              --gx-db ${GX_DB} \
              --out-dir ${RESULT_PATH} \
              --out-basename $(basename ${file%.fq.gz})
    # exclude contam read...
    gx clean-genome \
              --input ${RESULT_PATH}/$(basename ${file%.fq.gz}).asm/contigs.fasta.gz \
              --action-report ${RESULT_PATH}/$(basename ${file%.fq.gz}).fcs_gx_report.txt \
              --min-seq-len 5000 \
              --output ${RESULT_PATH}/$(basename ${file%.fq.gz}).fcs_cleaned.fasta
    # run kraken2
    kraken2 \
              --db ${KrakenDB} \
              --confidence ${CS} \
              --threads ${THREADS} \
              --output ${RESULT_PATH}/$(basename ${file%.fq.gz}).kraken \
              --report ${RESULT_PATH}/$(basename ${file%.fq.gz}).kreport \
              ${RESULT_PATH}/$(basename ${file%.fq.gz}).fcs_cleaned.fasta
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
              -k ${RESULT_PATH}/$(basename ${file%.fq.gz}).kraken \
              -s ${RESULT_PATH}/$(basename ${file%.fq.gz}).fcs_cleaned.fasta \
              --report ${RESULT_PATH}/$(basename ${file%.fq.gz}).kreport \
              --taxid 4762 \
              --output ${RESULT_PATH}/$(basename ${file%.fq.gz}).kraken_cleaned.fasta \
              --include-children
    # get quality report for fcs cleaned file
    python quality-check.py \
              --input_file ${RESULT_PATH}/$(basename ${file%.fq.gz}).fcs_cleaned.fasta \
              --output_dir ${RESULT_PATH} \
              --suffix $(basename ${file%.fq.gz}).fcs_cleaned \
              --library_path ${BUSCO_DB} \
              --threads ${THREADS}
    # get quality report for kraken2 cleaned file
    python quality-check.py \
              --input_file ${RESULT_PATH}/$(basename ${file%.fq.gz}).kraken_cleaned.fasta \
              --output_dir ${RESULT_PATH} \
              --suffix $(basename ${file%.fq.gz}).kraken_cleaned \
              --library_path ${BUSCO_DB} \
              --threads ${THREADS}
    # compress both files
    gzip ${RESULT_PATH}/$(basename ${file%.fq.gz}).fcs_cleaned.fasta
    gzip ${RESULT_PATH}/$(basename ${file%.fq.gz}).kraken_cleaned.fasta
    # remove unnecessary files
    rm -rf ${RESULT_PATH}/${file}.asm
done

