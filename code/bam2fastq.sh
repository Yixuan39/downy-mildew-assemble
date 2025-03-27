#!/bin/bash
#SBATCH --job-name=bam2fq
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24


FILES=$(ls -R $HOME/project_data/downy/GSL_Data/5Feb24/**/*bam)
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
OUTPUT_DIR=$HOME/project_data/downy/GSL_Data/fastq
mkdir -p $OUTPUT_DIR

bam2fastq --output $OUTPUT_DIR/$(basename $(dirname $FILE)) $FILE

