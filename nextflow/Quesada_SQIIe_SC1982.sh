#!/bin/bash
set -euo pipefail

nextflow run ${HOME}/software/TEA/main.nf \
    -profile slurm \
    --reads "${HOME}/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_SC1982.fastq.gz" \
    --outdir "${HOME}/project_data/downy/Assembly/Quesada_SQIIe_SC1982" \
    --gx_db "${HOME}/project_data/downy/fcs-db" \
    --tax_id 4762 \
    --target_bases 5400000000 \
    --hifiasm_option '-l 2' \
    --rasusa_seed 2025 \
    --threads 32 \
    --quality_library "${HOME}/project_data/downy/BUSCO_DB" \
    --quality_lineage stramenopiles \
    --keep_intermediates
