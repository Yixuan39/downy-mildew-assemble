#!/bin/bash
#SBATCH --array=0-10
#SBATCH -c 32
#SBATCH --mem=0

# Purpose : Same per-genome RepeatModeler/RepeatMasker treatment for the published genomes, so gene
#           prediction sees comparably masked input.
# Inputs  : ${PROJECT_DATA}/inputs/reference-genomes/*.fna.gz
# Outputs : ${PROJECT_DATA}/results/repeatmask-gene-prediction/references/hardmasked/
# Runs on : SLURM array 0-10, 32 cores
# Usage   : sbatch workflow/07-repeatmask-gene-prediction/hard-mask-published-genomes.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

THREADS=$SLURM_CPUS_PER_TASK
INPUT_DIR=${PROJECT_DATA}/inputs/reference-genomes
RESULT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/references/hardmasked
FILES=("$INPUT_DIR"/*.fna.gz)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
echo "Processing: $FILE"
BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.fna.gz}
TMP_DIR=${RESULT_DIR}/${BASENAME}_tmp
# decompress the original file to result directory
mkdir -p "${TMP_DIR}" "${RESULT_DIR}/${BASENAME}_masked"
cd "$TMP_DIR"
gzip -dc "$FILE" > "${TMP_DIR}/${BASENAME}.fna"

BuildDatabase \
  -name "${TMP_DIR}/db" \
  "${TMP_DIR}/${BASENAME}.fna"

RepeatModeler \
  -threads "$THREADS" \
  -database "${TMP_DIR}/db" > "${TMP_DIR}/${BASENAME}.out"

RepeatMasker \
  -engine ncbi \
  -parallel $((THREADS / 4)) \
  -gff \
  -lib "${TMP_DIR}/db-families.fa" \
  -dir "${RESULT_DIR}/${BASENAME}_masked" \
  "${TMP_DIR}/${BASENAME}.fna"

cp "${RESULT_DIR}/${BASENAME}_masked/${BASENAME}.fna.masked" "${RESULT_DIR}/${BASENAME}.fna"
gzip -f "${RESULT_DIR}/${BASENAME}.fna"
