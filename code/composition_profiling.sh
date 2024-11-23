#!/bin/bash

FILES=("MSU1" "Phumuli" "SC1982")
WORK_PATH="/data/run/yyang"

for FILE in "${FILES[@]}"; do
    # Run kraken2 on raw reads
    kraken2 --db ${WORK_PATH}/project_data/downy/KrakenDB-prot \
      --threads 24 \
      --output - \
      --report ${WORK_PATH}/project_data/downy/composition_profile/${FILE}.kreport \
      --gzip-compressed \
      ${WORK_PATH}/project_data/downy/data/${FILE}.fastq.gz

    bracken -d ${WORK_PATH}/project_data/downy/KrakenDB-prot \
      -i ${WORK_PATH}/project_data/downy/composition_profile/${FILE}.kreport \
      -o ${WORK_PATH}/project_data/downy/composition_profile/${FILE}.bracken \
      -w ${WORK_PATH}/project_data/downy/composition_profile/${FILE}.breport \
      -r 50 \
      -l S
done