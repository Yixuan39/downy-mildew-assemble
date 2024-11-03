#!/bin/bash
#SBATCH --array=0-2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=200G

# this script will run kraken2 on the downy mildew data against the large protein database
# List of files to process (without the `.fastq.gz` extension)
FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here

# Get the file name based on the task ID
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

# Run the python script with the corresponding file name
kraken2 --db ~/project_data/downy/KrakenDB-prot \
--threads 8 \
--output ~/project_data/downy/Kraken/${FILE}.kraken \
--report ~/project_data/downy/Kraken/${FILE}.kreport \
~/project_data/downy/asm/${FILE}.fasta

bracken -d ~/project_data/downy/KrakenDB-prot \
-i ~/project_data/downy/Kraken/${FILE}.report \
-o ~/project_data/downy/Kraken/${FILE}.bracken \
-w ~/project_data/downy/Kraken/${FILE}.breport \
-r 2000 \ # shortest read length of our samples is around 2000
-l S \
-t 10 # number of reads required PRIOR to abundance estimation to perform reestimation