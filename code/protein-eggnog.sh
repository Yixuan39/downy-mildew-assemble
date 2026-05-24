#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 24
#SBATCH --mem=0

INPUT_DIR=$HOME/project_data/downy/Helixer-contigs
RESULT_DIR=$HOME/project_data/downy/Helixer-contigs/eggnog-mapper
FILES=($(find "$INPUT_DIR" -type f -name "*.faa"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=24

echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.faa}
mkdir -p ${RESULT_DIR}/${BASENAME}

TMPDIR=${RESULT_DIR}/${BASENAME}_tmp
mkdir -p $TMPDIR

start=$EPOCHREALTIME

mamba run -n eggnog-mapper emapper.py \
-i ${FILE} \
--itype proteins \
-m diamond \
--cpu ${THREADS} \
--data_dir ${HOME}/db/eggnog \
--output ${BASENAME} \
--output_dir ${RESULT_DIR}/${BASENAME} \
--temp_dir ${TMPDIR} \
--override \
--sensmode sensitive \
--tax_scope eukaryota \
--go_evidence non-electronic

end=$EPOCHREALTIME
runtime=$(echo "$end - $start" | bc)
