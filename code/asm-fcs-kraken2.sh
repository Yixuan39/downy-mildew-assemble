#!/bin/bash

EXTRACT=true

usage() {
    echo "Usage: $0 -i <input_file> -o <output_dir> -d <gx_db> -k <kraken_db> -b <busco_db> -c <confidence_score> -t <taxid> -m <min_length> -p <threads>"
    echo ""
    echo "  -i  Input FASTQ file"
    echo "  -o  Output directory"
    echo "  -d  GX database path"
    echo "  -k  Kraken database path"
    echo "  -b  BUSCO database path"
    echo "  -c  Confidence score"
    echo "  -t  Taxonomic ID"
    echo "  -e  Extract reads classified as TAXID, default: ${EXTRACT}"
    echo "  -m  Minimum sequence length"
    echo "  -p  Number of threads"
    echo "  -h  Show this help message"
    exit 1
}

# Parse command-line options
while getopts "i:o:d:k:b:c:t:m:p:h" opt; do
    case $opt in
        i) INPUT_FILE="$OPTARG" ;;
        o) RESULT_DIR="$OPTARG" ;;
        d) GX_DB="$OPTARG" ;;
        k) KrakenDB="$OPTARG" ;;
        b) BUSCO_DB="$OPTARG" ;;
        c) CS="$OPTARG" ;;
        t) TAXID="$OPTARG" ;;
        e) EXTRACT="$OPTARG" ;;
        m) MIN_LENGTH="$OPTARG" ;;
        p) THREADS="$OPTARG" ;;
        h) usage ;;
    esac
done

export GX_NUM_CORES=$THREADS
# get base name
BASENAME=$(basename ${INPUT_FILE})
BASENAME=${BASENAME%.fastq}
BASENAME=${BASENAME%.gz}

# assemble the genome
metaMDBG asm \
    --out-dir ${RESULT_DIR}/${BASENAME}.asm \
    --in-hifi ${INPUT_FILE} \
    --threads ${THREADS}
    
# discard contigs shorter than 5000 bp
ASSEMBLED_FILE=${RESULT_DIR}/${BASENAME}.asm.fasta.gz
seqtk seq \
    -L ${MIN_LENGTH} \
    ${RESULT_DIR}/${BASENAME}.asm/contigs.fasta.gz\
    > ${ASSEMBLED_FILE}
rm -rf ${RESULT_DIR}/${BASENAME}.asm

# fcs screen and remove contamination
run_gx.py \
    --fasta ${ASSEMBLED_FILE} \
    --tax-id ${TAXID} \
    --gx-db ${GX_DB} \
    --out-dir ${RESULT_DIR} \
    --out-basename ${BASENAME}

gx clean-genome \
    --input ${ASSEMBLED_FILE} \
    --action-report ${RESULT_DIR}/${BASENAME}.fcs_gx_report.txt \
    --output ${RESULT_DIR}/${BASENAME}.fcs_cleaned.fasta

if [ ${EXTRACT} ]
then
    # run kraken2
    kraken2 \
        --db ${KrakenDB} \
        --confidence ${CS} \
        --threads ${THREADS} \
        --output ${RESULT_DIR}/${BASENAME}.kraken \
        --report ${RESULT_DIR}/${BASENAME}.kreport \
        ${RESULT_DIR}/${BASENAME}.fcs_cleaned.fasta
    # extract sequences classified as TAXID
    extract_kraken_reads.py \
        -k ${RESULT_DIR}/${BASENAME}.kraken \
        -s ${RESULT_DIR}/${BASENAME}.fcs_cleaned.fasta \
        --report ${RESULT_DIR}/${BASENAME}.kreport \
        --taxid ${TAXID} \
        --output ${RESULT_DIR}/${BASENAME}.kraken_cleaned.fasta \
        --include-children
else
    kraken2 \
        --db ${KrakenDB} \
        --confidence ${CS} \
        --threads ${THREADS} \
        --output ${RESULT_DIR}/${BASENAME}.kraken \
        --report ${RESULT_DIR}/${BASENAME}.kreport \
        --unclassified-out ${RESULT_DIR}/${BASENAME}.kraken_cleaned.fasta \
        ${RESULT_DIR}/${BASENAME}.fcs_cleaned.fasta
fi 
  
# get quality report for fcs cleaned INPUT_FILE
python quality-check.py \
    --input_INPUT_FILE ${RESULT_DIR}/${BASENAME}.fcs_cleaned.fasta \
    --output_dir ${RESULT_PATH} \
    --suffix ${BASENAME}.fcs_cleaned \
    --library_path ${BUSCO_DB} \
    --threads ${THREADS}
    # get quality report for kraken2 cleaned INPUT_FILE
python quality-check.py \
    --input_INPUT_FILE ${RESULT_DIR}/${BASENAME}.kraken_cleaned.fasta \
    --output_dir ${RESULT_PATH} \
    --suffix ${BASENAME}.kraken_cleaned \
    --library_path ${BUSCO_DB} \
    --threads ${THREADS}
# compress both INPUT_FILEs
gzip ${RESULT_DIR}/${BASENAME}.fcs_cleaned.fasta
gzip ${RESULT_DIR}/${BASENAME}.kraken_cleaned.fasta


