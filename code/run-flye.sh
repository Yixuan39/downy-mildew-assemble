#!/bin/bash
#SBATCH --job-name=flye
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

# run flye on raw pacbio hifi reads
INPUT_DIR=$HOME/project_data/downy/filtlong/filtadapt
RESULT_DIR=$HOME/project_data/downy/flye_test
FILES=($(find "$INPUT_DIR" -type f -name "*.fastq.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB

echo "Processing: $FILE"
bash flye.sh \
  -i ${FILE} \
  -o ${RESULT_DIR} \
  -b ${BUSCO_DB} \
  -p ${THREADS}