#!/bin/bash
#SBATCH --job-name=rag_tag
#SBATCH --cpus-per-task=24

set -euo pipefail

# with hifiasm results, run purge_dups on the primary assembly.
INPUT=$HOME/project_data/downy/cleaned_contigs/Quesada_SQIIe_MSU1/*.fasta.gz
RESULT_DIR=$HOME/project_data/downy/Scaffold/Quesada_SQIIe_MSU1
REF=$HOME/project_data/downy/oomycota-genome/Peronospora-effusa.fna
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
THREADS=24
mkdir -p $RESULT_DIR


gzip -dkc $INPUT > $INPUT.fasta

ragtag.py scaffold \
  -o $RESULT_DIR/ragtag \
  -w \
  -t $THREADS \
  $REF \
  $INPUT.fasta

gzip -c $RESULT_DIR/ragtag/ragtag.scaffold.fasta > $RESULT_DIR/Quesada_SQIIe_MSU1.fasta.gz
rm -rf $RESULT_DIR/ragtag
rm $INPUT.fasta

python quality-check.py \
  --input_file $RESULT_DIR/Quesada_SQIIe_MSU1.fasta.gz \
  --output_dir $RESULT_DIR \
  --library_path $BUSCO_DB \
  --threads $THREADS