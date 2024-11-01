#!/bin/bash
#SBATCH --array=0-2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=200G

# List of files to process (without the `.fastq.gz` extension)
FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here

# Get the file name based on the task ID
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

# Run the python script with the corresponding file name
kraken2 --db ~/project_data/downy/KrakenDB-prot \
--threads 8 \
--output ~/project_data/downy/Kraken/${FILE}.txt \
--report ~/project_data/downy/Kraken/${FILE}.report \
~/project_data/downy/asm/${FILE}.fasta