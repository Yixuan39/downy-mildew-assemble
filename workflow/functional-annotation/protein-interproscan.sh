#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 24

# Purpose : Assign InterPro domains and GO terms to the Helixer proteins with InterProScan 5.77-108.0 in a
#           container.
# Inputs  : ${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer/*.faa; ${DB_ROOT}/interproscan-5.77-108.0
# Outputs : ${PROJECT_DATA}/results/functional-annotation/interproscan/<genome>/
# Runs on : SLURM array 0-3, 24 cores, apptainer
# Usage   : sbatch workflow/functional-annotation/protein-interproscan.sh

set -euo pipefail

PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
DB_ROOT="${DB_ROOT:-$HOME/db}"
SOFTWARE_ROOT="${SOFTWARE_ROOT:-$HOME/software}"
INPUT_DIR="$PROJECT_DATA/results/repeatmask-gene-prediction/focal/helixer"
RESULT_DIR="$PROJECT_DATA/results/functional-annotation/interproscan"
FILES=("$INPUT_DIR"/*.faa)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
THREADS=24

BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.faa}
mkdir -p "${RESULT_DIR}/${BASENAME}"

ANNOTATION_TMP=${RESULT_DIR}/${BASENAME}_tmp
mkdir -p "$ANNOTATION_TMP"

apptainer exec \
--bind "$PROJECT_DATA:$PROJECT_DATA" \
--bind "${DB_ROOT}/interproscan-5.77-108.0/data:/opt/interproscan/data" \
"$SOFTWARE_ROOT/interproscan_5.77-108.0.sif" \
/opt/interproscan/interproscan.sh \
--cpu "$THREADS" \
--output-dir "${RESULT_DIR}/${BASENAME}" \
--formats TSV,GFF3 \
--disable-precalc \
--goterms \
--iprlookup \
--pathways \
--input "$FILE" \
--tempdir "$ANNOTATION_TMP"
