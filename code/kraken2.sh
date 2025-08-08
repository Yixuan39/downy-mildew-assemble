#!/bin/bash

# --- Script Configuration ---
# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# --- Default Parameters ---
THREADS=1
CONFIDENCE=0.0
MODE="check" # Default mode
TAXID=""
BUSCO_DB=""

# --- Usage Function ---
usage() {
  cat << EOF
Usage: $0 -i <input.fastq> -o <output_dir> -k <kraken_db> [OPTIONS]

This script runs Kraken2 in one of three modes: check, extract, or exclude.

REQUIRED:
  -i <input.fastq>    Input FASTQ file (can be gzipped).
  -o <output_dir>     Directory to store all results.
  -k <kraken_db>      Path to the Kraken2 database.

MODES:
  -m <mode>           Operation mode. One of:
                      'check'   - Run Kraken2 and generate a report. (Default)
                      'extract' - Extract reads matching a specific TAXID, then run quality check.
                      'exclude' - Exclude reads matching a specific TAXID, then run quality check.

OPTIONS for 'extract' and 'exclude' modes:
  -t <taxid>          Taxonomic ID to target for extraction or exclusion. REQUIRED for these modes.
  -b <busco_db>       Path to the BUSCO/Compleasm library for quality check. REQUIRED for these modes.
  -c <confidence>     Confidence score for classification (0.0-1.0). Default: ${CONFIDENCE}.

GENERAL OPTIONS:
  -p <threads>        Number of threads to use. Default: ${THREADS}.
  -h                  Display this help message and exit.

EOF
  exit 1
}

# --- Parse Command-Line Arguments ---
while getopts "i:o:k:m:t:c:p:b:h" opt; do
  case ${opt} in
    i) INPUT_FILE="$OPTARG" ;;
    o) RESULT_DIR="$OPTARG" ;;
    k) KRAKEN_DB="$OPTARG" ;;
    m) MODE="$OPTARG" ;;
    t) TAXID="$OPTARG" ;;
    c) CONFIDENCE="$OPTARG" ;;
    p) THREADS="$OPTARG" ;;
    b) BUSCO_DB="$OPTARG" ;;
    h) usage ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# --- Validate Arguments ---
if [[ -z "${INPUT_FILE:-}" || -z "${RESULT_DIR:-}" || -z "${KRAKEN_DB:-}" ]]; then
    echo "Error: Missing required arguments: -i, -o, and -k."
    usage
fi

if [[ "$MODE" != "check" && -z "$TAXID" ]]; then
    echo "Error: Mode '$MODE' requires a taxonomic ID (-t)."
    usage
fi

if [[ ( "$MODE" == "extract" || "$MODE" == "exclude" ) && -z "$BUSCO_DB" ]]; then
    echo "Error: Mode '$MODE' requires a BUSCO library path (-b) for the quality check."
    usage
fi


mkdir -p "${RESULT_DIR}"

# get base name
BASENAME=$(basename "$INPUT_FILE")  
BASENAME=${BASENAME%.fastq.gz}
BASENAME=${BASENAME%.fasta.gz}  


echo "Input File:   ${INPUT_FILE}"
echo "Output Dir:   ${RESULT_DIR}"
echo "Kraken DB:    ${KRAKEN_DB}"
echo "Mode:         ${MODE}"
echo "Threads:      ${THREADS}"
if [[ "$MODE" != "check" ]]; then
    echo "Taxon ID:     ${TAXID}"
    echo "Confidence:   ${CONFIDENCE}"
    echo "BUSCO DB:     ${BUSCO_DB}"
fi


# Define output file paths
KRAKEN_OUT="${RESULT_DIR}/${BASENAME}.kraken"
KREPORT_OUT="${RESULT_DIR}/${BASENAME}.kreport"

# --- Mode Execution ---
if [ "$MODE" = "check" ]; then
    echo "Running in 'check' mode..."
    kraken2 \
      --db "${KRAKEN_DB}" \
      --threads "${THREADS}" \
      --output "${KRAKEN_OUT}" \
      --report "${KREPORT_OUT}" \
      --use-names \
      "${INPUT_FILE}"

elif [ "$MODE" = "extract" ] || [ "$MODE" = "exclude" ]; then
    
    if [ "$MODE" = "extract" ]; then
        echo "Running in 'extract' mode for TAXID ${TAXID}..."
        kraken2 \
          --db "${KRAKEN_DB}" \
          --threads "${THREADS}" \
          --confidence "${CONFIDENCE}" \
          --report "${KREPORT_OUT}" \
          --output "${KRAKEN_OUT}" \
          "${INPUT_FILE}"
          
        extract_kraken_reads.py \
          -k "${KRAKEN_OUT}" \
          -s "${INPUT_FILE}" \
          --report "${KREPORT_OUT}" \
          --taxid ${TAXID} \
          --output "${RESULT_DIR}/${BASENAME}.fasta" \
          --include-children
          
    else # exclude mode
        echo "Running in 'exclude' mode for TAXID ${TAXID}..."
        kraken2 \
          --db "${KRAKEN_DB}" \
          --threads "${THREADS}" \
          --confidence "${CONFIDENCE}" \
          --report "${KREPORT_OUT}" \
          --output "${KRAKEN_OUT}" \
          --unclassified-out "${RESULT_DIR}/${BASENAME}.fasta" \
          --taxid "${TAXID}" \
          --include-children \
          "${INPUT_FILE}"
    fi

    echo "Compressing filtered reads..."
    gzip -c "${RESULT_DIR}/${BASENAME}.fasta" > "${RESULT_DIR}/${BASENAME}.fasta.gz"
    rm "${RESULT_DIR}/${BASENAME}.fasta"

    echo "--- Starting Quality Check ---"
    python quality-check.py \
      --input_file "${RESULT_DIR}/${BASENAME}.fasta.gz" \
      --output_dir "${RESULT_DIR}/compleasm" \
      --suffix "${BASENAME}" \
      --library_path "${BUSCO_DB}" \
      --threads "${THREADS}"
else
    echo "Error: Invalid mode specified. Use 'check', 'extract', or 'exclude'."
    usage
fi

