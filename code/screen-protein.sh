#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 32
#SBATCH --mem=0

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
--evalue 0.00001 \
--max-target-seqs 10 \
--db $HOME/diamond_db/nr.dmnd \
--out $RESULT_DIR/$BASENAME.daa \
--ultra-sensitive \
--query $FILE \
--outfmt 100

end=$EPOCHREALTIME
runtime=$(echo "$end - $start" | bc)
echo "Runtime: $runtime seconds"

# convert result to tab format
diamond view \
--threads $THREADS \
--header simple \
--out $RESULT_DIR/$BASENAME.tsv \
--outfmt 6 qseqid sseqid pident length qlen slen evalue qstart qend sstart send staxids sphylum sgenus\
--daa $RESULT_DIR/$BASENAME.daa \
--forwardonly

# convert result to pairwise alignment format
diamond view \
--threads $THREADS \
--out $RESULT_DIR/$BASENAME.txt \
--outfmt 0 \
--daa $RESULT_DIR/$BASENAME.daa \
--forwardonly
