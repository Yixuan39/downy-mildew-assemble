#!/bin/bash
#SBATCH --cpu=10
#SBATCH --mem=0

# Define the arrays of files and reference files
FILES=("MSU1" "Phumuli" "SC1982")
refFiles=( $(ls ~/project_data/downy/ref-seq-prot | grep -v "dmnd") )

# Loop through each combination of FILES and refFiles
for INPUT_FILE in "${FILES[@]}"; do
    for REF_FILE in "${refFiles[@]}"; do
        echo "Running DIAMOND for ${INPUT_FILE} against ${REF_FILE}..."

        # Ensure the output directory exists
        mkdir -p ~/project_data/downy/diamond/${REF_FILE}

        # Run DIAMOND blastx
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

        echo "Completed DIAMOND for ${INPUT_FILE} against ${REF_FILE}"
    done
done