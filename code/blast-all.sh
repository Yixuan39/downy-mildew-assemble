#!/bin/bash
#SBATCH --array=0-3

INPUT_DIR=$HOME/project_data/downy/Scaffold
RESULT_DIR=$HOME/project_data/downy/BLAST-long
FILES=($(find "$INPUT_DIR" -type f -name "*.fasta.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fasta.gz}
gzip -d -k ${FILE} 

blastn -query ${FILE%.gz} \
  -subject "../data/KT072718.1.fna" \
  -outfmt "6 qseqid sseqid pident length qlen qstart qend slen sstart send evalue" \
  -max_target_seqs 1 \
  -out "$RESULT_DIR/$BASENAME.mito.tsv"

# blastn -query ${FILE%.gz} \
#   -task megablast \
#   -db nt \
#   -outfmt "6 qseqid sseqid pident length qlen slen evalue staxids" \
#   -max_target_seqs 5 \
#   -max_hsps 1 \
#   -num_threads "$THREADS" \
#   -out "$RESULT_DIR/$BASENAME.nt.tsv"
  
[ -f "${FILE%.gz}" ] && rm "${FILE%.gz}"
