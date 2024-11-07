#!/bin/bash
#SBATCH --job-name=kraken_cleaning
#SBATCH --array=0-17
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=180G


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
mkdir -p ~/project_data/downy/Kraken/${REF_FILE}

for INPUT_FILE in "${FILES[@]}"; do
  kraken2-build --download-taxonomy --db ~/project_data/downy/ref-seq-prot/${REF_FILE}
  kraken2-build --add-to-library ~/project_data/downy/ref-seq-prot/${REF_FILE} --db ~/project_data/downy/ref-seq-prot/${REF_FILE}
  kraken2-build --build --db ~/project_data/downy/ref-seq-prot/${REF_FILE}

  kraken2 --db ~/project_data/downy/ref-seq-prot/${REF_FILE} \
    --threads 24 \
    --output - \
    --classified-out ~/project_data/downy/Kraken/${REF_FILE}/${INPUT_FILE}.fasta \
    --gzip-compressed \
    ~/project_data/downy/meta-asm/${INPUT_FILE}/contigs.fasta.gz
done