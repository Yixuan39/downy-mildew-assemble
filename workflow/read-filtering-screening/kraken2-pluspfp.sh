#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24
#SBATCH --mem=220G

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export DB_ROOT="${DB_ROOT:-$HOME/db}"

INPUT_DIR="$PROJECT_DATA/results/read-filtering-screening/reads/focal"
FILES=("$INPUT_DIR"/*.fastq.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
sample="$(basename "$FILE" .fastq.gz)"
RESULT_DIR="$PROJECT_DATA/results/read-filtering-screening/taxonomy"
mkdir -p "$RESULT_DIR"
kraken2 --db "$DB_ROOT/kraken2/PlusPFP" \
    --threads "$SLURM_CPUS_PER_TASK" --confidence 0 \
    --report "$RESULT_DIR/$sample.kreport" \
    --output "$RESULT_DIR/$sample.kraken" "$FILE"
