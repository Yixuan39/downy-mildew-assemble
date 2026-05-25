#!/bin/bash
#SBATCH --array=0-10
#SBATCH -c 32

THREADS=32
INPUT_DIR=$HOME/project_data/downy/downy-mildew-genomes
RESULT_DIR=$HOME/project_data/downy/downy-mildew-genomes/hardmasked
FILES=($(find "$INPUT_DIR" -type f -name "*.fna.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fna.gz}
# # decompress the original file to result directory
mkdir -p ${RESULT_DIR}/${BASENAME}_tmp
gzip -dc "$FILE" > "${RESULT_DIR}/${BASENAME}_tmp/${BASENAME}.fna"


mamba run -n earlGrey earlGrey \
  -g "${RESULT_DIR}/${BASENAME}_tmp/${BASENAME}.fna" \
  -s $BASENAME \
  -o $RESULT_DIR \
  -t $THREADS \
  -r eukaryota \
  -d yes

bedtools maskfasta \
  -fi "${RESULT_DIR}/${BASENAME}_tmp/${BASENAME}.fna" \
  -bed $RESULT_DIR/${BASENAME}_EarlGrey/${BASENAME}_summaryFiles/${BASENAME}.filteredRepeats.bed \
  -fo $RESULT_DIR/${BASENAME}.fna

gzip $RESULT_DIR/${BASENAME}.fna

