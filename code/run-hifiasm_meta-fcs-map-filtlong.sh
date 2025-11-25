#!/bin/bash
#SBATCH --job-name=filtlong
#SBATCH --array=0-2
#SBATCH -c 24

# read depth in our samples are too high, which does not help for assembly.
INPUT_DIR="$HOME/project_data/downy/hifiasm-meta/fcs-gx/minimap2"
RESULT_DIR="$INPUT_DIR/filtlong"
mkdir -p $RESULT_DIR
mapfile -t FILES < <(find "$INPUT_DIR" -type f -maxdepth 1 -name "*.fastq.gz" | sort)
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
# get base name
BASENAME=$(basename "$FILE")  

echo $BASENAME
bases=(5400000000 4800000000 5400000000)

filtlong \
--target_bases ${bases[$SLURM_ARRAY_TASK_ID]} \
--min_length 1000 \
--mean_q_weight 1.5 \
$FILE | pigz -p 24 > $RESULT_DIR/$BASENAME
