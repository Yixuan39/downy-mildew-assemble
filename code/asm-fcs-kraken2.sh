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
    esac
done

export GX_NUM_CORES=$THREADS
# # get base name
# BASENAME=$(basename "$INPUT_FILE")  
# BASENAME=${BASENAME%.fastq.gz}  
# BASENAME=${BASENAME%.fq.gz}  
# BASENAME=${BASENAME%.fastq}  
# BASENAME=${BASENAME%.fq} 
# 
# echo "Base name: $BASENAME"

# # assemble the genome
# metaMDBG asm \
#     --out-dir ${RESULT_DIR}/${BASENAME}.asm \
#     --in-hifi ${INPUT_FILE} \
#     --threads ${THREADS}
#     
# get base name
BASENAME=$(basename "$INPUT_FILE")  
BASENAME=${BASENAME%.fasta.gz}  
echo "Base name: $BASENAME"

# discard contigs shorter than 5000 bp
# previous input file: ${RESULT_DIR}/${BASENAME}.asm/contigs.fasta.gz \
seqtk seq \
    -L ${MIN_LENGTH} \
    ${INPUT_FILE} \
    | gzip > ${RESULT_DIR}/${BASENAME}.asm.fasta.gz

# fcs screen and remove contamination
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

if [ "$EXTRACT" = true ]
then
    # run kraken2
    kraken2 \
        --db ${KrakenDB} \
        --confidence ${CS} \
        --threads ${THREADS} \
        --output ${RESULT_DIR}/${BASENAME}.kraken \
        --report ${RESULT_DIR}/${BASENAME}.kreport \
        ${RESULT_DIR}/${BASENAME}.fcs.fasta
    # extract sequences classified as TAXID
    extract_kraken_reads.py \
        -k ${RESULT_DIR}/${BASENAME}.kraken \
        -s ${RESULT_DIR}/${BASENAME}.fcs.fasta \
        --report ${RESULT_DIR}/${BASENAME}.kreport \
        --taxid ${TAXID} \
        --output ${RESULT_DIR}/${BASENAME}.kraken.fasta \
        --include-children
else
    kraken2 \
        --db ${KrakenDB} \
        --confidence ${CS} \
        --threads ${THREADS} \
        --output ${RESULT_DIR}/${BASENAME}.kraken \
        --report ${RESULT_DIR}/${BASENAME}.kreport \
        --unclassified-out ${RESULT_DIR}/${BASENAME}.kraken.fasta \
        ${RESULT_DIR}/${BASENAME}.fcs.fasta
fi 

# compress both INPUT_FILEs
gzip ${RESULT_DIR}/${BASENAME}.fcs.fasta
gzip ${RESULT_DIR}/${BASENAME}.kraken.fasta
# remove useless files
rm ${RESULT_DIR}/${BASENAME}.kraken
rm ${RESULT_DIR}/${BASENAME}.asm.fasta.gz
  
# get quality report for fcs cleaned INPUT_FILE
python quality-check.py \
    --input_file ${RESULT_DIR}/${BASENAME}.fcs.fasta.gz \
    --output_dir ${RESULT_DIR} \
    --suffix ${BASENAME}.fcs \
    --library_path ${BUSCO_DB} \
    --threads ${THREADS}
    # get quality report for kraken2 cleaned INPUT_FILE
python quality-check.py \
    --input_file ${RESULT_DIR}/${BASENAME}.kraken.fasta.gz \
    --output_dir ${RESULT_DIR} \
    --suffix ${BASENAME}.kraken \
    --library_path ${BUSCO_DB} \
    --threads ${THREADS}


