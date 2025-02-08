#!/bin/sh

THREADS=10
REF_PATH=$HOME/project_data/downy/ref-seq/
# download kraken2 bacteria
kraken2-build --download-library bacteria --db ${REF_PATH}/genome --threads ${THREADS} --no-masking --use-ftp
kraken2-build --download-library bacteria --db ${REF_PATH}/protein --threads ${THREADS} --no-masking --protein --use-ftp
# download kraken2 fungi
kraken2-build --download-library fungi --db ${REF_PATH}/genome --threads ${THREADS} --no-masking --use-ftp
kraken2-build --download-library fungi --db ${REF_PATH}/protein --threads ${THREADS} --no-masking --protein --use-ftp
# download kraken2 human
kraken2-build --download-library human --db ${REF_PATH}/genome --threads ${THREADS} --no-masking --use-ftp
kraken2-build --download-library human --db ${REF_PATH}/protein --threads ${THREADS} --no-masking --protein --use-ftp

# combine genome files
FILES=$(find ${REF_PATH}/genome -name "*.fna")
cat ${FILES} > ${REF_PATH}/genome-bfh.fasta
rm -rf ${REF_PATH}/genome
# combine protein files
FILES=$(find ${REF_PATH}/protein -name "*.faa")
cat ${FILES} > ${REF_PATH}/protein-bfh.fasta
rm -rf ${REF_PATH}/protein