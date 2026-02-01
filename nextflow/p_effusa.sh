#!/bin/bash
set -euo pipefail

nextflow run ${HOME}/software/TEA/main.nf \
    -profile slurm \
    --reads "${HOME}/project_data/downy/p_effusa/filtered/p_effusa.fastq.gz" \
    --outdir "${HOME}/project_data/downy/Assembly/p_effusa" \
    --gx_db "${HOME}/project_data/downy/fcs-db" \
    --tax_id 4762 \
    --hifiasm_option '-l 2' \
    --threads 32 \
    --quality_library "${HOME}/project_data/downy/BUSCO_DB" \
    --quality_lineage stramenopiles \
    --keep_intermediates
