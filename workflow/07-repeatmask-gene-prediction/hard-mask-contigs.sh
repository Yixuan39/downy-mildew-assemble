#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 32
#SBATCH --mem=0

# Purpose : Build a per-assembly repeat library with RepeatModeler and hard-mask the three new assemblies
#           with RepeatMasker.
# Inputs  : ${PROJECT_DATA}/results/assembly-qc/nuclear/*.fasta.gz
# Outputs : ${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/hardmasked/
# Runs on : SLURM array 0-3, 32 cores
# Usage   : sbatch workflow/07-repeatmask-gene-prediction/hard-mask-contigs.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

THREADS=$SLURM_CPUS_PER_TASK
INPUT_DIR=${PROJECT_DATA}/results/assembly-qc/nuclear
RESULT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/hardmasked
FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
echo "Processing: $FILE"
BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.fasta.gz}
TMP_DIR=${RESULT_DIR}/${BASENAME}_tmp
# decompress the original file to result directory
mkdir -p "${TMP_DIR}" "${RESULT_DIR}/${BASENAME}_masked"
cd "$TMP_DIR"
gzip -dc "$FILE" > "${TMP_DIR}/${BASENAME}.fasta"

BuildDatabase \
  -name "${TMP_DIR}/db" \
  "${TMP_DIR}/${BASENAME}.fasta"

RepeatModeler \
  -threads "$THREADS" \
  -database "${TMP_DIR}/db" > "${TMP_DIR}/${BASENAME}.out"

RepeatMasker \
  -engine ncbi \
  -parallel $((THREADS / 4)) \
  -gff \
  -lib "${TMP_DIR}/db-families.fa" \
  -dir "${RESULT_DIR}/${BASENAME}_masked" \
  "${TMP_DIR}/${BASENAME}.fasta"

cp "${RESULT_DIR}/${BASENAME}_masked/${BASENAME}.fasta.masked" "${RESULT_DIR}/${BASENAME}.fasta"
gzip -f "${RESULT_DIR}/${BASENAME}.fasta"
