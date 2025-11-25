#!/bin/bash
#SBATCH --job-name=filtlong
#SBATCH --array=0-2
#SBATCH -c 24

# read depth in our samples are too high, which does not help for assembly.
INPUT_DIR="$HOME/project_data/downy/metaMDBG/fcs-gx/minimap2"
RESULT_DIR="$INPUT_DIR/filtlong"
mkdir -p $RESULT_DIR
mapfile -t FILES < <(find "$INPUT_DIR" -type f -maxdepth 1 -name "*.fastq.gz" | sort)
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
# get base name
BASENAME=$(basename "$FILE")  

echo $BASENAME
bases=(5400000000 4800000000 5400000000)
min_l=(5417 6500 3562)

filtlong \
--target_bases ${bases[$SLURM_ARRAY_TASK_ID]} \
--min_length ${min_l[$SLURM_ARRAY_TASK_ID]} \
$FILE | pigz -p 24 > $RESULT_DIR/$BASENAME
