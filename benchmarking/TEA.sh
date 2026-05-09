#!/bin/bash
#SBATCH -c 32
#SBATCH --mem=500G
#SBATCH --output=TEA_%j.out

total_start=$EPOCHREALTIME
echo "TEA PIPELINE started: $(date)"
 
# Run TEA pipeline
start=$EPOCHREALTIME
nextflow run ${HOME}/software/TEA/main.nf \
    -profile apptainer \
    --reads "${HOME}/project_data/downy/p_effusa/filtered/p_effusa.fastq.gz" \
    --outdir "${HOME}/project_data/downy/benchmarking/tea" \
    --gx_db "${HOME}/project_data/downy/fcs-db" \
    --tax_id 4762 \
    --hifiasm_option '-l 2' \
    --threads 32 \
    --keep_intermediates
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "TEA pipeline: $runtime seconds"
 
total_runtime=$(echo "$EPOCHREALTIME - $total_start" | bc -l)
echo "Pipeline completed: $(date)"
echo "Total runtime: $total_runtime seconds"
