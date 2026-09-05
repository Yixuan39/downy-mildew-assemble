#!/bin/bash
#SBATCH --job-name=adapterfilt
#SBATCH --cpus-per-task=32

# ----------------------------------------------------------------------------------------
# Purpose : Same HiFiAdapterFilt step for the public P. effusa UA202013 reads. Single library, so it runs as
#           one job; $SLURM_ARRAY_TASK_ID is left unset and resolves to index 0.
# Inputs  : $HOME/project_data/downy/UA202013/*.fastq.gz
# Outputs : $HOME/project_data/downy/UA202013/filtered/*.filt.fastq.gz
# Runs on : SLURM, single job, 32 cores
# Usage   : sbatch workflow/01-read-filtering/UA202013/run-hifiadapterfilt.sh
# ----------------------------------------------------------------------------------------

# After subsetting data with filtlong, we remove adapter sequences using hifiadapterfilt.sh
cd $INPUT_DIR
RESULT_DIR=./filtered
mkdir -p $RESULT_DIR
FILES=($(find "." -type f -name "*.fastq.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32

hifiadapterfilt.sh -p ${FILE%.fastq.gz} -o $RESULT_DIR -t $THREADS
