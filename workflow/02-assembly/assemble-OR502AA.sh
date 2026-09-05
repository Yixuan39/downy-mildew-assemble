#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Run the targetasm pipeline on P. humuli OR502AA.
# Inputs  : $HOME/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_Phumuli.fastq.gz; FCS-GX at
#           $HOME/db/fcs-gx; compleasm lineages at $HOME/db/compleasm
# Outputs : $HOME/project_data/downy/Assembly/OR502AA/
# Runs on : NCSU BRC login node - the pipeline submits its own SLURM jobs
# Usage   : bash workflow/02-assembly/assemble-OR502AA.sh
# ----------------------------------------------------------------------------------------
set -euo pipefail

nextflow run ${HOME}/software/targetasm/main.nf \
    -profile slurm \
    --reads "${HOME}/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_Phumuli.fastq.gz" \
    --outdir "${HOME}/project_data/downy/Assembly/Quesada_SQIIe_Phumuli" \
    --gx_db "${HOME}/db/fcs-gx" \
    --tax_id 4762 \
    --target_bases 4800000000 \
    --hifiasm_option '-l 2' \
    --rasusa_seed 2025 \
    --threads 32 \
    --quality_library "${HOME}/db/compleasm" \
    --quality_lineage stramenopiles \
    --keep_intermediates
