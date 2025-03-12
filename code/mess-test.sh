#!/bin/bash

mess run \
    --input ../metagenome-simulation.tsv \
    --output ~/project_data/downy/simulated-hifi \
    --threads 24 \
    --tech pacbio \
    --error hifi \
    --model QSHMM-ONT-HQ \
    --passes 2 