#!/bin/bash
#SBATCH --array=0-10
#SBATCH -p gpu
#SBATCH -c 24

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export GFFREAD_BIN="${GFFREAD_BIN:-$HOME/miniforge3/envs/downy/bin/gffread}"

INPUT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/references/hardmasked
RESULT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/references/helixer
FILES=("$INPUT_DIR"/*.fna.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"
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

apptainer run --nv --bind "$PROJECT_DATA:$PROJECT_DATA" "$HOME/software/helixer-docker_helixer_v0.3.6_cuda_12.2.2-cudnn8.sif" Helixer.py \
  --fasta-path "${FASTA_TMP}/input.fasta" --lineage fungi \
  --min-coding-length 150 \
  --gff-output-path "${RESULT_DIR}/${BASENAME}/${BASENAME}.gff"
  
sed -i 's/ID=_/ID=/g; s/Parent=_/Parent=/g' "${RESULT_DIR}/${BASENAME}/${BASENAME}.gff"

"$GFFREAD_BIN" \
  "${RESULT_DIR}/${BASENAME}/${BASENAME}.gff" \
  -g "${FASTA_TMP}/input.fasta" \
  -y "${RESULT_DIR}/${BASENAME}/${BASENAME}.faa"
  
