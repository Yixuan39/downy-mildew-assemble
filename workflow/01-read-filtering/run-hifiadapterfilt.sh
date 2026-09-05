#!/bin/bash
#SBATCH --job-name=adapterfilt
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

# ----------------------------------------------------------------------------------------
# Purpose : Remove PacBio adapter sequence from the filtlong-subset HiFi reads with HiFiAdapterFilt, one
#           array task per library.
# Inputs  : $HOME/project_data/downy/GSL_Data/fastq/*.fastq.gz
# Outputs : $HOME/project_data/downy/GSL_Data/fastq/filtered/*.filt.fastq.gz
# Runs on : NCSU BRC (SLURM), array 0-2, 32 cores per task
# Usage   : sbatch workflow/01-read-filtering/run-hifiadapterfilt.sh
# ----------------------------------------------------------------------------------------

INPUT_DIR=$HOME/project_data/downy/GSL_Data/fastq
cd $INPUT_DIR
RESULT_DIR=./filtered
mkdir -p $RESULT_DIR
FILES=($(find "." -type f -name "*.fastq.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32

hifiadapterfilt.sh -p ${FILE%.fastq.gz} -o $RESULT_DIR -t $THREADS
