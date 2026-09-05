#!/bin/bash

# Purpose : Run the targetasm pipeline on P. cubensis SC1982.
# Inputs  : ${PROJECT_DATA}/results/read-filtering-screening/reads/focal/Quesada_SQIIe_SC1982.fastq.gz; FCS-GX at
#           ${DB_ROOT}/fcs-gx; compleasm lineages at ${DB_ROOT}/compleasm
# Outputs : ${PROJECT_DATA}/results/assembly/SC1982/
# Runs on : login node - the pipeline submits its own SLURM jobs
# Usage   : bash workflow/02-assembly/assemble-SC1982.sh
set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

nextflow run ${TARGET_ASM_DIR}/main.nf \
    -profile "${NEXTFLOW_PROFILE:-slurm,$CONTAINER_RUNTIME}" \
    --reads "${PROJECT_DATA}/results/read-filtering-screening/reads/focal/Quesada_SQIIe_SC1982.fastq.gz" \
    --outdir "${PROJECT_DATA}/results/assembly/Quesada_SQIIe_SC1982" \
    --gx_db "${DB_ROOT}/fcs-gx/all" \
    --tax_id 4762 \
    --target_bases 5400000000 \
    --hifiasm_option '-l 2' \
    --rasusa_seed 2025 \
    --threads 32 \
    --quality_library "${DB_ROOT}/compleasm" \
    --quality_lineage stramenopiles \
    --keep_intermediates
