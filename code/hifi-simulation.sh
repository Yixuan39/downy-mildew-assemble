#!/bin/bash

mess run \
    --input ../subsample-seqabn.tsv \
    --output $HOME/project_data/downy/hifi-simulation \
    --threads 8 \
    --tech pacbio \
    --model QSHMM-RSII \
    --error hifi \
    --length-min 100 \
    --length-max 1000000 \
    --length-mean 9000 \
    --length-sd 7000 