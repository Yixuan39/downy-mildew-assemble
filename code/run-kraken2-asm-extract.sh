#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

# set -euo pipefail

# after cleaning with fcs, verify and clean with Kraken2
INPUT_DIR="$HOME/project_data/downy/hifiasm"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
TAXID=4762
CONF=(0 0.25 0.5 0.75)
THREADS=32

FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"

echo "Processing: $FILE"

# test for genomic database
Kraken_DB="$HOME/project_data/downy/KrakenDB/oomycota-genome"
for C in "${CONF[@]}"; do
  RESULT_DIR="$HOME/project_data/downy/Kraken2/asm/genomic-extract-$C"
  mkdir -p "$RESULT_DIR"
  bash kraken2.sh \
    -i "$FILE" \
    -o "$RESULT_DIR" \
    -b "$BUSCO_DB" \
    -k "$Kraken_DB" \
    -m extract \
    -t "$TAXID" \
    -c "$C" \
    -p "$THREADS"
done

# test for protein database
Kraken_DB="$HOME/project_data/downy/KrakenDB/oomycota-protein"
for C in "${CONF[@]}"; do
  RESULT_DIR="$HOME/project_data/downy/Kraken2/asm/protein-extract-$C"
  mkdir -p "$RESULT_DIR"
  bash kraken2.sh \
    -i "$FILE" \
    -o "$RESULT_DIR" \
    -b "$BUSCO_DB" \
    -k "$Kraken_DB" \
    -m extract \
    -t "$TAXID" \
    -c "$C" \
    -p "$THREADS"
done
