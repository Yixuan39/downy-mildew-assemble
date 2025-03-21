#!/bin/bash

mess run \
    --input ../subsample.tsv \
    --output $HOME/project_data/downy/hifi-simulation \
    --threads 8 \
    --tech pacbio \
    --model QSHMM-RSII