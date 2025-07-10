#!/bin/bash
#SBATCH --job-name=purge_dups
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24

set -euo pipefail

ASM_DIR="$HOME/project_data/downy/hifiasm/fcs-gx"
HIFI_DIR="$HOME/project_data/downy/GSL_Data/fastq"
RESULT_DIR="$ASM_DIR/purge_dups"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
THREADS=24

mkdir -p "$RESULT_DIR"

# Use glob + sort for simplicity and robustness
mapfile -t ASM_FILES < <(printf '%s\n' "$ASM_DIR"/*.fasta.gz | sort)
mapfile -t HIFI_FILES < <(printf '%s\n' "$HIFI_DIR"/*.fastq.gz | sort)

ASM_FILE="${ASM_FILES[$SLURM_ARRAY_TASK_ID]}"
HIFI_FILE="${HIFI_FILES[$SLURM_ARRAY_TASK_ID]}"

echo "Processing:"
echo "  ASM_FILE:  $ASM_FILE"
echo "  HIFI_FILE: $HIFI_FILE"

bash purge_dups.sh \
  -a "$ASM_FILE" \
  -r "$HIFI_FILE" \
  -o "$RESULT_DIR" \
  -b "$BUSCO_DB" \
  -p "$THREADS"