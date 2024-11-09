#!/bin/bash
#SBATCH --cpu=32
#SBATCH --mem=0

# Define the arrays of files and reference files
FILES=("MSU1" "Phumuli" "SC1982")
refFiles=( $(ls ~/project_data/downy/ref-seq-prot | grep -v "dmnd") )
threads=32

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
            --threads ${threads}

        # run busco
        # here we are not using auto-lineage, it will make the process fast and use less memory
        busco -i ~/project_data/downy/diamond/${REF_FILE}/${INPUT_FILE}.fasta \
            -l stramenopiles_odb10 \
            --out_path ~/project_data/downy/diamond/${REF_FILE}/${INPUT_FILE}_busco \
            --mode genome \
            --download_path ~/project_data/downy/busco_downloads \
            --cpu ${threads} \
            --offline \
            --force \
            --tar

        # run quast
        quast.py --output-dir ~/project_data/downy/diamond/${REF_FILE}/${INPUT_FILE}_quast \
            --threads ${threads} \
            --eukaryote \
            ~/project_data/downy/diamond/${REF_FILE}/${INPUT_FILE}.fasta


    done
done