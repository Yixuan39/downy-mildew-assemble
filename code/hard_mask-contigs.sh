#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 24
#SBATCH --mem=0

THREADS=24
INPUT_DIR=$HOME/project_data/downy/cleaned_contigs
RESULT_DIR=$HOME/project_data/downy/HardMask-contigs
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



# BuildDatabase \
#   -name ${RESULT_DIR}/${BASENAME}_tmp/db \
#   ${RESULT_DIR}/${BASENAME}_tmp/${BASENAME}.fasta
#   
# RepeatModeler \
#   -threads 32 \
#   -database ${RESULT_DIR}/${BASENAME}_tmp/db > ${RESULT_DIR}/${BASENAME}_tmp/${BASENAME}.out
#   
# RepeatMasker \
#   -engine ncbi \
#   -parallel 8 \
#   -gff \
#   -lib ${RESULT_DIR}/${BASENAME}_tmp/db-families.fa \
#   -dir ${RESULT_DIR}/${BASENAME}_masked \
#   ${RESULT_DIR}/${BASENAME}_tmp/${BASENAME}.fasta
#   
# cp ${RESULT_DIR}/${BASENAME}_masked/${BASENAME}.fasta.masked ${RESULT_DIR}/${BASENAME}.fasta
# gzip ${RESULT_DIR}/${BASENAME}.fasta

