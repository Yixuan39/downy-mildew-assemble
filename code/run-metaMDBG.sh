#!/bin/bash
#SBATCH --job-name=run
#SBATCH --array=0-3
#SBATCH --cpus-per-task=24


INPUT_DIR=$HOME/project_data/downy/GSL_Data/fastq
RESULT_DIR=$HOME/project_data/downy/GSL_Data/metaMDBG
FILES=($(find "$INPUT_DIR" -type f -name "*.fastq.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=24

BASENAME=$(basename $FILE)  
BASENAME=${BASENAME%.fastq.gz}  


echo "Processing file: $FILE"
metaMDBG asm \
  --out-dir ${RESULT_DIR}/${BASENAME}.asm \
  --in-hifi ${FILE} \
  --threads ${THREADS}
mv ${RESULT_DIR}/${BASENAME}.asm/contigs.fasta.gz ${RESULT_DIR}/${BASENAME}.fasta.gz
rm -r ${RESULT_DIR}/${BASENAME}.asm

