#!/bin/bash
#SBATCH --job-name=hifiasm
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

# run hifiasm on raw pacbio hifi reads
INPUT_DIR="$HOME/project_data/downy/metaMDBG/fcs-gx/minimap2"
RESULT_DIR="$INPUT_DIR/hifiasm"
FILES=($(find "$INPUT_DIR" -type f -maxdepth 1 -name "*.fastq.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB

echo "Processing: $FILE"
bash hifiasm.sh \
  -i ${FILE} \
  -o ${RESULT_DIR} \
  -b ${BUSCO_DB} \
  -p ${THREADS}
