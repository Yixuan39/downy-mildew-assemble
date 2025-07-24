#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24
#SBATCH --partition=standard,bigmem,gpu
#SBATCH --mem=300G

set -euo pipefail

INPUT_DIR="$HOME/project_data/downy/hifiasm/fcs-gx/purge_dups/glued"
RESULT_DIR="$HOME/project_data/downy/Kraken2/final"
Kraken_DB="$HOME/project_data/downy/kraken-nt"
THREADS=24

mkdir -p "$RESULT_DIR"

FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"

echo "Processing: $FILE"

bash kraken2.sh \
  -i "$FILE" \
  -o "$RESULT_DIR" \
  -d "$Kraken_DB" \
  -p "$THREADS"