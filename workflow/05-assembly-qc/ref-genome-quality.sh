#!/bin/bash
#SBATCH --cpus-per-task=24

# ----------------------------------------------------------------------------------------
# Purpose : Score the wider set of oomycete reference genomes with compleasm and QUAST, giving the clade-
#           level context for the assembly quality figure.
# Inputs  : $HOME/project_data/downy/oomycota-genome/*.fna.gz; compleasm lineages at $HOME/db/compleasm
# Outputs : $HOME/project_data/downy/oomycota-genome/compleasm/<genome>/quality.csv
# Runs on : SLURM, 24 cores
# Usage   : sbatch workflow/05-assembly-qc/ref-genome-quality.sh
# ----------------------------------------------------------------------------------------

INPUT_DIR=$HOME/project_data/downy/oomycota-genome
FILES=($(find "$INPUT_DIR" -type f -name "*.fna.gz"))
RESULT_DIR=$HOME/project_data/downy/oomycota-genome/compleasm
BUSCO_DB=$HOME/db/compleasm
THREADS=24

for FILE in ${FILES[@]}; do
  BASENAME=$(basename "$FILE")  
  BASENAME=${BASENAME%.fna.gz}  
  
  python "$(dirname "$0")/quality-check.py" \
      --input_file ${FILE} \
      --output_dir ${RESULT_DIR} \
      --suffix ${BASENAME} \
      --library_path ${BUSCO_DB} \
      --threads ${THREADS}
    
done