#!/bin/bash

WD=/data/run/yyang

mess run \
    --threads 24 \
    --input ../metagenome-simulation.tsv \
    --output ${WD}/project_data/downy/hifi-simulation \
    --tech pacbio \
    --error hifi