#!/bin/bash
#SBATCH --array=0-2

INPUT_DIR=$HOME/project_data/downy/hifiasm/fcs-gx/kraken2/purge_dups/rag_tag/unplaced-contigs
RESULT_DIR=$HOME/project_data/downy/hifiasm/fcs-gx/kraken2/purge_dups/rag_tag/unplaced-contigs
FILES=($(find "$INPUT_DIR" -type f -name "*.fasta"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fasta}

blastn -query "$FILE" \
  -subject "../data/KT072718.1.fna" \
  -outfmt "6 qseqid sseqid pident length qstart qend sstart send evalue staxids" \
  -max_target_seqs 1 \
  -max_hsps 1 \
  -out "$RESULT_DIR/$BASENAME.mito.tsv"