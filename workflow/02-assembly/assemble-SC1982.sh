#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Run the targetasm pipeline on P. cubensis SC1982.
# Inputs  : $HOME/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_SC1982.fastq.gz; FCS-GX at
#           $HOME/db/fcs-gx; compleasm lineages at $HOME/db/compleasm
# Outputs : $HOME/project_data/downy/Assembly/SC1982/
# Runs on : NCSU BRC login node - the pipeline submits its own SLURM jobs
# Usage   : bash workflow/02-assembly/assemble-SC1982.sh
# ----------------------------------------------------------------------------------------
set -euo pipefail

nextflow run ${HOME}/software/targetasm/main.nf \
    -profile slurm \
    --reads "${HOME}/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_SC1982.fastq.gz" \
    --outdir "${HOME}/project_data/downy/Assembly/Quesada_SQIIe_SC1982" \
    --gx_db "${HOME}/db/fcs-gx" \
    --tax_id 4762 \
    --target_bases 5400000000 \
    --hifiasm_option '-l 2' \
    --rasusa_seed 2025 \
    --threads 32 \
    --quality_library "${HOME}/db/compleasm" \
    --quality_lineage stramenopiles \
    --keep_intermediates
