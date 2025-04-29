#!/bin/bash

mess run \
    --input ./information/subsample-prop.tsv \
    --output $HOME/project_data/downy/hifi-simulation \
    --threads 24 \
    --bases 10G \
    --tech pacbio \
    --model QSHMM-RSII \
    --error hifi \
    --mean-len 9000 \
    --accuracy 0.999 \
    --passes 10