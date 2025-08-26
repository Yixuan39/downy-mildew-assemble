#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24

set -euo pipefail

# after cleaning with fcs, verify and clean with Kraken2
INPUT_DIR="$HOME/project_data/downy/hifiasm"
RESULT_DIR="$INPUT_DIR/kraken2"
Kraken_DB="$HOME/project_data/downy/KrakenDB/oomycota-genome"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
TAXID=4762
THREADS=24

mkdir -p "$RESULT_DIR"

FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"

echo "Processing: $FILE"

bash kraken2.sh \
  -i "$FILE" \
  -o "$RESULT_DIR" \
  -b "$BUSCO_DB" \
  -k "$Kraken_DB" \
  -m extract \
  -t "$TAXID" \
  -p "$THREADS"

