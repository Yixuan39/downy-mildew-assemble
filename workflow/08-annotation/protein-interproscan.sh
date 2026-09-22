#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 24

# Purpose : Assign InterPro domains and GO terms to the Helixer proteins with InterProScan 5.77-108.0 in a
#           container.
# Inputs  : $HOME/project_data/downy/results/repeatmask-gene-prediction/focal/helixer/*.faa; $HOME/db/interproscan-5.77-108.0
# Outputs : $HOME/project_data/downy/results/functional-annotation/interproscan/<genome>/
# Runs on : SLURM array 0-3, 24 cores, apptainer
# Usage   : sbatch workflow/08-annotation/protein-interproscan.sh

set -euo pipefail

PD="$HOME/project_data/downy"
INPUT_DIR="$PD/results/repeatmask-gene-prediction/focal/helixer"
RESULT_DIR="$PD/results/functional-annotation/interproscan"
FILES=("$INPUT_DIR"/*.faa)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"
THREADS=24

BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.faa}
mkdir -p "${RESULT_DIR}/${BASENAME}"

ANNOTATION_TMP=${RESULT_DIR}/${BASENAME}_tmp
mkdir -p "$ANNOTATION_TMP"

apptainer exec \
--bind "$PD:$PD" \
--bind "$HOME/db/interproscan-5.77-108.0/data:/opt/interproscan/data" \
"$HOME/software/interproscan_5.77-108.0.sif" \
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
