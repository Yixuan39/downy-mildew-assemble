#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

set -euo pipefail

# run Kraken2 on raw HIFI reads
INPUT_DIR="$HOME/project_data/downy/GSL_Data/fastq/filtered"
Kraken_DB="$HOME/project_data/downy/KrakenDB"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
TAXID=4762 # oomycete
CONF=0.1
THREADS=32

FILES=("$INPUT_DIR"/*.fastq.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"

BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.fastq.gz}
BASENAME=${BASENAME%.fasta.gz}  

echo "Processing: $FILE"

RESULT_DIR="$HOME/project_data/downy/Kraken2"
mkdir -p "$RESULT_DIR"
bash kraken2.sh \
  -i "$FILE" \
  -o "$RESULT_DIR" \
  -b "$BUSCO_DB" \
  -k "$Kraken_DB" \
  -m extract \
  -t "$TAXID" \
  -c "$CONF" \
  -p "$THREADS"
