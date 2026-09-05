#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 24
#SBATCH --mem=0

# Purpose : Functionally annotate the Helixer proteins with eggNOG-mapper (DIAMOND search mode).
# Inputs  : ${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer/*.faa; eggNOG DB at ${DB_ROOT}/eggnog
# Outputs : ${PROJECT_DATA}/results/functional-annotation/eggnog-mapper/<genome>/
# Runs on : SLURM array 0-3, 24 cores
# Usage   : sbatch workflow/09-functional-annotation/protein-eggnog.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

INPUT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer
RESULT_DIR=${PROJECT_DATA}/results/functional-annotation/eggnog-mapper
FILES=("$INPUT_DIR"/*.faa)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
THREADS=24

echo "Processing: $FILE"
BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.faa}
mkdir -p "${RESULT_DIR}/${BASENAME}"

ANNOTATION_TMP=${RESULT_DIR}/${BASENAME}_tmp
mkdir -p "$ANNOTATION_TMP"

mamba run -n eggnog-mapper emapper.py \
-i "${FILE}" \
--itype proteins \
-m diamond \
--cpu "${THREADS}" \
--data_dir "${DB_ROOT}/eggnog" \
--output "${BASENAME}" \
--output_dir "${RESULT_DIR}/${BASENAME}" \
--temp_dir "${ANNOTATION_TMP}" \
--override \
--sensmode sensitive \
--tax_scope eukaryota \
--go_evidence non-electronic
