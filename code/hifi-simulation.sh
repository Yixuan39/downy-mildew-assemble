#!/bin/bash

mess run \
    --input ../subsample-seqabn.tsv \
    --output $HOME/project_data/downy/hifi-simulation \
    --threads 8 \
    --tech pacbio \
    --model QSHMM-RSII \
    --error hifi \
    --mean-len 9000 \
    --accuracy 0.999 \
    --passes 10