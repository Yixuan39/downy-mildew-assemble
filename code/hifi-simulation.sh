#!/bin/bash

PATH=/data/run/yyang

mess run \
    --threads 24 \
    --input ../metagenome-simulation.tsv \
    --output $PATH/project_data/downy/hifi-simulation \
    --tech pacbio \
    --error hifi