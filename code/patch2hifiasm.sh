#!/bin/bash
#SBATCH --job-name=patch
#SBATCH --array=0-2

set -euo pipefail

# reference genome for patching
INPUT_DIR="$HOME/project_data/downy/hifiasm/fcs-gx/kraken2/purge_dups/rag_tag"
# support genome for patching
INPUT_DIR2="$HOME/project_data/downy/flye/fcs-gx/kraken2/rag_tag/gapless-raw"
RESULT_DIR="$HOME/project_data/downy/patch2hifiasm2"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"

mkdir -p "$RESULT_DIR"

FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"
BASENAME=$(basename "$FILE")
BASENAME=${BASENAME%.fasta.gz}
mkdir -p "${RESULT_DIR}/${BASENAME}"
echo "Base name: $BASENAME"

gzip -dkc ${INPUT_DIR}/${BASENAME}.fasta.gz > ${RESULT_DIR}/${BASENAME}/${BASENAME}.1.fasta
gzip -dkc ${INPUT_DIR2}/${BASENAME}.fasta.gz > ${RESULT_DIR}/${BASENAME}/${BASENAME}.2.fasta

ragtag.py patch \
  -o ${RESULT_DIR}/${BASENAME} \
  -w \
  -f 1500 --remove-small \
  ${RESULT_DIR}/${BASENAME}/${BASENAME}.1.fasta \
  ${RESULT_DIR}/${BASENAME}/${BASENAME}.2.fasta

gzip -c "${RESULT_DIR}/${BASENAME}/ragtag.patch.fasta" > "${RESULT_DIR}/${BASENAME}.fasta.gz"
rm -rf "${RESULT_DIR}/${BASENAME}"

python quality-check.py \
  --input_file "${RESULT_DIR}/${BASENAME}.fasta.gz" \
  --output_dir "${RESULT_DIR}/compleasm" \
  --suffix ${BASENAME} \
  --library_path ${BUSCO_DB} \
  --threads 1