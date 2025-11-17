#!/bin/bash
#SBATCH --job-name=gapless
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

set -euo pipefail

# with hifiasm results, run purge_dups on the primary assembly.
INPUT_DIR="$HOME/project_data/downy/patch"
RESULT_DIR="$INPUT_DIR/gapless"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
THREADS=32

mkdir -p "$RESULT_DIR"

FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"

# get base name
BASENAME=$(basename "$INPUT_FILE")  
BASENAME=${BASENAME%.fasta.gz}  
QUERRY="$HOME/project_data/downy/GSL_Data/filtered_fastq/$BASENAME.fastq.gz"
mkdir -p "${RESULT_DIR}/${BASENAME}"
echo "Base name: $BASENAME"
echo "input: $INPUT_FILE"
echo "query: $QUERY"

gapless.sh \
  -r \
  -i ${INPUT_FILE} \
  -t pb_hifi \
  -j ${THREADS} \
  -o ${RESULT_DIR}/${BASENAME} \
  ${QUERY}
  
gzip -c "${RESULT_DIR}/${BASENAME}/gapless.fa" > "${RESULT_DIR}/${BASENAME}.fasta.gz"
rm -rf "${RESULT_DIR}/${BASENAME}"

python quality-check.py \
  --input_file "${RESULT_DIR}/${BASENAME}.fasta.gz" \
  --output_dir "${RESULT_DIR}/compleasm" \
  --suffix ${BASENAME} \
  --library_path ${BUSCO_DB} \
  --threads ${THREADS}
  
  
  
