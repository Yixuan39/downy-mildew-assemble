#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 24

# Purpose : Functionally annotate the Helixer proteins with eggNOG-mapper (DIAMOND search mode).
# Inputs  : $HOME/project_data/downy/results/repeatmask-gene-prediction/focal/helixer/*.faa; $HOME/db/eggnog
# Outputs : $HOME/project_data/downy/results/functional-annotation/eggnog-mapper/<genome>/
# Runs on : SLURM array 0-3, 24 cores
# Usage   : sbatch workflow/08-annotation/protein-eggnog.sh

set -euo pipefail

PD="$HOME/project_data/downy"
INPUT_DIR="$PD/results/repeatmask-gene-prediction/focal/helixer"
RESULT_DIR="$PD/results/functional-annotation/eggnog-mapper"
FILES=("$INPUT_DIR"/*.faa)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"
THREADS=24

BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.faa}
mkdir -p "${RESULT_DIR}/${BASENAME}"

ANNOTATION_TMP=${RESULT_DIR}/${BASENAME}_tmp
mkdir -p "$ANNOTATION_TMP"

"$HOME/miniforge3/bin/mamba" run -n eggnog-mapper emapper.py \
-i "${FILE}" \
--itype proteins \
-m diamond \
--cpu "${THREADS}" \
--data_dir "$HOME/db/eggnog" \
--output "${BASENAME}" \
--output_dir "${RESULT_DIR}/${BASENAME}" \
--temp_dir "${ANNOTATION_TMP}" \
--override \
--sensmode sensitive \
--tax_scope eukaryota \
--go_evidence non-electronic
