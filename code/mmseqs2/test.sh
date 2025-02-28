#!/bin/bash
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24
#SBATCH --mem=0

EV=1e-10
threads=24

###########################################################################
# classify sequence first, then assemble with metaMDBG                    #
###########################################################################

INPUT_FOLDER=$HOME/project_data/downy/data
FILES=($(ls ${INPUT_FOLDER}/*.fastq.gz 2>/dev/null))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]} 
FILE=$(basename $FILE)
echo $FILES
echo $FILE