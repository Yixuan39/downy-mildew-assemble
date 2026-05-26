#!/bin/bash
#SBATCH --array=0-10
#SBATCH -c 32
#SBATCH --mem=0

THREADS=32
INPUT_DIR=$HOME/project_data/downy/downy-mildew-genomes
RESULT_DIR=$HOME/project_data/downy/downy-mildew-genomes/hardmasked
FILES=($(find "$INPUT_DIR" -type f -name "*.fna.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fna.gz}
EG_NAME=${BASENAME##*_}
TMP_DIR=${RESULT_DIR}/${EG_NAME}_tmp
# decompress the original file to result directory
mkdir -p ${TMP_DIR}
gzip -dc "$FILE" > "${TMP_DIR}/${EG_NAME}.fna"


mamba run -n earlGrey earlGrey \
  -g "${TMP_DIR}/${EG_NAME}.fna" \
  -s $EG_NAME \
  -o $RESULT_DIR \
  -t $THREADS \
  -r eukaryota \
  -d yes \
  -q yes

mamba run -n earlGrey bedtools maskfasta \
  -fi "${TMP_DIR}/${EG_NAME}.fna" \
  -bed $RESULT_DIR/${EG_NAME}_EarlGrey/${EG_NAME}_summaryFiles/${EG_NAME}.filteredRepeats.bed \
  -fo $RESULT_DIR/${BASENAME}.fna

mamba run -n earlGrey gzip $RESULT_DIR/${BASENAME}.fna