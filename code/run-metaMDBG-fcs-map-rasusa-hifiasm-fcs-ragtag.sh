#!/bin/bash
#SBATCH --job-name=rag_tag
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24

set -euo pipefail

# with hifiasm results, run purge_dups on the primary assembly.
INPUT_DIR="$HOME/project_data/downy/metaMDBG/fcs-gx/minimap2/rasusa/hifiasm/fcs-gx"
REF="$HOME/project_data/downy/oomycota-genome/Peronospora-effusa.fna"
RESULT_DIR="$INPUT_DIR/rag_tag"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
THREADS=24

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
  
  
  
