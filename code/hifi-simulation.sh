#!/bin/bash

OUTPUT_FOLDER=$HOME/project_data/downy/hifi-simulation

mess run \
    --input ../metagenome-simulation.tsv \
    --output ${OUTPUT_FOLDER} \
    --tech pacbio \
    --error hifi \
    --model QSHMM-ONT-HQ 
    
metaMDBG asm \
    --out-dir ${OUTPUT_FOLDER} \
    --in-hifi ${OUTPUT_FOLDER}/fastq/*.fq.gz \
    --threads 24