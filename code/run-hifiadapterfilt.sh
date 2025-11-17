#!/bin/bash
#SBATCH --job-name=adapterfilt
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

# After subsetting data with filtlong, we remove adapter sequences using hifiadapterfilt.sh
INPUT_DIR=$HOME/project_data/downy/GSL_Data/fastq
cd $INPUT_DIR
RESULT_DIR=./filtered
mkdir -p $RESULT_DIR
FILES=($(find "." -type f -name "*.fastq.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32

hifiadapterfilt.sh -p ${FILE%.fastq.gz} -o $RESULT_DIR -t $THREADS