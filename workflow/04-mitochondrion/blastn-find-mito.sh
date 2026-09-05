#!/bin/bash
#SBATCH --array=0-10

# ----------------------------------------------------------------------------------------
# Purpose : Locate mitochondrial contigs in each published downy mildew genome by BLASTN against a reference
#           mitochondrial genome.
# Inputs  : $HOME/project_data/downy/downy-mildew-genomes/*.fna.gz
#           $HOME/project_data/downy/mitochondrial-genome/KT072718.1.fna (NCBI KT072718.1, P. cubensis mt genome)
# Outputs : $HOME/project_data/downy/downy-mildew-genomes/blast-mito/<genome>.tsv
# Runs on : SLURM array 0-10 (one task per published genome)
# Usage   : sbatch workflow/04-mitochondrion/blastn-find-mito.sh
# ----------------------------------------------------------------------------------------

INPUT_DIR=$HOME/project_data/downy/downy-mildew-genomes
RESULT_DIR=$HOME/project_data/downy/downy-mildew-genomes/blast-mito
FILES=($(find "$INPUT_DIR" -maxdepth 1 -type f -name "*.fna.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fna.gz}
gzip -d -k ${FILE} 

blastn -query ${FILE%.gz} \
  -subject "$HOME/project_data/downy/mitochondrial-genome/KT072718.1.fna" \
  -outfmt "6 qseqid sseqid pident length qlen qstart qend slen sstart send evalue" \
  -max_target_seqs 1 \
  -max_hsps 1 \
  -out "$RESULT_DIR/$BASENAME.mito.tsv"
  
[ -f "${FILE%.gz}" ] && rm "${FILE%.gz}"
