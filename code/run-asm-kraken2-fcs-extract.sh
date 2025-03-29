#!/bin/bash
#SBATCH --job-name=run
#SBATCH --array=0-3
#SBATCH --cpus-per-task=24
#SBATCH --mem=500G

INPUT_DIR=$HOME/project_data/downy/GSL_Data/fastq
FILES=($(find "$INPUT_DIR" -type f -name "*.fastq.gz"))
GX_DB=$HOME/project_data/downy/fcs-db/
KrakenDB_oomycota_genomic=$HOME/project_data/downy/KrakenDB/oomycota-genome
KrakenDB_oomycota_protein=$HOME/project_data/downy/KrakenDB/oomycota-protein
KrakenDB_contam_genomic=$HOME/project_data/downy/KrakenDB/contam-genome
KrakenDB_contam_protein=$HOME/project_data/downy/KrakenDB/contam-protein
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
CS_LIST=(0 0.25 0.5 0.75) 
CS=${CS_LIST[$SLURM_ARRAY_TASK_ID]} 
TAXID=4762
MIN_LENGTH=5000
THREADS=24
EXTRACT=true


# assemble first, then use fcs, then kraken2
OUTPUT_DIR=$HOME/project_data/downy/kraken2-extract/asm-fcs-kraken2/oomycota-genomic/${CS}
mkdir -p $OUTPUT_DIR
for FILE in ${FILES}; do
    bash asm-kraken2-fcs.sh \
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

OUTPUT_DIR=$HOME/project_data/downy/kraken2-extract/asm-fcs-kraken2/contam-genomic/${CS}
mkdir -p $OUTPUT_DIR
for FILE in ${FILES}; do
    bash asm-kraken2-fcs.sh \
      -i $FILE \
      -o $OUTPUT_DIR \
      -d $GX_DB \
      -k $KrakenDB_contam_genomic \
      -b $BUSCO_DB \
      -c $CS \
      -t $TAXID \
      -e $EXTRACT \
      -m $MIN_LENGTH \
      -p $THREADS
done

OUTPUT_DIR=$HOME/project_data/downy/kraken2-extract/asm-fcs-kraken2/oomycota-protein/${CS}
mkdir -p $OUTPUT_DIR
for FILE in ${FILES}; do
    bash asm-kraken2-fcs.sh \
      -i $FILE \
      -o $OUTPUT_DIR \
      -d $GX_DB \
      -k $KrakenDB_oomycota_protein \
      -b $BUSCO_DB \
      -c $CS \
      -t $TAXID \
      -e $EXTRACT \
      -m $MIN_LENGTH \
      -p $THREADS
done

OUTPUT_DIR=$HOME/project_data/downy/kraken2-extract/asm-fcs-kraken2/contam-protein/${CS}
mkdir -p $OUTPUT_DIR
for FILE in ${FILES}; do
    bash asm-kraken2-fcs.sh \
      -i $FILE \
      -o $OUTPUT_DIR \
      -d $GX_DB \
      -k $KrakenDB_contam_protein \
      -b $BUSCO_DB \
      -c $CS \
      -t $TAXID \
      -e $EXTRACT \
      -m $MIN_LENGTH \
      -p $THREADS
done
