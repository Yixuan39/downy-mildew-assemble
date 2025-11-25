#!/bin/bash

usage() {
    echo "Usage: $0 -i <input_file> -o <output_dir> -b <busco_db> -p <threads>"
    echo ""
    echo "  -i  Input FASTQ file"
    echo "  -o  Output directory"
    echo "  -b  BUSCO database path"
    echo "  -p  Number of threads"
    echo "  -h  Show this help message"
    exit 1
}

# Parse command-line options
while getopts "i:o:b:p:h" opt; do
    case $opt in
        i) INPUT_FILE="$OPTARG" ;;
        o) RESULT_DIR="$OPTARG" ;;
        b) BUSCO_DB="$OPTARG" ;;
        p) THREADS="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

set -euo pipefail

# Validate required arguments
if [ -z "${INPUT_FILE:-}" ] || [ -z "${RESULT_DIR:-}" ] || [ -z "${BUSCO_DB:-}" ] || [ -z "${THREADS:-}" ]; then
    usage
fi

# Get base name without extension
BASENAME=$(basename "$INPUT_FILE")
BASENAME="${BASENAME%.fastq.gz}"
BASENAME="${BASENAME%.fasta.gz}"

echo "Base name: $BASENAME"

# Create output directories
mkdir -p "${RESULT_DIR}/${BASENAME}"
mkdir -p "${RESULT_DIR}/compleasm"

# Run hifiasm, disallow purge dup, only generate primary
echo "Running flye..."
    
flye \
    --threads "${THREADS}" \
    --pacbio-hifi "${INPUT_FILE}" \
    --out-dir "${RESULT_DIR}/${BASENAME}/${BASENAME}.asm" \
    --meta 
    
gzip -c "${RESULT_DIR}/${BASENAME}/${BASENAME}.asm/assembly.fasta" \
    > "${RESULT_DIR}/${BASENAME}.fasta.gz"

# Clean up intermediate directory
rm -rf "${RESULT_DIR:?}/${BASENAME}"

echo "Running quality-check..."
python quality-check.py \
    --input_file "${RESULT_DIR}/${BASENAME}.fasta.gz" \
    --output_dir "${RESULT_DIR}/compleasm" \
    --suffix "${BASENAME}" \
    --library_path "${BUSCO_DB}" \
    --threads "${THREADS}"

echo "Generating seqkit summary..."
seqkit fx2tab \
    -n -l -j "${THREADS}" \
    "${RESULT_DIR}/${BASENAME}.fasta.gz" \
    | gzip > "${RESULT_DIR}/compleasm/${BASENAME}.tsv.gz"

echo "All steps completed successfully for ${BASENAME}."