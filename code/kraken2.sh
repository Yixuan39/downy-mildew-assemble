#!/bin/bash

usage() {
    echo "Usage: $0 -i <input_file> -o <output_dir> -d <gx_db> -p <threads>"
    echo ""
    echo "  -i  Input FASTQ file"
    echo "  -o  Output directory"
    echo "  -d  Kraken2 database path"
    echo "  -p  Number of threads"
    echo "  -h  Show this help message"
    exit 1
}

# Parse command-line options
while getopts "i:o:d:p:h" opt; do
    case $opt in
        i) INPUT_FILE="$OPTARG" ;;
        o) RESULT_DIR="$OPTARG" ;;
        d) Kraken_DB="$OPTARG" ;;
        p) THREADS="$OPTARG" ;;
        h) usage ;;
    esac
done
set -euo pipefail

# get base name
BASENAME=$(basename "$INPUT_FILE")  
 
echo "Base name: $BASENAME"

kraken2 \
  --db ${Kraken_DB} \
  --threads ${THREADS} \
  --output ${RESULT_DIR}/${BASENAME}.kraken \
  --report ${RESULT_DIR}/${BASENAME}.kreport \
  ${INPUT_FILE}
