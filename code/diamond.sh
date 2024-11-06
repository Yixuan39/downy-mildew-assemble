#!/bin/bash
#SBATCH --job-name=pacbio_cleaning
#SBATCH --output=logs/output_%A_%a.out
#SBATCH --array=0-53
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=40G


FILES=("MSU1" "Phumuli" "SC1982")
# Only use the files that do not have "dmnd" in the name
refFiles=( $(ls ~/project_data/downy/ref-seq-prot | grep -v "dmnd") )

# Calculate indices for FILES and refFiles based on the task ID
FILE_INDEX=$((SLURM_ARRAY_TASK_ID / ${#refFiles[@]}))
REF_INDEX=$((SLURM_ARRAY_TASK_ID % ${#refFiles[@]}))

# Access specific elements in each array
INPUT_FILE=${FILES[$FILE_INDEX]}
REF_FILE=${refFiles[$REF_INDEX]}

# Ensure the output directory exists
mkdir -p ~/project_data/downy/diamond/${REF_FILE}

diamond blastx \
  --db ~/project_data/downy/ref-seq-prot/${REF_FILE} \
  --query ~/project_data/downy/meta-asm/${INPUT_FILE}/contigs.fasta.gz \
  --out ~/project_data/downy/diamond/${REF_FILE}/${INPUT_FILE}.csv \
  --al ~/project_data/downy/diamond/${REF_FILE}/${INPUT_FILE}.fasta \
  --evalue 1e-10 \
  --max-target-seqs 1 \
  --max-hsps 1 \
  --very-sensitive \
  --outfmt 6 \
  --threads 8

## Run the python script with the corresponding file name
#python pacbio_cleaning.py \
#  --input ~/project_data/downy/asm/${INPUT_FILE}.fasta \
#  --ref ~/project_data/downy/ref-seq-prot/${REF_FILE} \
#  --output ~/project_data/downy/diamond/${REF_FILE}/${INPUT_FILE}.fasta \
#  --threads 8 \
#  --busco_downloads_path ~/project_data/downy/busco_downloads