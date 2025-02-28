#!/bin/bash
#SBATCH --array=1-3
#SBATCH --cpus-per-task=24
#SBATCH --mem=0

EV=1e-10
threads=24

###########################################################################
# classify sequence first, then assemble with metaMDBG                    #
###########################################################################

INPUT_FOLDER=$HOME/project_data/downy/data
FILES=$(ls ${INPUT_FOLDER}/*.fastq.gz 2>/dev/null | xargs -n 1 basename)
FILE=${FILES[$SLURM_ARRAY_TASK_ID - 1]}
echo $FILES
echo $FILE