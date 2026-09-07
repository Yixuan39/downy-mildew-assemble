#!/bin/bash
#SBATCH --array=0-10
#SBATCH -p gpu
#SBATCH -c 24

# Purpose : Same Helixer prediction for the published genomes, giving a like-for-like gene set for the
#           annotation comparison.
# Inputs  : ${PROJECT_DATA}/results/repeatmask-gene-prediction/references/hardmasked/*.fna.gz
# Outputs : ${PROJECT_DATA}/results/repeatmask-gene-prediction/references/helixer/
# Runs on : GPU partition, SLURM array 0-10, 24 cores, apptainer --nv
# Usage   : sbatch workflow/07-repeatmask-gene-prediction/helixer-published-genomes.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

INPUT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/references/hardmasked
RESULT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/references/helixer
FILES=("$INPUT_DIR"/*.fna.gz)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }

echo "Processing: $FILE"
BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.fna.gz}
mkdir -p "$RESULT_DIR"
FASTA_TMP="$(mktemp -d "${RESULT_DIR}/helixer.XXXXXX")"
trap 'rm -rf "$FASTA_TMP"' EXIT
gzip -dc "$FILE" > "$FASTA_TMP/input.fasta"
mkdir -p "${RESULT_DIR}/${BASENAME}"

nvidia-smi

# helixer_post_bin ships empty in this image; supply the locally-built binary and its
# HDF5 runtime library via bind mount + LD_LIBRARY_PATH (both env var prefixes covered
# since CONTAINER_RUNTIME may be apptainer or singularity).
export APPTAINERENV_LD_LIBRARY_PATH="$HELIXER_POST_LIB_DIR"
export SINGULARITYENV_LD_LIBRARY_PATH="$HELIXER_POST_LIB_DIR"

"$CONTAINER_RUNTIME" run --nv --bind "$PROJECT_DATA:$PROJECT_DATA" \
  --bind "$HELIXER_POST_BIN_DIR:/home/helixer_user/bin" \
  --bind "$HELIXER_POST_LIB_DIR:$HELIXER_POST_LIB_DIR" \
  "${HELIXER_IMAGE:-docker://gglyptodon/helixer-docker:helixer_v0.3.6_cuda_12.2.2-cudnn8}" Helixer.py \
  --fasta-path "${FASTA_TMP}/input.fasta" --lineage fungi \
  --min-coding-length 150 \
  --gff-output-path "${RESULT_DIR}/${BASENAME}/${BASENAME}.gff"
  
sed -i 's/ID=_/ID=/g; s/Parent=_/Parent=/g' "${RESULT_DIR}/${BASENAME}/${BASENAME}.gff"

"$GFFREAD_BIN" \
  "${RESULT_DIR}/${BASENAME}/${BASENAME}.gff" \
  -g "${FASTA_TMP}/input.fasta" \
  -y "${RESULT_DIR}/${BASENAME}/${BASENAME}.faa"
  

