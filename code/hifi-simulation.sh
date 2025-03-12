#!/bin/bash

mess run \
    --input ../metagenome-simulation.tsv \
    --output $HOME/project_data/downy/hifi-simulation \
    --tech pacbio \
    --error hifi \
    --model QSHMM-ONT-HQ 