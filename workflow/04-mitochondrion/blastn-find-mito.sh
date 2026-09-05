#!/bin/bash
#SBATCH --array=0-10

# Purpose : Locate mitochondrial contigs in each published downy mildew genome by BLASTN against a reference
#           mitochondrial genome.
# Inputs  : ${PROJECT_DATA}/inputs/reference-genomes/*.fna.gz
#           ${PROJECT_DATA}/inputs/reference-mitochondria/KT072718.1.fna (NCBI KT072718.1, P. cubensis mt genome)
# Outputs : ${PROJECT_DATA}/results/assembly-preparation/reference-mito-hits/<genome>.tsv
# Runs on : SLURM array 0-10 (one task per published genome)
# Usage   : sbatch workflow/04-mitochondrion/blastn-find-mito.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

INPUT_DIR=${PROJECT_DATA}/inputs/reference-genomes
RESULT_DIR=${PROJECT_DATA}/results/assembly-preparation/reference-mito-hits
FILES=($(find "$INPUT_DIR" -maxdepth 1 -type f -name "*.fna.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fna.gz}
gzip -d -k ${FILE} 

blastn -query ${FILE%.gz} \
  -subject "${PROJECT_DATA}/inputs/reference-mitochondria/KT072718.1.fna" \
  -outfmt "6 qseqid sseqid pident length qlen qstart qend slen sstart send evalue" \
  -max_target_seqs 1 \
  -max_hsps 1 \
  -out "$RESULT_DIR/$BASENAME.mito.tsv"
  
[ -f "${FILE%.gz}" ] && rm "${FILE%.gz}"
