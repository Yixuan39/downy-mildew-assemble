#!/bin/bash

usage() {
    echo "Usage: $0 -i <input_file> -o <output_dir> -d <gx_db> -b <busco_db> -t <taxid> -p <threads>"
    echo ""
    echo "  -i  Input FASTQ file"
    echo "  -o  Output directory"
    echo "  -d  GX database path"
    echo "  -b  BUSCO database path"
    echo "  -t  Taxonomic ID"
    echo "  -p  Number of threads"
    echo "  -h  Show this help message"
    exit 1
}

# Parse command-line options
while getopts "i:o:d:b:t:p:h" opt; do
    case $opt in
        i) INPUT_FILE="$OPTARG" ;;
        o) RESULT_DIR="$OPTARG" ;;
        d) GX_DB="$OPTARG" ;;
        b) BUSCO_DB="$OPTARG" ;;
        t) TAXID="$OPTARG" ;;
        p) THREADS="$OPTARG" ;;
        h) usage ;;
    esac
done
set -euo pipefail
export GX_NUM_CORES=$THREADS

# get base name
BASENAME=$(basename "$INPUT_FILE")  
BASENAME=${BASENAME%.fasta.gz}  
mkdir -p "${RESULT_DIR}/${BASENAME}"
echo "Base name: $BASENAME"

run_gx.py \
  --fasta ${INPUT_FILE} \
  --tax-id ${TAXID} \
  --gx-db ${GX_DB} \
  --out-dir ${RESULT_DIR} \
  --out-basename ${BASENAME}
  
gzip -dkc ${INPUT_FILE} > ${RESULT_DIR}/${BASENAME}/tmp.fasta

gx clean-genome \
  --input ${RESULT_DIR}/${BASENAME}/tmp.fasta \
  --action-report ${RESULT_DIR}/${BASENAME}.fcs_gx_report.txt \
  --output ${RESULT_DIR}/${BASENAME}/${BASENAME}.fasta
    
gzip -c "${RESULT_DIR}/${BASENAME}/${BASENAME}.fasta" \
  > "${RESULT_DIR}/${BASENAME}.fasta.gz"
rm -rf "${RESULT_DIR}/${BASENAME}"

python quality-check.py \
  --input_file "${RESULT_DIR}/${BASENAME}.fasta.gz" \
  --output_dir "${RESULT_DIR}/compleasm" \
  --suffix ${BASENAME} \
  --library_path ${BUSCO_DB} \
  --threads ${THREADS}
    
seqkit fx2tab \
  "${RESULT_DIR}/${BASENAME}.fasta.gz" \
  -n -l -j ${THREADS} \
  -o "${RESULT_DIR}/compleasm/${BASENAME}.tsv.gz"
