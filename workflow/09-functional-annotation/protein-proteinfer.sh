#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 24
#SBATCH --mem=0

# ----------------------------------------------------------------------------------------
# Purpose : Predict protein function with ProteInfer, the fourth independent annotation source in the gene-
#           support comparison.
# Inputs  : $HOME/project_data/downy/contigs-renamed/helixer/*.faa
# Outputs : $HOME/project_data/downy/contigs-renamed/proteinfer/
# Runs on : SLURM array 0-3, 24 cores
# Usage   : sbatch workflow/09-functional-annotation/protein-proteinfer.sh
# ----------------------------------------------------------------------------------------

INPUT_DIR=$HOME/project_data/downy/contigs-renamed/helixer
RESULT_DIR=$HOME/project_data/downy/contigs-renamed/proteinfer
FILES=($(find "$INPUT_DIR" -type f -name "*.faa"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=24

echo "Processing: $FILE"
BASENAME=$(basename ${FILE})
BASENAME=${BASENAME%.faa}
mkdir -p ${RESULT_DIR}

start=$EPOCHREALTIME

mamba run -n proteinfer python3 ${HOME}/software/proteinfer/proteinfer.py \
--i ${FILE} \
--o ${RESULT_DIR}/${BASENAME}.proteinfer_thr09.tsv \
--model_cache_path ${HOME}/software/proteinfer/cached_models \
--num_ensemble_elements 5 \
--reporting_threshold 0.9

end=$EPOCHREALTIME
runtime=$(echo "$end - $start" | bc)
