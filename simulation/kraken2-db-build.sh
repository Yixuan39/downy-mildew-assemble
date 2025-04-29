#!/bin/sh
#SBATCH --cpus-per-task=32

THREADS=32
REF_PATH=$HOME/project_data/downy/ref-seq/

# build kraken2 oomycota db
DB_PATH=$HOME/project_data/downy/KrakenDB/simulation
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/genome-bfh.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/simulation.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/contam-genome.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --build --threads ${THREADS}
kraken2-build --db ${DB_PATH} --clean --threads ${THREADS}
