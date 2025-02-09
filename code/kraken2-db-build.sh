#!/bin/sh

THREADS=32
REF_PATH=$HOME/project_data/downy/ref-seq/

# build kraken2 oomycota db
DB_PATH=$HOME/project_data/downy/KrakenDB/oomycota-genome
# kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/genome-bfh.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/oomycota-genome.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/contam-genome.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --build --threads ${THREADS}
kraken2-build --db ${DB_PATH} --clean --threads ${THREADS}

# build kraken2 oomycota protein db
DB_PATH=$HOME/project_data/downy/KrakenDB/oomycota-protein
# kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS} 
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/protein-bfh.fasta --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/oomycota-protein.fasta --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/contam-protein.fasta --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --build --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --clean --threads ${THREADS} --protein

# build kraken2 contam db
DB_PATH=$HOME/project_data/downy/KrakenDB/contam-genome
# kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/genome-bfh.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/contam-genome.fasta --threads ${THREADS}
kraken2-build --db ${DB_PATH} --build --threads ${THREADS}
kraken2-build --db ${DB_PATH} --clean --threads ${THREADS}

# build kraken2 contam protein db
DB_PATH=$HOME/project_data/downy/KrakenDB/contam-protein
# kraken2-build --db ${DB_PATH} --download-taxonomy --threads ${THREADS} 
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/protein-bfh.fasta --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --add-to-library ${REF_PATH}/contam-protein.fasta --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --build --threads ${THREADS} --protein
kraken2-build --db ${DB_PATH} --clean --threads ${THREADS} --protein
