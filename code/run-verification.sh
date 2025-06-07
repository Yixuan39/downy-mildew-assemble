#!/bin/bash
#SBATCH --job-name=verification
#SBATCH --cpus-per-task=24
#SBATCH --mem=500G

FILE=$HOME/project_data/downy/verification/SRR15142133.fastq.gz
GX_DB=$HOME/project_data/downy/fcs-db/
KrakenDB_oomycota_genomic=$HOME/project_data/downy/KrakenDB/verification
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
CS_LIST="0,0.05,0.1,0.15,0.2"
TAXID=4762
MIN_LENGTH=5000
THREADS=24
EXTRACT=true

OUTPUT_DIR=$HOME/project_data/downy/result/verification/genomic/${CS}
mkdir -p $OUTPUT_DIR
bash clean-asm.sh \
      -i $FILE \
      -o $OUTPUT_DIR \
      -d $GX_DB \
      -k $KrakenDB_oomycota_genomic \
      -b $BUSCO_DB \
      -c $CS_LIST \
      -t $TAXID \
      -e $EXTRACT \
      -m $MIN_LENGTH \
      -p $THREADS

      

