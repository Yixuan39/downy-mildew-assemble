#!/bin/bash

usage() {
    echo "Usage: $0 -a <asm_file> -r <raw_file> -o <output_dir> -b <busco_db> -p <threads>"
    echo ""
    echo "  -a  Input FASTA file"
    echo "  -r  Raw HIFI FASTQ file"
    echo "  -o  Output directory"
    echo "  -b  BUSCO database path"
    echo "  -p  Number of threads"
    echo "  -h  Show this help message"
    exit 1
}

# Parse command-line options
while getopts "a:r:o:b:p:h" opt; do
    case $opt in
        a) ASM_FILE="$OPTARG" ;;
        r) RAW_FILE="$OPTARG" ;;
        o) RESULT_DIR="$OPTARG" ;;
        b) BUSCO_DB="$OPTARG" ;;
        p) THREADS="$OPTARG" ;;
        h) usage ;;
    esac
done
set -euo pipefail
# get base name
BASENAME=$(basename "$ASM_FILE")  
BASENAME=${BASENAME%.fasta.gz}  
mkdir -p "${RESULT_DIR}/${BASENAME}"
echo "Base name: $BASENAME"

# 3. self mapping
minimap2 -xasm20 -t "${THREADS}" \
  "${ASM_FILE}" \
  "${RAW_FILE}" | gzip -c - \
  > "${RESULT_DIR}/${BASENAME}/${BASENAME}.paf.gz"

# 4. Coverage stats & cutoff   
pbcstat -O "${RESULT_DIR}/${BASENAME}" \
  "${RESULT_DIR}/${BASENAME}/${BASENAME}.paf.gz"

calcuts "${RESULT_DIR}/${BASENAME}/PB.stat" \
  > "${RESULT_DIR}/${BASENAME}/cutoffs"

split_fa \
  "${ASM_FILE}" \
  > "${RESULT_DIR}/${BASENAME}/${BASENAME}.split.fasta"

minimap2 -xasm5 -DP -t "${THREADS}" \
  "${RESULT_DIR}/${BASENAME}/${BASENAME}.split.fasta" \
  "${RESULT_DIR}/${BASENAME}/${BASENAME}.split.fasta" \
  | gzip -c - > "${RESULT_DIR}/${BASENAME}/${BASENAME}.split.self.paf.gz"

purge_dups -2 \
  -T "${RESULT_DIR}/${BASENAME}/cutoffs" \
  -c "${RESULT_DIR}/${BASENAME}/PB.base.cov" \
  "${RESULT_DIR}/${BASENAME}/${BASENAME}.split.self.paf.gz" \
  > "${RESULT_DIR}/${BASENAME}/${BASENAME}.dups.bed"

# 6. Generate purged and haplotig FASTA
get_seqs -e \
  -p "${RESULT_DIR}/${BASENAME}/${BASENAME}" \
  "${RESULT_DIR}/${BASENAME}/${BASENAME}.dups.bed" \
  "${ASM_FILE}"
  
gzip -c "${RESULT_DIR}/${BASENAME}/${BASENAME}.purged.fa" \
  > "${RESULT_DIR}/${BASENAME}.fasta.gz"

# 7. Run quality-check from current directory
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
    
hist_plot.py \
  -c "${RESULT_DIR}/${BASENAME}/cutoffs" \
  "${RESULT_DIR}/${BASENAME}/PB.stat" \
  "${RESULT_DIR}/compleasm/${BASENAME}.png"

rm -rf "${RESULT_DIR}/${BASENAME}"
