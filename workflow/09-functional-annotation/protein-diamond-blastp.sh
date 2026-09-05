#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 32
#SBATCH --mem=0

# ----------------------------------------------------------------------------------------
# Purpose : DIAMOND blastp of the Helixer proteins against NCBI nr, for the homology-based half of the
#           annotation support table.
# Inputs  : $HOME/project_data/downy/contigs-renamed/helixer/*.faa; nr.dmnd at $HOME/db/nr.dmnd
# Outputs : $HOME/project_data/downy/contigs-renamed/blastp/<genome>.tsv
# Runs on : NCSU BRC, SLURM array 0-3, 32 cores
# Usage   : sbatch workflow/09-functional-annotation/protein-diamond-blastp.sh
# ----------------------------------------------------------------------------------------

INPUT_DIR=$HOME/project_data/downy/contigs-renamed/helixer
RESULT_DIR=$HOME/project_data/downy/contigs-renamed/blastp
FILES=($(find "$INPUT_DIR" -type f -name "*.faa"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.faa}

start=$EPOCHREALTIME

mamba run -n diamond diamond blastp \
--threads $THREADS \
--evalue 1e-3 \
--max-target-seqs 1 \
--db $HOME/db/diamond/nr.dmnd \
--sensitive \
--index-chunks 1 \
--query $FILE \
--header simple \
--out $RESULT_DIR/$BASENAME.tsv \
--outfmt 6 qseqid sseqid pident length qlen slen evalue qstart qend sstart send staxids sphylums sgenus sspecies

end=$EPOCHREALTIME
runtime=$(echo "$end - $start" | bc)

