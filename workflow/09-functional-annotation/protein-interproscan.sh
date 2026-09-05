#!/bin/bash
#SBATCH --array=0-3
#SBATCH -c 24
#SBATCH --mem=0

# ----------------------------------------------------------------------------------------
# Purpose : Assign InterPro domains and GO terms to the Helixer proteins with InterProScan 5.77-108.0 in a
#           container.
# Inputs  : $HOME/project_data/downy/contigs-renamed/helixer/*.faa; InterProScan data at
#           $HOME/db/interproscan-5.77-108.0
# Outputs : $HOME/project_data/downy/contigs-renamed/interproscan/<genome>/
# Runs on : SLURM array 0-3, 24 cores, apptainer
# Usage   : sbatch workflow/09-functional-annotation/protein-interproscan.sh
# ----------------------------------------------------------------------------------------

INPUT_DIR=$HOME/project_data/downy/contigs-renamed/helixer
RESULT_DIR=$HOME/project_data/downy/contigs-renamed/interproscan
FILES=($(find "$INPUT_DIR" -type f -name "*.faa"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=24

echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.faa}
mkdir -p ${RESULT_DIR}/${BASENAME}

TMPDIR=${RESULT_DIR}/${BASENAME}_tmp
mkdir -p $TMPDIR

start=$EPOCHREALTIME

apptainer exec \
--bind "$HOME:$HOME" \
--bind "$HOME/db/interproscan-5.77-108.0/data:/opt/interproscan/data" \
$HOME/software/interproscan_5.77-108.0.sif \
/opt/interproscan/interproscan.sh \
--cpu $THREADS \
--output-dir ${RESULT_DIR}/${BASENAME} \
--formats TSV,GFF3 \
--disable-precalc \
--goterms \
--iprlookup \
--pathways \
--input $FILE \
--tempdir $TMPDIR

end=$EPOCHREALTIME
runtime=$(echo "$end - $start" | bc)
