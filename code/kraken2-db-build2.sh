#!/bin/sh

THREADS=32
REF_PATH=$HOME/project_data/downy/ref-seq/

# build kraken2 oomycota db
DB_PATH=$HOME/project_data/downy/KrakenDB/oomycota-genome 
kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS} 

# build kraken2 oomycota protein db
DB_PATH=$HOME/project_data/downy/KrakenDB/oomycota-protein
kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS} 

# build kraken2 contam db
DB_PATH=$HOME/project_data/downy/KrakenDB/contam-genome
kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS} 

# build kraken2 contam protein db
DB_PATH=$HOME/project_data/downy/KrakenDB/contam-protein
kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS} 

