#!/bin/bash

# Purpose : Run the targetasm pipeline on the public P. effusa reads, the external dataset used to show the
#           method generalises.
# Inputs  : ${PROJECT_DATA}/results/read-filtering-screening/reads/UA202013/UA202013.fastq.gz; FCS-GX at ${DB_ROOT}/fcs-gx;
#           compleasm lineages at ${DB_ROOT}/compleasm
# Outputs : ${PROJECT_DATA}/results/assembly/UA202013/
# Runs on : login node - the pipeline submits its own SLURM jobs
# Usage   : bash workflow/02-assembly/assemble-UA202013.sh
set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export DB_ROOT="${DB_ROOT:-$HOME/db}"
export TARGET_ASM_DIR="${TARGET_ASM_DIR:-$HOME/software/targetasm}"
export CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-$(command -v apptainer >/dev/null 2>&1 && echo apptainer || echo singularity)}"

nextflow run ${TARGET_ASM_DIR}/main.nf \
    -profile "${NEXTFLOW_PROFILE:-slurm,$CONTAINER_RUNTIME}" \
    --reads "${PROJECT_DATA}/results/read-filtering-screening/reads/UA202013/UA202013.fastq.gz" \
    --outdir "${PROJECT_DATA}/results/assembly/UA202013" \
    --gx_db "${DB_ROOT}/fcs-gx/all" \
    --tax_id 4762 \
    --hifiasm_option '-l 2' \
    --threads 32 \
    --quality_library "${DB_ROOT}/compleasm" \
    --quality_lineage stramenopiles \
    --keep_intermediates
