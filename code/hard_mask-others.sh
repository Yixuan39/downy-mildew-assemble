#!/bin/bash
#SBATCH --array=0-10
#SBATCH -c 32
#SBATCH --mem=0

THREADS=$SLURM_CPUS_PER_TASK
INPUT_DIR=$HOME/project_data/downy/downy-mildew-genomes
RESULT_DIR=$HOME/project_data/downy/downy-mildew-genomes/hardmasked
FILES=($(find "$INPUT_DIR" -path "$RESULT_DIR" -prune -o -type f -name "*.fna.gz" -print | sort))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fna.gz}
TMP_DIR=${RESULT_DIR}/${BASENAME}_tmp
# decompress the original file to result directory
mkdir -p ${TMP_DIR}
gzip -dc "$FILE" > "${TMP_DIR}/${BASENAME}.fna"


BuildDatabase \
  -name ${TMP_DIR}/db \
  ${TMP_DIR}/${BASENAME}.fna

RepeatModeler \
  -threads $THREADS \
  -database ${TMP_DIR}/db > ${TMP_DIR}/${BASENAME}.out

RepeatMasker \
  -engine ncbi \
  -parallel $((THREADS / 4)) \
  -gff \
  -lib ${TMP_DIR}/db-families.fa \
  -dir ${RESULT_DIR}/${BASENAME}_masked \
  ${TMP_DIR}/${BASENAME}.fna

cp ${RESULT_DIR}/${BASENAME}_masked/${BASENAME}.fna.masked ${RESULT_DIR}/${BASENAME}.fna
gzip -f ${RESULT_DIR}/${BASENAME}.fna

