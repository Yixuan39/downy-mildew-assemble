#!/bin/bash

mess run \
    --input ../simulation-info/subsample-prop.tsv \
    --output $HOME/project_data/downy/hifi-simulation \
    --threads 24 \
    --bases 15G \
    --tech pacbio \
    --model QSHMM-RSII \
    --error hifi \
    --mean-len 9000 \
    --accuracy 0.999 \
    --passes 10