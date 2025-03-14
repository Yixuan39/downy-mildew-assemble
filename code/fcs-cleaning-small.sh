#!/bin/bash

THREADS=24
INPUT_FOLDER=$HOME/project_data/downy/metaMDBG
FILES=$(find ${INPUT_FOLDER} -name "*.fasta.gz")
RESULT_PATH=$HOME/project_data/downy/fcs-genome-cleaning-small/
GX_DB=$HOME/project_data/downy/fcs-db/
KrakenDB=$HOME/project_data/downy/KrakenDB/oomycota-genome-small
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
CS=0.5
export GX_NUM_CORES=$THREADS

for file in ${FILES}; do
    # check contamination in the genome, 4762 is the tax id for oomycota.
    run_gx.py --fasta ${file} \
              --tax-id 4762 \
              --gx-db ${GX_DB} \
              --out-dir ${RESULT_PATH} \
              --out-basename $(basename ${file%.fasta.gz})
    # exclude contam read...
    gx clean-genome \
              --input ${file} \
              --action-report ${RESULT_PATH}/$(basename ${file%.fasta.gz}).fcs_gx_report.txt \
              --min-seq-len 5000 \
              --output ${RESULT_PATH}/$(basename ${file%.fasta.gz}).fcs_cleaned.fasta
    # run kraken2
    kraken2 \
              --db ${KrakenDB} \
              --confidence ${CS} \
              --threads ${THREADS} \
              --output ${RESULT_PATH}/$(basename ${file%.fasta.gz}).kraken \
              --report ${RESULT_PATH}/$(basename ${file%.fasta.gz}).kreport \
              ${RESULT_PATH}/$(basename ${file%.fasta.gz}).fcs_cleaned.fasta
    # extract sequences classified as Oomycota (taxid 4762)
    extract_kraken_reads.py \
              -k ${RESULT_PATH}/$(basename ${file%.fasta.gz}).kraken \
              -s ${RESULT_PATH}/$(basename ${file%.fasta.gz}).fcs_cleaned.fasta \
              --report ${RESULT_PATH}/$(basename ${file%.fasta.gz}).kreport \
              --taxid 4762 \
              --output ${RESULT_PATH}/$(basename ${file%.fasta.gz}).kraken_cleaned.fasta \
              --include-children
    # get quality report for fcs cleaned file
    python quality-check.py \
              --input_file ${RESULT_PATH}/$(basename ${file%.fasta.gz}).fcs_cleaned.fasta \
              --output_dir ${RESULT_PATH} \
              --suffix $(basename ${file%.fasta.gz}).fcs_cleaned \
              --library_path ${BUSCO_DB} \
              --threads ${THREADS}
    # get quality report for kraken2 cleaned file
    python quality-check.py \
              --input_file ${RESULT_PATH}/$(basename ${file%.fasta.gz}).kraken_cleaned.fasta \
              --output_dir ${RESULT_PATH} \
              --suffix $(basename ${file%.fasta.gz}).kraken_cleaned \
              --library_path ${BUSCO_DB} \
              --threads ${THREADS}
    # compress both files
    gzip ${RESULT_PATH}/$(basename ${file%.fasta.gz}).fcs_cleaned.fasta
    gzip ${RESULT_PATH}/$(basename ${file%.fasta.gz}).kraken_cleaned.fasta
done

