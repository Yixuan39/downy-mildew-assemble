#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 24

# Purpose : DIAMOND blastp of the Helixer proteins against NCBI nr, for the homology-based half of the
#           annotation support table.
# Inputs  : $HOME/project_data/downy/results/repeatmask-gene-prediction/focal/helixer/*.faa; $HOME/db/diamond/nr.dmnd
# Outputs : $HOME/project_data/downy/results/functional-annotation/blastp/<genome>.tsv
# Runs on : SLURM array 0-3, 24 cores
# Usage   : sbatch workflow/08-annotation/protein-diamond-blastp.sh

set -euo pipefail

PD="$HOME/project_data/downy"
INPUT_DIR="$PD/results/repeatmask-gene-prediction/focal/helixer"
RESULT_DIR="$PD/results/functional-annotation/blastp"
FILES=("$INPUT_DIR"/*.faa)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"
THREADS=24
mkdir -p "${RESULT_DIR}"
BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.faa}

"$HOME/miniforge3/bin/mamba" run -n diamond diamond blastp \
--threads "$THREADS" \
--evalue 1e-3 \
--max-target-seqs 1 \
--db "$HOME/db/diamond/nr.dmnd" \
--sensitive \
--index-chunks 1 \
--query "$FILE" \
--header simple \
--out "$RESULT_DIR/$BASENAME.tsv" \
--outfmt 6 qseqid sseqid pident length qlen slen evalue qstart qend sstart send staxids sphylums sgenus sspecies
