#!/bin/bash

mess run \
    --threads 24 \
    --input ../metagenome-simulation.tsv \
    --output $HOME/project_data/downy/hifi-simulation \
    --tech pacbio \
    --error hifi \
    --model QSHMM-RSII  