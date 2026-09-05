#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 32
#SBATCH --mem=0

# Purpose : DIAMOND blastp of the Helixer proteins against NCBI nr, for the homology-based half of the
#           annotation support table.
# Inputs  : ${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer/*.faa; nr.dmnd at ${DB_ROOT}/nr.dmnd
# Outputs : ${PROJECT_DATA}/results/functional-annotation/blastp/<genome>.tsv
# Runs on : SLURM array 0-3, 32 cores
# Usage   : sbatch workflow/09-functional-annotation/protein-diamond-blastp.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

INPUT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer
RESULT_DIR=${PROJECT_DATA}/results/functional-annotation/blastp
FILES=("$INPUT_DIR"/*.faa)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
THREADS=32
mkdir -p "${RESULT_DIR}"
echo "Processing: $FILE"
BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.faa}

mamba run -n diamond diamond blastp \
--threads "$THREADS" \
--evalue 1e-3 \
--max-target-seqs 1 \
--db "${DB_ROOT}/diamond/nr.dmnd" \
--sensitive \
--index-chunks 1 \
--query "$FILE" \
--header simple \
--out "$RESULT_DIR/$BASENAME.tsv" \
--outfmt 6 qseqid sseqid pident length qlen slen evalue qstart qend sstart send staxids sphylums sgenus sspecies
