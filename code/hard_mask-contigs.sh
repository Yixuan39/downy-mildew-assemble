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
TMP_DIR=${RESULT_DIR}/${BASENAME}_tmp
# decompress the original file to result directory
mkdir -p ${TMP_DIR}
gzip -dc "$FILE" > "${TMP_DIR}/${BASENAME}.fasta"


BuildDatabase \
  -name ${TMP_DIR}/db \
  ${TMP_DIR}/${BASENAME}.fasta

RepeatModeler \
  -threads 32 \
  -database ${TMP_DIR}/db > ${TMP_DIR}/${BASENAME}.out

RepeatMasker \
  -engine ncbi \
  -parallel 8 \
  -gff \
  -lib ${TMP_DIR}/db-families.fa \
  -dir ${RESULT_DIR}/${BASENAME}_masked \
  ${TMP_DIR}/${BASENAME}.fasta

cp ${RESULT_DIR}/${BASENAME}_masked/${BASENAME}.fasta.masked ${RESULT_DIR}/${BASENAME}.fasta
gzip ${RESULT_DIR}/${BASENAME}.fasta

