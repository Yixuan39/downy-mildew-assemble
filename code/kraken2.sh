#!/bin/bash
#SBATCH --array=0-2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=180G

# this script will run kraken2 on the downy mildew data against the large protein database
# List of files to process (without the `.fastq.gz` extension)
FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here

# Get the file name based on the task ID
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

# Run kraken2 on raw reads
kraken2 --db ~/project_data/downy/KrakenDB-prot \
  --threads 24 \
  --output ~/project_data/downy/Kraken-raw/${FILE}.kraken \
  --report ~/project_data/downy/Kraken-raw/${FILE}.kreport \
  --gzip-compressed \
  ~/project_data/downy/data/${FILE}.fastq.gz

bracken -d ~/project_data/downy/KrakenDB-prot \
  -i ~/project_data/downy/Kraken-raw/${FILE}.kreport \
  -o ~/project_data/downy/Kraken-raw/${FILE}.bracken \
  -w ~/project_data/downy/Kraken-raw/${FILE}_S.breport \
  -r 50 \
  -l S

bracken -d ~/project_data/downy/KrakenDB-prot \
  -i ~/project_data/downy/Kraken-raw/${FILE}.kreport \
  -o ~/project_data/downy/Kraken-raw/${FILE}.bracken \
  -w ~/project_data/downy/Kraken-raw/${FILE}_G.breport \
  -r 50 \
  -l G

# Run bracken on the assembly data
kraken2 --db ~/project_data/downy/KrakenDB-prot \
  --threads 24 \
  --output ~/project_data/downy/Kraken-asm/${FILE}.kraken \
  --report ~/project_data/downy/Kraken-asm/${FILE}.kreport \
  --gzip-compressed \
  ~/project_data/downy/meta-asm/${FILE}/contigs.fasta.gz

bracken -d ~/project_data/downy/KrakenDB-prot \
  -i ~/project_data/downy/Kraken-asm/${FILE}.kreport \
  -o ~/project_data/downy/Kraken-asm/${FILE}.bracken \
  -w ~/project_data/downy/Kraken-asm/${FILE}_S.breport \
  -r 200 \
  -l S

bracken -d ~/project_data/downy/KrakenDB-prot \
  -i ~/project_data/downy/Kraken-asm/${FILE}.kreport \
  -o ~/project_data/downy/Kraken-asm/${FILE}.bracken \
  -w ~/project_data/downy/Kraken-asm/${FILE}_G.breport \
  -r 200 \
  -l G