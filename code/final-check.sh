#!/bin/bash
#SBATCH --job-name=QC
#SBATCH --array=0-3
#SBATCH --cpus-per-task=24

set -euo pipefail

# with hifiasm results, run purge_dups on the primary assembly.
INPUT_DIR='../data/cleaned_contigs'
RESULT_DIR='../data/cleaned_contigs'
FILES=($(find "$INPUT_DIR" -type f -name "*.fasta.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
THREADS=24
mkdir -p $RESULT_DIR

python quality-check.py \
  --input_file $RESULT_DIR/$FILE \
  --output_dir $RESULT_DIR \
  --library_path $BUSCO_DB \
  --threads $THREADS