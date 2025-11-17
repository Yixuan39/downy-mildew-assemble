#!/bin/bash
#SBATCH --job-name=filtlong
#SBATCH --array=0-2

# subset data to 15% with filtlong (keep longest 15% reads)
# read depth in our samples are too high, which does not help for assembly.
INPUT_DIR=$HOME/project_data/downy/GSL_Data/fastq/filtered
RESULT_DIR=$HOME/project_data/downy/filtlong
mkdir -p $RESULT_DIR
mapfile -t FILES < <(find "$INPUT_DIR" -type f -name "*.fastq.gz" | sort)
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
# get base name
BASENAME=$(basename "$FILE")  

echo $BASENAME
# here we used Q1 read length
min_l=(5567 6085 3942)
bases=(7277452891 4430169454 10526315789)

filtlong \
--target_bases ${bases[$SLURM_ARRAY_TASK_ID]} \
--min_length ${min_l[$SLURM_ARRAY_TASK_ID]} \
--mean_q_weight 1.5 \
$FILE | gzip > $RESULT_DIR/$BASENAME
