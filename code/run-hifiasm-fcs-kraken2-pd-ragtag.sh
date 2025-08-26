#!/bin/bash
#SBATCH --job-name=rag_tag
#SBATCH --array=0-2

set -euo pipefail

# with hifiasm results, run purge_dups on the primary assembly.
INPUT_DIR="$HOME/project_data/downy/hifiasm/fcs-gx/kraken2/purge_dups"
REF="$HOME/project_data/downy/oomycota-genome/Peronospora-effusa.fna"
RESULT_DIR="$INPUT_DIR/rag_tag"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
THREADS=1

mkdir -p "$RESULT_DIR"

FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"
BASENAME=$(basename "$FILE")  

QUERRY="$HOME/project_data/downy/hifiasm/$BASENAME"

bash ragtag.sh \
  -i "$FILE" \
  -o "$RESULT_DIR" \
  -b "$BUSCO_DB" \
  -r "$REF" \
  -q "$QUERRY" \
  -p "$THREADS"
  
  
  
