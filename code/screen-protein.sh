#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 32

INPUT_DIR=$HOME/project_data/downy/Helixer
RESULT_DIR=$HOME/project_data/downy/Helixer
FILES=($(find "$INPUT_DIR" -type f -name "*.faa"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.faa}

start=$EPOCHREALTIME

diamond blastp \
--threads $THREADS \
--db $HOME/diamond_db/nr \
--out $RESULT_DIR/$BASENAME.tsv \
--header simple \
--evalue 0.00001 \
--max-target-seqs 10 \
--ultra-sensitive \
--query $FILE \
--outfmt "6 qseqid sseqid pident length qlen slen evalue staxids qstart qend sstart send"

end=$EPOCHREALTIME
runtime=$(echo "$end - $start" | bc)
echo "Runtime: $runtime seconds"

diamond blastp \
--threads $THREADS \
--db $HOME/diamond_db/nr \
--out $RESULT_DIR/$BASENAME.tsv \
--header simple \
--evalue 0.00001 \
--max-target-seqs 10 \
--ultra-sensitive \
--query $FILE \
--outfmt 0

runtime=$(echo "$end - $start" | bc)
echo "Runtime: $runtime seconds"