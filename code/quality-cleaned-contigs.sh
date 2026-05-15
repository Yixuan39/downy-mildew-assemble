#!/bin/bash
#SBATCH --job-name=qc
#SBATCH --cpus-per-task=24

set -euo pipefail

DIR=$HOME/project_data/downy/cleaned_contigs/p_effusa/
FILE=($(find "$DIR" -type f -name "*.fasta.gz"))
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
THREADS=24
mkdir -p $DIR

python quality-check.py \
  --input_file $FILE \
  --output_dir $DIR \
  --library_path $BUSCO_DB \
  --threads $THREADS
  
DIR=$HOME/project_data/downy/cleaned_contigs/Quesada_SQIIe_MSU1/
FILE=($(find "$DIR" -type f -name "*.fasta.gz"))
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
THREADS=24
mkdir -p $DIR

python quality-check.py \
  --input_file $FILE \
  --output_dir $DIR \
  --library_path $BUSCO_DB \
  --threads $THREADS
  
DIR=$HOME/project_data/downy/cleaned_contigs/Quesada_SQIIe_Phumuli/
FILE=($(find "$DIR" -type f -name "*.fasta.gz"))
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
THREADS=24
mkdir -p $DIR

python quality-check.py \
  --input_file $FILE \
  --output_dir $DIR \
  --library_path $BUSCO_DB \
  --threads $THREADS
  
DIR=$HOME/project_data/downy/cleaned_contigs/Quesada_SQIIe_SC1982/
FILE=($(find "$DIR" -type f -name "*.fasta.gz"))
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
THREADS=24
mkdir -p $DIR

python quality-check.py \
  --input_file $FILE \
  --output_dir $DIR \
  --library_path $BUSCO_DB \
  --threads $THREADS