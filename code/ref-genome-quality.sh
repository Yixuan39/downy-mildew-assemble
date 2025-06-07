#!/bin/bash
#SBATCH --cpus-per-task=24

INPUT_DIR=$HOME/project_data/downy/oomycota-genome
FILES=($(find "$INPUT_DIR" -type f -name "*.fna.gz"))
RESULT_DIR=$HOME/project_data/downy/oomycota-genome/compleasm
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
THREADS=24

for FILE in ${FILES[@]}; do
  BASENAME=$(basename "$FILE")  
  BASENAME=${BASENAME%.fna.gz}  
  
  python quality-check.py \
      --input_file ${FILE} \
      --output_dir ${RESULT_DIR} \
      --suffix ${BASENAME} \
      --library_path ${BUSCO_DB} \
      --threads ${THREADS}
    
done