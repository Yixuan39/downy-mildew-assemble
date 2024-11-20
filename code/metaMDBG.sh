#!/bin/bash

# This script will run MetaMDBG on the downy mildew data
FILES=("MSU1" "Phumuli" "SC1982")
WORK_PATH="/data/run/yyang"

for FILE in "${FILES[@]}"; do
  metaMDBG asm \
  --out-dir ${WORK_PATH}/project_data/downy/meta-asm/${FILE} \
  --in-hifi ${WORK_PATH}/project_data/downy/data/${FILE}.fastq.gz \
  --threads 32
done