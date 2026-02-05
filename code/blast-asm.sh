#!/bin/bash
#SBATCH --array=0-3

INPUT_DIR=$HOME/project_data/downy/Assembly
RESULT_DIR=$HOME/project_data/downy/BLAST-asm
FILES=($(find "$INPUT_DIR" -maxdepth 2 -type f -name "*.fasta.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fasta.gz}
gzip -d -k ${FILE} 

blastn -query ${FILE%.gz} \
  -subject "../data/KT072718.1.fna" \
  -outfmt "6 qseqid sseqid pident length qlen slen evalue staxids" \
  -max_target_seqs 1 \
  -max_hsps 1 \
  -out "$RESULT_DIR/$BASENAME.mito.tsv"
  
[ -f "${FILE%.gz}" ] && rm "${FILE%.gz}"
