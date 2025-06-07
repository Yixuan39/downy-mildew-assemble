#!/bin/bash
#SBATCH --job-name=verification
#SBATCH --cpus-per-task=24

FILE=$HOME/project_data/downy/verification/SRR15142133.fastq.gz
KrakenDB=$HOME/project_data/downy/KrakenDB/verification
THREADS=24
RESULT_DIR=$HOME/project_data/downy/result/verification/length
mkdir -p $RESULT_DIR

kraken2 \
      --db ${KrakenDB} \
      --confidence 0 \
      --threads ${THREADS} \
      --output ${RESULT_DIR}/SRR15142133.kraken \
      --report ${RESULT_DIR}/SRR15142133.kreport \
      ${FILE}
      

