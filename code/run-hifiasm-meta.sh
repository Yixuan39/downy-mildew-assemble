#!/bin/bash
#SBATCH --job-name=hifiasm-meta
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32
#SBATCH --mem=0

# run hifiasm on raw pacbio hifi reads
INPUT_DIR=$HOME/project_data/downy/GSL_Data/filtered_fastq
RESULT_DIR=$HOME/project_data/downy/hifiasm-meta
FILES=($(find "$INPUT_DIR" -type f -name "*.fastq.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB

echo "Processing: $FILE"
bash hifiasm-meta.sh \
  -i ${FILE} \
  -o ${RESULT_DIR} \
  -b ${BUSCO_DB} \
  -p ${THREADS}