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
    esac
done
set -euo pipefail
# get base name
BASENAME=$(basename "$INPUT_FILE")  
BASENAME=${BASENAME%.fastq.gz}  
mkdir -p "${RESULT_DIR}/${BASENAME}"
echo "Base name: $BASENAME"

# 1. Run hifiasm with --primary
hifiasm \
  -t "${THREADS}" \
  --primary \
  -o "${RESULT_DIR}/${BASENAME}/${BASENAME}.asm" \
  "${INPUT_FILE}"

# 2. Convert primary GFA to FASTA
gfatools gfa2fa \
  "${RESULT_DIR}/${BASENAME}/${BASENAME}.asm.p_ctg.gfa" \
  > "${RESULT_DIR}/${BASENAME}/${BASENAME}.asm.p_ctg.fa"
  
gzip -c "${RESULT_DIR}/${BASENAME}/${BASENAME}.asm.p_ctg.fa" > "${RESULT_DIR}/${BASENAME}.fasta.gz"
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


