#!/bin/sh

THREADS=24
REF_PATH=$HOME/project_data/downy/ref-seq/

# build kraken2 oomycota db
DB_PATH=$HOME/project_data/downy/KrakenDB/verification
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/genome-bfh.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/verify.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/contam-genome.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/GCA_020520425.1_BTI_SOV_V1_genomic.fna --threads ${THREADS}
kraken2-build --db ${DB_PATH} --build --threads ${THREADS}
kraken2-build --db ${DB_PATH} --clean --threads ${THREADS}
