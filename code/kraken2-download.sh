#!/bin/sh

THREADS=10
REF_PATH=$HOME/project_data/downy/ref-seq/
# download kraken2 bacteria
kraken2-build --download-library bacteria --db ${REF_PATH}/genome --threads ${THREADS} --no-masking --use-ftp
# download kraken2 fungi
kraken2-build --download-library fungi --db ${REF_PATH}/genome --threads ${THREADS} --no-masking --use-ftp
# download kraken2 human
kraken2-build --download-library human --db ${REF_PATH}/genome --threads ${THREADS} --no-masking --use-ftp
# download kraken2 plant
kraken2-build --download-library plant --db ${REF_PATH}/genome --threads ${THREADS} --no-masking --use-ftp

# combine genome files
FILES=$(find ${REF_PATH}/genome -name "*.fna")
cat ${FILES} > ${REF_PATH}/genome.fasta

# download library
DB_PATH=$HOME/project_data/downy/KrakenDB
kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS} --use-ftp