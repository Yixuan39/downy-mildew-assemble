#!/bin/bash
#SBATCH -c 24
# Assembly genome with purly hifiasm

hifiasm \
    -t 24 \
    -l 2 \
    --primary \
    -o ~/project_data/downy/benchmarking/hifiasm/p_effusa \
    ~/project_data/downy/p_effusa/filtered/p_effusa.fastq.gz
    
gfatools gfa2fa \
    ~/project_data/downy/benchmarking/hifiasm/p_effusa.p_ctg.gfa \
    | gzip -c > ~/project_data/downy/benchmarking/hifiasm/p_effusa.p_ctg.fasta.gz