#!/bin/bash

usage() {
    echo "Usage: $0 -i <input_file> -o <output_dir> -b <busco_db> -r <refseq> -q <query> -p <threads>"
    echo ""
    echo "  -i  Input FASTA file"
    echo "  -o  Output directory"
    echo "  -b  BUSCO database path"
    echo "  -r  reference file"
    echo "  -q  query asm file for patching"
    echo "  -p  Number of threads"
    echo "  -h  Show this help message"
    exit 1
}

# Parse command-line options
while getopts "i:o:d:b:r:q:p:h" opt; do
    case $opt in
        i) INPUT_FILE="$OPTARG" ;;
        o) RESULT_DIR="$OPTARG" ;;
        b) BUSCO_DB="$OPTARG" ;;
        r) REF="$OPTARG" ;;
        q) QUERY="$OPTARG" ;;
        p) THREADS="$OPTARG" ;;
        h) usage ;;
    esac
done
set -euo pipefail

# get base name
BASENAME=$(basename "$INPUT_FILE")  
BASENAME=${BASENAME%.fasta.gz}  
mkdir -p "${RESULT_DIR}/${BASENAME}"
echo "Base name: $BASENAME"

gzip -dkc ${INPUT_FILE} > ${RESULT_DIR}/${BASENAME}/${BASENAME}.fasta
gzip -dkc ${QUERY} > ${RESULT_DIR}/${BASENAME}/${BASENAME}.query.fasta

ragtag.py scaffold \
  -o ${RESULT_DIR}/${BASENAME} \
  -w \
  -t ${THREADS} \
  ${REF} \
  ${RESULT_DIR}/${BASENAME}/${BASENAME}.fasta
  
# self patching
ragtag.py patch \
  -o ${RESULT_DIR}/${BASENAME} \
  -w \
  ${RESULT_DIR}/${BASENAME}/ragtag.scaffold.fasta \
  ${RESULT_DIR}/${BASENAME}/${BASENAME}.query.fasta
  
# refine scaffolding
ragtag.py scaffold \
  -o ${RESULT_DIR}/${BASENAME} \
  -w \
  -t ${THREADS} \
  ${REF} \
  ${RESULT_DIR}/${BASENAME}/ragtag.patch.fasta
  
gzip -c "${RESULT_DIR}/${BASENAME}/ragtag.scaffold.fasta" > "${RESULT_DIR}/${BASENAME}.fasta.gz"
rm -rf "${RESULT_DIR}/${BASENAME}"

python quality-check.py \
  --input_file "${RESULT_DIR}/${BASENAME}.fasta.gz" \
  --output_dir "${RESULT_DIR}/compleasm" \
  --suffix ${BASENAME} \
  --library_path ${BUSCO_DB} \
  --threads ${THREADS}
    
