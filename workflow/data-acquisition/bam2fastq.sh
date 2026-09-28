#!/bin/bash
#SBATCH --job-name=bam2fq
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"

INPUT_DIR="$PROJECT_DATA/inputs/hifi/focal/bam"
OUTPUT_DIR="$PROJECT_DATA/inputs/hifi/focal/fastq"
FILES=("$INPUT_DIR"/*/*.bam)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
mkdir -p "$OUTPUT_DIR"
bam2fastq --output "$OUTPUT_DIR/$(basename "$(dirname "$FILE")")" "$FILE"
