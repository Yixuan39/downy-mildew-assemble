#!/bin/bash

EXTRACT=true

usage() {
    echo "Usage: $0 -i <input_file> -o <output_dir> -d <gx_db> -k <kraken_db> -b <busco_db> -c <confidence_score> -t <taxid> -m <min_length> -p <threads>"
    echo ""
    echo "  -i  Input FASTQ file (required)"
    echo "  -o  Output directory (required)"
    echo "  -d  GX database path (required)"
    echo "  -k  Kraken database path (required)"
    echo "  -b  BUSCO database path (required)"
    echo "  -c  Confidence score [default: 0]"
    echo "  -t  Taxonomic ID (required)"
    echo "  -e  Extract reads classified as TAXID [default: ${EXTRACT}]"
    echo "  -m  Minimum sequence length [default: 5000]"
    echo "  -p  Number of threads [default: 8]"
    echo "  -h  Show help message"
    exit 1
}

# Default values
CS=0
MIN_LENGTH=5000
THREADS=8

# Parse command-line options
while getopts "i:o:d:k:b:c:t:e:m:p:h" opt; do
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
        *) usage ;;
    esac
done

# Validate required parameters
if [[ -z $INPUT_FILE || -z $RESULT_DIR || -z $GX_DB || -z $KrakenDB || -z $BUSCO_DB || -z $TAXID ]]; then
    echo "Missing required arguments."
    usage
fi

mkdir -p "${RESULT_DIR}"

export GX_NUM_CORES=$THREADS
BASENAME=$(basename "${INPUT_FILE%.fastq.gz}")
BASENAME=${BASENAME%.fq.gz}

echo "Starting assembly pipeline for ${BASENAME}"

# Assembly step
echo "Running metaMDBG assembly..."
metaMDBG asm \
    --out-dir ${RESULT_DIR}/${BASENAME}.asm \
    --in-hifi ${INPUT_FILE} \
    --threads ${THREADS} || { echo "[ERROR] metaMDBG failed"; exit 1; }

# Filtering short contigs
echo "Filtering contigs shorter than ${MIN_LENGTH} bp..."
seqkit seq \
    --threads ${THREADS} \
    --min-len ${MIN_LENGTH} \
    --out-file ${RESULT_DIR}/${BASENAME}.asm.fasta.gz \
    ${RESULT_DIR}/${BASENAME}.asm/contigs.fasta.gz

# FCS contamination removal
echo "Running FCS for contamination screening..."
run_gx.py \
    --fasta ${RESULT_DIR}/${BASENAME}.asm.fasta.gz \
    --tax-id ${TAXID} \
    --gx-db ${GX_DB} \
    --out-dir ${RESULT_DIR} \
    --out-basename ${BASENAME}

gx clean-genome \
    --input ${RESULT_DIR}/${BASENAME}.asm.fasta.gz \
    --action-report ${RESULT_DIR}/${BASENAME}.fcs_gx_report.txt \
    --output ${RESULT_DIR}/${BASENAME}.fcs.fasta

gzip ${RESULT_DIR}/${BASENAME}.fcs.fasta

# Convert CS into array
IFS=',' read -ra CS_ARRAY <<< "$CS"

# Loop through confidence scores
for CURRENT_CS in "${CS_ARRAY[@]}"; do
    CURRENT_SUFFIX="kraken_cs_${CURRENT_CS}"
    echo "[INFO] Running Kraken2 with confidence score ${CURRENT_CS}"
    mkdir -p ${RESULT_DIR}/${CURRENT_CS}
    cp ${RESULT_DIR}/${BASENAME}.fcs.fasta.gz ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.fcs.fasta.gz
    
    if [[ "$(echo "$EXTRACT" | tr '[:upper:]' '[:lower:]')" =~ ^(true|yes|1)$ ]]; then
        kraken2 \
            --db ${KrakenDB} \
            --confidence ${CURRENT_CS} \
            --threads ${THREADS} \
            --output ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kraken \
            --report ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kreport \
            ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.fcs.fasta.gz

        extract_kraken_reads.py \
            -k ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kraken \
            -s ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.fcs.fasta.gz \
            --report ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kreport \
            --taxid ${TAXID} \
            --output ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kraken.fasta \
            --include-children
    else
        kraken2 \
            --db ${KrakenDB} \
            --confidence ${CURRENT_CS} \
            --threads ${THREADS} \
            --output ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kraken \
            --report ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kreport \
            --unclassified-out ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kraken.fasta \
            ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.fcs.fasta.gz
    fi

    # Compress fasta
    gzip -f ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kraken.fasta

    # Remove intermediate Kraken file
    rm ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kraken
    
    python quality-check.py \
        --input_file ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.fcs.fasta.gz \
        --output_dir ${RESULT_DIR}/${CURRENT_CS} \
        --suffix ${BASENAME}.fcs \
        --library_path ${BUSCO_DB} \
        --threads ${THREADS}

    python quality-check.py \
        --input_file ${RESULT_DIR}/${CURRENT_CS}/${BASENAME}.kraken.fasta.gz \
        --output_dir ${RESULT_DIR}/${CURRENT_CS} \
        --suffix ${BASENAME}.kraken \
        --library_path ${BUSCO_DB} \
        --threads ${THREADS}
done

# Cleanup temporary assembly files
echo "[INFO] Cleaning up temporary files..."
rm -rf ${RESULT_DIR}/${BASENAME}.asm
rm ${RESULT_DIR}/${BASENAME}.asm.fasta.gz
rm ${RESULT_DIR}/${BASENAME}.fcs.fasta.gz

echo "[INFO] Pipeline successfully completed!"
