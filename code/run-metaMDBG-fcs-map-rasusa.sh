#!/bin/bash
#SBATCH --job-name=filtlong
#SBATCH --array=0-2

# read depth in our samples are too high, which does not help for assembly.
INPUT_DIR="$HOME/project_data/downy/metaMDBG/fcs-gx/minimap2"
RESULT_DIR="$INPUT_DIR/rasusa"
mkdir -p $RESULT_DIR
mapfile -t FILES < <(find "$INPUT_DIR" -type f -maxdepth 1 -name "*.fastq.gz" | sort)
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
# get base name
BASENAME=$(basename "$FILE")  

echo $BASENAME
bases=(5400000000 4800000000 5400000000)

rasusa reads \
--bases ${bases[$SLURM_ARRAY_TASK_ID]} \
--output-type g \
--output $RESULT_DIR/$BASENAME \
$FILE
