#!/bin/bash

mess run \
    --input ../subsample.tsv \
    --output $HOME/project_data/downy/hifi-simulation \
    --threads 8 \
    --tech pacbio \
    --tool pbsim3 \
    --error hifi \
    --ratio '22:45:33' \
    --max_len 1000000 \
    --mean_len 9000 \
    --min_len 100 \
    --sd_len 7000 \
    --accuracy 0.999 \
    --passes 10 \
    --model QSHMM-RSII