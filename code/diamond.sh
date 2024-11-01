#!/bin/bash
#SBATCH --array=0-53
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10

FILES=("MSU1" "Phumuli" "SC1982")
refFiles=( $(ls ~/project_data/downy/ref-seq-prot) )

INPUT_FILE=${FILES[$((SLURM_ARRAY_TASK_ID % ${#FILES[@]}))]}  # Cycle through FILES array
REF_FILE=${refFiles[$((SLURM_ARRAY_TASK_ID % ${#refFiles[@]}))]}  # Cycle through refFiles array

# Run the python script with the corresponding file name
python pacbio_cleaning.py \
  --input ~/project_data/downy/asm/${INPUT_FILE}.fasta \
  --ref ~/project_data/downy/ref-seq-prot/${REF_FILE} \
  --output ~/project_data/downy/diamond/${REF_FILE}/${INPUT_FILE}.fasta \
  --threads 10 \
  --busco-downloads-path ~/project_data/downy/busco_downloads