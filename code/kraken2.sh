#!/bin/bash
#SBATCH --cpus-per-task=24
#SBATCH --mem=180G

# this script will run kraken2 on the downy mildew data against the large protein database
# List of files to process (without the `.fastq.gz` extension)
FILES=("MSU1" "Phumuli" "SC1982")  # Add your file names here
WORK_PATH="/data/run/yyang"

for FILE in "${FILES[@]}"; do
  mkdir ${WORK_PATH}/project_data/downy/Kraken-raw
  # Run kraken2 on raw reads
  kraken2 --db ${WORK_PATH}/project_data/downy/KrakenDB-prot \
    --threads 24 \
    --output ${WORK_PATH}/project_data/downy/Kraken-raw/${FILE}.kraken \
    --report ${WORK_PATH}/project_data/downy/Kraken-raw/${FILE}.kreport \
    --gzip-compressed \
    ${WORK_PATH}/project_data/downy/data/${FILE}.fastq.gz

  bracken -d ${WORK_PATH}/project_data/downy/KrakenDB-prot \
    -i ${WORK_PATH}/project_data/downy/Kraken-raw/${FILE}.kreport \
    -o ${WORK_PATH}/project_data/downy/Kraken-raw/${FILE}.bracken \
    -w ${WORK_PATH}/project_data/downy/Kraken-raw/${FILE}.breport \
    -r 50 \
    -l S

  mkdir ${WORK_PATH}/project_data/downy/Kraken-asm
  # Run bracken on the assembly data
  kraken2 --db ${WORK_PATH}/project_data/downy/KrakenDB-prot \
    --threads 24 \
    --output ${WORK_PATH}/project_data/downy/Kraken-asm/${FILE}.kraken \
    --report ${WORK_PATH}/project_data/downy/Kraken-asm/${FILE}.kreport \
    --gzip-compressed \
    ${WORK_PATH}/project_data/downy/meta-asm/${FILE}/contigs.fasta.gz

  bracken -d ${WORK_PATH}/project_data/downy/KrakenDB-prot \
    -i ${WORK_PATH}/project_data/downy/Kraken-asm/${FILE}.kreport \
    -o ${WORK_PATH}/project_data/downy/Kraken-asm/${FILE}.bracken \
    -w ${WORK_PATH}/project_data/downy/Kraken-asm/${FILE}.breport \
    -r 200 \
    -l S
done