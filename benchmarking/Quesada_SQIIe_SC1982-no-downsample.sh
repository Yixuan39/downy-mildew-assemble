#!/bin/bash
#SBATCH -c 24
#SBATCH --mem=500G
#SBATCH --output=Phumuli-no-downsample_%j.out
set -euo pipefail

total_start=$EPOCHREALTIME
echo "TEA PIPELINE started: $(date)"
 
# Run TEA pipeline
start=$EPOCHREALTIME

nextflow run ${HOME}/software/TEA/main.nf \
    -profile apptainer \
    --reads "${HOME}/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_Phumuli.fastq.gz" \
    --outdir "${HOME}/project_data/downy/benchmarking/Phumuli_no-downsample" \
    --gx_db "${HOME}/project_data/downy/fcs-db" \
    --tax_id 4762 \
    --hifiasm_option '-l 2' \
    --threads 24 \
    --quality_library "${HOME}/project_data/downy/BUSCO_DB" \
    --quality_lineage stramenopiles \
    --keep_intermediates

runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "TEA pipeline: $runtime seconds"
 
total_runtime=$(echo "$EPOCHREALTIME - $total_start" | bc -l)
echo "Pipeline completed: $(date)"
echo "Total runtime: $total_runtime seconds"