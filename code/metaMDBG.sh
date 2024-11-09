#!/bin/bash
#SBATCH --array=0-2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24

# This script will run MetaMDBG on the downy mildew data
# List of files to process (without the `.fastq.gz` extension)
FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here

# Get the file name based on the task ID
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

metaMDBG asm \
--out-dir ~/project_data/downy/meta-asm/${FILE} \
--in-hifi ~/project_data/downy/data/${FILE}.fastq.gz \
--threads 24