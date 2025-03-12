#!/bin/bash

mess run \
    --input ../metagenome-simulation.tsv \
    --output ~/project_data/downy/simulated-hifi \
    --threads 10 \
    --tech pacbio \
    --error hifi  