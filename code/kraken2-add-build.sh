#!/bin/bash
#SBATCH --job-name=kraken2_build
#SBATCH -c 24
#SBATCH --mem=180G

# add oomycete protein sequences to the Kraken2 database
refFiles=( $(ls ~/project_data/downy/ref-seq-prot) )
for REF_FILE in "${refFiles[@]}"; do
    echo "adding ${REF_FILE}..."
    kraken2-build --add-to-library ~/project_data/downy/ref-seq-prot/${REF_FILE} --db ~/project_data/downy/KrakenDB-prot --protein
done
# add possible contaminant protein sequences to the Kraken2 database
refFiles=( $(ls ~/project_data/downy/contam-prot) )
for REF_FILE in "${refFiles[@]}"; do
    echo "adding ${REF_FILE}..."
    kraken2-build --add-to-library ~/project_data/downy/contam-prot/${REF_FILE} --db ~/project_data/downy/KrakenDB-prot --protein
done

kraken2-build --build --db ~/project_data/downy/KrakenDB-prot --protein --threads 24
bracken-build -l 50 -d ~/project_data/downy/KrakenDB-prot -t 24
bracken-build -l 200 -d ~/project_data/downy/KrakenDB-prot -t 24