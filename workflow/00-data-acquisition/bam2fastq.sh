#!/bin/bash
#SBATCH --job-name=bam2fq
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24

# ----------------------------------------------------------------------------------------
# Purpose : Convert the PacBio HiFi BAMs delivered by the sequencing core into gzipped FASTQ, one array task
#           per BAM.
# Inputs  : $HOME/project_data/downy/GSL_Data/5Feb24/*/*.bam
# Outputs : $HOME/project_data/downy/GSL_Data/fastq/<run>.fastq.gz
# Runs on : SLURM array 0-2 (one task per isolate BAM)
# Usage   : sbatch workflow/00-data-acquisition/bam2fastq.sh
# ----------------------------------------------------------------------------------------


INPUT_DIR=$HOME/project_data/downy/GSL_Data/5Feb24
OUTPUT_DIR=$HOME/project_data/downy/GSL_Data/fastq
mkdir -p $OUTPUT_DIR

FILES=($(find "$INPUT_DIR" -type f -name "*.bam"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

bam2fastq --output $OUTPUT_DIR/$(basename $(dirname $FILE)) $FILE

