#!/bin/bash
#SBATCH --job-name=gapless
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32
#SBATCH --mem=350G

set -euo pipefail

INPUT_DIR="$HOME/project_data/downy/hifiasm/fcs-gx/kraken2/rag_tag"
RESULT_DIR="$INPUT_DIR/gapless-raw"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
THREADS=32

mkdir -p "$RESULT_DIR"

FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"

# get base name
BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.fasta.gz}  
QUERY="$HOME/project_data/downy/GSL_Data/filtered_fastq/$BASENAME.fastq.gz"
mkdir -p "${RESULT_DIR}/${BASENAME}"
echo "Base name: $BASENAME"
echo "input: $FILE"
echo "query: $QUERY"

bash gap-close.sh \
  -i "$FILE" \
  -q "$QUERY" \
  -o "$RESULT_DIR" \
  -b "$BUSCO_DB" \
  -p "$THREADS"
  
  
  
