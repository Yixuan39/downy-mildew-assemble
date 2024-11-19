#!/bin/bash
#SBATCH --job-name=kraken2_build
#SBATCH -c 32
#SBATCH --mem=180G
WORK_PATH="/data/run/yyang"

kraken2-build --download-taxonomy --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --protein --use-ftp
# download bacterial, fungi, human protein sequences to the Kraken2 database
kraken2-build --download-library bacteria --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --protein
kraken2-build --download-library fungi --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --protein
kraken2-build --download-library human --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --protein

# add oomycete protein sequences to the Kraken2 database
refFiles=( $(ls ${WORK_PATH}/project_data/downy/ref-seq-prot) )
for REF_FILE in "${refFiles[@]}"; do
    echo "adding ${REF_FILE}..."
    kraken2-build --add-to-library ${WORK_PATH}/project_data/downy/ref-seq-prot/${REF_FILE} --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --protein
done
# add possible contaminant protein sequences to the Kraken2 database
refFiles=( $(ls ${WORK_PATH}/project_data/downy/contam-prot) )
for REF_FILE in "${refFiles[@]}"; do
    echo "adding ${REF_FILE}..."
    kraken2-build --add-to-library ${WORK_PATH}/project_data/downy/contam-prot/${REF_FILE} --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --protein
done

kraken2-build --build --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --protein --threads 32
bracken-build -l 50 -d ${WORK_PATH}/project_data/downy/KrakenDB-prot -t 32
bracken-build -l 200 -d ${WORK_PATH}/project_data/downy/KrakenDB-prot -t 32