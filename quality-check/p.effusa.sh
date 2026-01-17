#!/bin/bash
#SBATCH --job-name=QC
#SBATCH --cpus-per-task=24

set -euo pipefail

# with hifiasm results, run purge_dups on the primary assembly.
INPUT=$HOME/Projects/downy-mildew-assemble/data/cleaned_contigs/SRR15142133/*.fasta.gz
RESULT_DIR=$HOME/Projects/downy-mildew-assemble/data/cleaned_contigs/SRR15142133
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
THREADS=24
mkdir -p $RESULT_DIR

python quality-check.py \
  --input_file $RESULT_DIR/SRR15142133.fasta.gz \
  --output_dir $RESULT_DIR \
  --library_path $BUSCO_DB \
  --threads $THREADS