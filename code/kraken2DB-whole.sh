#!/bin/bash
WORK_PATH="/data/run/yyang"

# Here we are not using the --protein flag, because we use protein sequences translated from the nucleotide sequences
kraken2-build --download-taxonomy --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --use-ftp
# download bacterial, fungi, human protein sequences to the Kraken2 database
kraken2-build --download-library bacteria --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --protein --use-ftp
kraken2-build --download-library fungi --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --protein --use-ftp
kraken2-build --download-library human --db ${WORK_PATH}/project_data/downy/KrakenDB-prot --protein --use-ftp

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
bracken-build -d ${WORK_PATH}/project_data/downy/KrakenDB-prot -l 50 -t 32