#!/bin/bash
#SBATCH --job-name=rag_tag
#SBATCH --cpus-per-task=24

set -euo pipefail

# with hifiasm results, run purge_dups on the primary assembly.
INPUT=$HOME/project_data/downy/Assembly/p_effusa/p_effusa.fasta.gz
RESULT_DIR=$HOME/project_data/downy/Scaffold/p_effusa
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

gzip -c $RESULT_DIR/ragtag/ragtag.scaffold.fasta > $RESULT_DIR/p_effusa.fasta.gz
rm -rf $RESULT_DIR/ragtag
rm $INPUT.fasta

python quality-check.py \
  --input_file $RESULT_DIR/p_effusa.fasta.gz \
  --output_dir $RESULT_DIR \
  --library_path $BUSCO_DB \
  --threads $THREADS