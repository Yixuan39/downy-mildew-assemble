#!/bin/bash
#SBATCH --cpus-per-task=32

seqkit fx2tab \
    $HOME/project_data/downy/GSL_Data/fastq/Quesada_SQIIe_MSU1.fastq.gz \
    -n -l -j 32 \
    -o $HOME/project_data/downy/GSL_Data/length/MSU1.tsv.gz
    
seqkit fx2tab \
    $HOME/project_data/downy/GSL_Data/fastq/Quesada_SQIIe_Phumuli.fastq.gz \
    -n -l -j 32 \
    -o $HOME/project_data/downy/GSL_Data/length/Phumuli.tsv.gz

seqkit fx2tab \
    $HOME/project_data/downy/GSL_Data/fastq/Quesada_SQIIe_SC1982.fastq.gz \
    -n -l -j 32 \
    -o $HOME/project_data/downy/GSL_Data/length/SC1982.tsv.gz