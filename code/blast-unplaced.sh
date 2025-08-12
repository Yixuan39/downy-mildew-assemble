#!/bin/bash
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

INPUT_DIR=$HOME/Projects/downy-mildew-assemble/data/unplaced-contigs
RESULT_DIR=$HOME/Projects/downy-mildew-assemble/data/unplaced-contigs
FILES=($(find "$INPUT_DIR" -type f -name "*.fasta"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fasta}

blastn -query "$FILE" \
  -db /home1/ncbi/July2023/nt \
  -outfmt 6 \
  -max_target_seqs 1 \
  -max_hsps 1 \
  -num_threads "$THREADS" \
  -out "$RESULT_DIR/$BASENAME.tsv"
  
# Compress the output file
gzip "$RESULT_DIR/$BASENAME.tsv"