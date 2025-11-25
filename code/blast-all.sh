#!/bin/bash
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24

INPUT_DIR=$HOME/project_data/downy/metaMDBG/fcs-gx/minimap2/rasusa/hifiasm/fcs-gx/rag_tag
RESULT_DIR=$INPUT_DIR/blast
FILES=($(find "$INPUT_DIR" -type f -name "*.fasta.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=24
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fasta.gz}
gzip -d -k ${FILE} 

blastn -query ${INPUT_DIR}/${BASENAME}.fasta \
  -db nt \
  -outfmt "6 qseqid sseqid pident length qlen slen evalue staxids" \
  -max_target_seqs 5 \
  -max_hsps 1 \
  -num_threads "$THREADS" \
  -out "$RESULT_DIR/$BASENAME.nt.tsv"
  
blastn -query ${INPUT_DIR}/${BASENAME}.fasta \
  -subject "../data/KT072718.1.fna" \
  -outfmt "6 qseqid sseqid pident length qlen slen evalue staxids" \
  -max_target_seqs 1 \
  -max_hsps 1 \
  -num_threads "$THREADS" \
  -out "$RESULT_DIR/$BASENAME.mito.tsv"
  
rm ${INPUT_DIR}/${BASENAME}.fasta
