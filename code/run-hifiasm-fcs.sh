#!/bin/bash
#SBATCH --job-name=fcs
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24
#SBATCH --partition=standard,bigmem,gpu
#SBATCH --mem=500G

set -euo pipefail

# with hifiasm results, clean up the primary assembly with FCS-GX
INPUT_DIR="$HOME/project_data/downy/hifiasm"
RESULT_DIR="$INPUT_DIR/fcs-gx"
GX_DB="$HOME/project_data/downy/fcs-db"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
TAXID=4762
THREADS=24
export GX_NUM_CORES=$THREADS

mkdir -p "$RESULT_DIR"

FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"

echo "Processing: $FILE"

bash fcs-gx.sh \
  -i "$FILE" \
  -o "$RESULT_DIR" \
  -d "$GX_DB" \
  -b "$BUSCO_DB" \
  -t "$TAXID" \
  -p "$THREADS"