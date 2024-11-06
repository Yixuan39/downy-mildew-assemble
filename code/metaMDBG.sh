#!/bin/bash

# This script will run MetaMDBG on the downy mildew data
FILES=("MSU1" "Phumuli" "SC1982")

for FILE in "${FILES[@]}"; do
  metaMDBG asm \
  --out-dir ~/project_data/downy/meta-asm/${FILE} \
  --in-hifi ~/project_data/downy/data/${FILE}.fastq.gz \
  --threads 24
done