#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Run the targetasm pipeline on P. cubensis MSU1: HiFi reads in, decontaminated primary assembly
#           out.
# Inputs  : $HOME/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_MSU1.fastq.gz; FCS-GX at
#           $HOME/db/fcs-gx; compleasm lineages at $HOME/db/compleasm
# Outputs : $HOME/project_data/downy/Assembly/MSU1/ (see targetasm docs for the layout)
# Runs on : login node - the pipeline submits its own SLURM jobs, so do not sbatch this script
# Usage   : bash workflow/02-assembly/assemble-MSU1.sh
# ----------------------------------------------------------------------------------------
set -euo pipefail

nextflow run ${HOME}/software/targetasm/main.nf \
    -profile slurm \
    --reads "${HOME}/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_MSU1.fastq.gz" \
    --outdir "${HOME}/project_data/downy/Assembly/Quesada_SQIIe_MSU1" \
    --gx_db "${HOME}/db/fcs-gx" \
    --tax_id 4762 \
    --target_bases 5400000000 \
    --hifiasm_option '-l 2' \
    --rasusa_seed 2025 \
    --threads 32 \
    --quality_library "${HOME}/db/compleasm" \
    --quality_lineage stramenopiles \
    --keep_intermediates
