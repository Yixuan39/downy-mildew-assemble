#!/bin/bash
#SBATCH --job-name=run
#SBATCH --cpus-per-task=24
#SBATCH --mem=500G

INPUT_DIR=$HOME/project_data/downy/GSL_Data/fastq
FILES=($(find "$INPUT_DIR" -type f -name "*.fastq.gz"))
GX_DB=$HOME/project_data/downy/fcs-db/
KrakenDB_oomycota_genomic=$HOME/project_data/downy/KrakenDB/oomycota-genome-small
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
CS=0.5
TAXID=4762
MIN_LENGTH=5000
THREADS=24
EXTRACT=true


# assemble first, then use fcs, then kraken2
OUTPUT_DIR=$HOME/project_data/downy/kraken2-extract/asm-fcs-kraken2-smalldb/oomycota-genomic/${CS}
mkdir -p $OUTPUT_DIR
for FILE in ${FILES}; do
    bash asm-fcs-kraken2.sh \
      -i $FILE \
      -o $OUTPUT_DIR \
      -d $GX_DB \
      -k $KrakenDB_oomycota_genomic \
      -b $BUSCO_DB \
      -c $CS \
      -t $TAXID \
      -e $EXTRACT \
      -m $MIN_LENGTH \
      -p $THREADS
done