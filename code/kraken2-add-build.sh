#!/bin/bash
#SBATCH --job-name=kraken2_build
#SBATCH -c 24
#SBATCH --mem=180G

KRAKEN2_DB_PATH="KrakenDB-prot"
# add oomycete protein sequences to the Kraken2 database
refFiles=( $(ls ~/project_data/downy/ref-seq-prot) )
for REF_FILE in "${refFiles[@]}"; do
    echo "adding ${REF_FILE}..."
    kraken2-build --add-to-library ~/project_data/downy/ref-seq-prot/${REF_FILE} --db $KRAKEN2_DB_PATH --protein
done

contamFiles=( $(ls ~/project_data/downy/contam-prot) )
for REF_FILE in "${refFiles[@]}"; do
    echo "adding ${REF_FILE}..."
    kraken2-build --add-to-library ~/project_data/downy/contam-prot/${REF_FILE} --db $KRAKEN2_DB_PATH --protein
done

kraken2-build --build --db KrakenDB-prot --protein --threads 24
bracken-build -l 50 -d KrakenDB-prot -t 24
bracken-build -l 200 -d KrakenDB-prot -t 24