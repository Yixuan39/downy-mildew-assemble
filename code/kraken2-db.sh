#!/bin/sh

THREADS=32
REF_PATH=$HOME/project_data/downy/ref-seq/
# download kraken2 bacteria
kraken2-build --download-library bacteria --db ${REF_PATH}/genome --threads ${THREADS} --no-masking
kraken2-build --download-library bacteria --db ${REF_PATH}/protein --threads ${THREADS} --no-masking --protein
# download kraken2 fungi
kraken2-build --download-library fungi --db ${REF_PATH}/genome --threads ${THREADS} --no-masking
kraken2-build --download-library fungi --db ${REF_PATH}/protein --threads ${THREADS} --no-masking --protein
# download kraken2 human
kraken2-build --download-library human --db ${REF_PATH}/genome --threads ${THREADS} --no-masking
kraken2-build --download-library human --db ${REF_PATH}/protein --threads ${THREADS} --no-masking --protein

# combine genome files
FILES=$(find ${REF_PATH}/genome -name "*.fna")
cat ${FILES} > ${REF_PATH}/genome-bfh.fasta
# rm -rf ${REF_PATH}/genome
# combine protein files
FILES=$(find ${REF_PATH}/protein -name "*.faa")
cat ${FILES} > ${REF_PATH}/protein-bfh.fasta
# rm -rf ${REF_PATH}/protein

# build kraken2 oomycota db
DB_PATH=$HOME/project_data/downy/KrakenDB/oomycota-genome
kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/genome-bfh.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/oomycota-genome.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/contam-genome.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --build --threads ${THREADS}
kraken2-build --db ${DB_PATH} --clean --threads ${THREADS}

# build kraken2 oomycota protein db
DB_PATH=$HOME/project_data/downy/KrakenDB/oomycota-protein
kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS} 
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/protein-bfh.fasta --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/oomycota-protein.fasta --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/contam-protein.fasta --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --build --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --clean --threads ${THREADS} --protein

# build kraken2 contam db
DB_PATH=$HOME/project_data/downy/KrakenDB/contam-genome
kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/genome-bfh.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/contam-genome.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --build --threads ${THREADS}
kraken2-build --db ${DB_PATH} --clean --threads ${THREADS}

# build kraken2 contam protein db
DB_PATH=$HOME/project_data/downy/KrakenDB/contam-protein
kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS} 
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/protein-bfh.fasta --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/contam-protein.fasta --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --build --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --clean --threads ${THREADS} --protein
