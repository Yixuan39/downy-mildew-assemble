#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 32
#SBATCH --mem=0

THREADS=32
INPUT_DIR=$HOME/project_data/downy/contigs-renamed/cleaned
RESULT_DIR=$HOME/project_data/downy/contigs-renamed/hardmasked
FILES=($(find "$INPUT_DIR" -type f -name "*.fasta.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fasta.gz}
# # decompress the original file to result directory
mkdir -p ${RESULT_DIR}/${BASENAME}_tmp
gzip -dc "$FILE" > "${RESULT_DIR}/${BASENAME}_tmp/${BASENAME}.fasta"


earlGrey \
  -g "${RESULT_DIR}/${BASENAME}_tmp/${BASENAME}.fasta" \
  -s $BASENAME \
  -o $RESULT_DIR \
  -t $THREADS \
  -r eukaryota \
  -d yes

bedtools maskfasta \
  -fi "${RESULT_DIR}/${BASENAME}_tmp/${BASENAME}.fasta" \
  -bed $RESULT_DIR/${BASENAME}_EarlGrey/${BASENAME}_summaryFiles/${BASENAME}.filteredRepeats.bed \
  -fo $RESULT_DIR/${BASENAME}.fasta

gzip $RESULT_DIR/${BASENAME}.fasta
