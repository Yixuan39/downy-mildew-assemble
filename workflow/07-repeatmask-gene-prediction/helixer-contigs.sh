#!/bin/bash
#SBATCH --array=0-3
#SBATCH -p gpu
#SBATCH -c 24

# Purpose : Predict genes in the three new assemblies with Helixer (fungi model in the v0.3.6
#           CUDA container) and convert the GFF3 to proteins with gffread.
# Inputs  : ${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/hardmasked/*.fasta.gz
# Outputs : ${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer/ (GFF3 + .faa)
# Runs on : GPU partition, SLURM array 0-3, 24 cores, apptainer --nv
# Usage   : sbatch workflow/07-repeatmask-gene-prediction/helixer-contigs.sh

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export GFFREAD_BIN="${GFFREAD_BIN:-$HOME/miniforge3/envs/downy/bin/gffread}"

INPUT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/hardmasked
RESULT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer
FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
mkdir -p "${RESULT_DIR}"
echo "Processing: $FILE"
BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.fasta.gz}
mkdir -p "$RESULT_DIR"
FASTA_TMP="$(mktemp -d "${RESULT_DIR}/helixer.XXXXXX")"
trap 'rm -rf "$FASTA_TMP"' EXIT
gzip -dc "$FILE" > "$FASTA_TMP/input.fasta"

nvidia-smi

apptainer run --nv --bind "$PROJECT_DATA:$PROJECT_DATA" "$HOME/software/helixer-docker_helixer_v0.3.6_cuda_12.2.2-cudnn8.sif" Helixer.py \
  --fasta-path "${FASTA_TMP}/input.fasta" --lineage fungi \
  --min-coding-length 150 \
  --gff-output-path "${RESULT_DIR}/${BASENAME}.gff"
  
sed -i 's/ID=_/ID=/g; s/Parent=_/Parent=/g' "${RESULT_DIR}/${BASENAME}.gff"

"$GFFREAD_BIN" \
  "${RESULT_DIR}/${BASENAME}.gff" \
  -g "${FASTA_TMP}/input.fasta" \
  -y "${RESULT_DIR}/${BASENAME}.faa"
  
