#!/bin/bash
#SBATCH -c 32
#SBATCH --mem=0
#SBATCH --output=hifiasm_%j.out

total_start=$EPOCHREALTIME
echo "HIFIASM pipeline started: $(date)"

mkdir -p $HOME/project_data/downy/benchmarking/hifiasm

# Assemble with hifiasm
start=$EPOCHREALTIME
hifiasm \
    -t 32 \
    -l 2 \
    --primary \
    -o $HOME/project_data/downy/benchmarking/hifiasm/p_effusa \
    $HOME/project_data/downy/p_effusa/filtered/p_effusa.fastq.gz
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "Assembly: $runtime seconds"

# Convert to fasta
gfatools gfa2fa \
    $HOME/project_data/downy/benchmarking/hifiasm/p_effusa.p_ctg.gfa \
    | gzip > $HOME/project_data/downy/benchmarking/hifiasm/p_effusa.fasta.gz

total_runtime=$(echo "$EPOCHREALTIME - $total_start" | bc -l)
echo "Pipeline completed: $(date)"
echo "Total runtime: $total_runtime seconds"