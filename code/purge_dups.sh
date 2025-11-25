#!/bin/bash

usage() {
    echo "Usage: $0 -a <asm_file> -r <raw_file> -o <output_dir> -b <busco_db> -p <threads> [options]"
    echo ""
    echo "Required arguments:"
    echo "  -a  Input FASTA file"
    echo "  -r  Raw HIFI FASTQ file"
    echo "  -o  Output directory"
    echo "  -b  BUSCO database path"
    echo "  -p  Number of threads"
    echo ""
    echo "Optional purge_dups parameters:"
    echo "  To set manual cutoffs, all three (-l, -m, -u) must be provided."
    echo "  If not provided, cutoffs will be determined automatically."
    echo "  -l  Low cutoff"
    echo "  -m  Mid cutoff"
    echo "  -u  Upper cutoff"
    echo ""
    echo "Other options:"
    echo "  -h  Show this help message"
    exit 1
}

# Initialize cutoff variables
LOW_CUTOFF=""
MID_CUTOFF=""
UPPER_CUTOFF=""

# Parse command-line options
while getopts "a:r:o:b:p:l:m:u:h" opt; do
    case $opt in
        a) ASM_FILE="$OPTARG" ;;
        r) RAW_FILE="$OPTARG" ;;
        o) RESULT_DIR="$OPTARG" ;;
        b) BUSCO_DB="$OPTARG" ;;
        p) THREADS="$OPTARG" ;;
        l) LOW_CUTOFF="$OPTARG" ;;
        m) MID_CUTOFF="$OPTARG" ;;
        u) UPPER_CUTOFF="$OPTARG" ;;
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

# Check if all three manual cutoffs were provided
if [ -n "$LOW_CUTOFF" ] && [ -n "$MID_CUTOFF" ] && [ -n "$UPPER_CUTOFF" ]; then
    echo "Using provided manual cutoffs: low=${LOW_CUTOFF}, mid=${MID_CUTOFF}, upper=${UPPER_CUTOFF}"
    calcuts -l "${LOW_CUTOFF}" -m "${MID_CUTOFF}" -u "${UPPER_CUTOFF}" "${RESULT_DIR}/${BASENAME}/PB.stat" \
      > "${RESULT_DIR}/${BASENAME}/cutoffs"
else
    echo "Using automatic cutoffs from calcuts."
    calcuts "${RESULT_DIR}/${BASENAME}/PB.stat" \
      > "${RESULT_DIR}/${BASENAME}/cutoffs"
fi
mkdir -p ${RESULT_DIR}/compleasm
hist_plot.py \
  -c "${RESULT_DIR}/${BASENAME}/cutoffs" \
  "${RESULT_DIR}/${BASENAME}/PB.stat" \
  "${RESULT_DIR}/compleasm/${BASENAME}.png"

split_fa \
  "${ASM_FILE}" \
  > "${RESULT_DIR}/${BASENAME}/${BASENAME}.split.fasta"

minimap2 -xasm5 -DP -t "${THREADS}" \
  "${RESULT_DIR}/${BASENAME}/${BASENAME}.split.fasta" \
  "${RESULT_DIR}/${BASENAME}/${BASENAME}.split.fasta" \
  | gzip -c - > "${RESULT_DIR}/${BASENAME}/${BASENAME}.split.self.paf.gz"

purge_dups \
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

# remove the temporary directory
rm -rf "${RESULT_DIR}/${BASENAME}"