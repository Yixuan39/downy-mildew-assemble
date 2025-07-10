#!/bin/bash
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

INPUT_DIR=$HOME/project_data/downy/GSL_Data/hifiasm-fcs-dedup
RESULT_DIR=$HOME/project_data/downy/helixer-fcs-dedup
FILES=($(find "$INPUT_DIR" -type f -name "*.fasta.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32

echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fasta.gz}
mkdir -p ${RESULT_DIR}/${BASENAME}
cp ${FILE} ${RESULT_DIR}/${BASENAME}/${BASENAME}.fasta.gz
gzip -d ${RESULT_DIR}/${BASENAME}/${BASENAME}.fasta.gz

helixerlite \
  --cpus ${THREADS} \
  --lineage fungi \
  --fasta ${RESULT_DIR}/${BASENAME}/${BASENAME}.fasta \
  --out ${RESULT_DIR}/${BASENAME}/${BASENAME}.gff

gffread \
  ${RESULT_DIR}/${BASENAME}/${BASENAME}.gff \
  -g ${RESULT_DIR}/${BASENAME}/${BASENAME}.fasta \
  -y ${RESULT_DIR}/${BASENAME}/${BASENAME}.faa
