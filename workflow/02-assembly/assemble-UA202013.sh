#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Run the targetasm pipeline on the public P. effusa reads, the external dataset used to show the
#           method generalises.
# Inputs  : $HOME/project_data/downy/UA202013/filtered/UA202013.fastq.gz; FCS-GX at $HOME/db/fcs-gx;
#           compleasm lineages at $HOME/db/compleasm
# Outputs : $HOME/project_data/downy/Assembly/UA202013/
# Runs on : NCSU BRC login node - the pipeline submits its own SLURM jobs
# Usage   : bash workflow/02-assembly/assemble-UA202013.sh
# ----------------------------------------------------------------------------------------
set -euo pipefail

nextflow run ${HOME}/software/targetasm/main.nf \
    -profile slurm \
    --reads "${HOME}/project_data/downy/UA202013/filtered/UA202013.fastq.gz" \
    --outdir "${HOME}/project_data/downy/Assembly/UA202013" \
    --gx_db "${HOME}/db/fcs-gx" \
    --tax_id 4762 \
    --hifiasm_option '-l 2' \
    --threads 32 \
    --quality_library "${HOME}/db/compleasm" \
    --quality_lineage stramenopiles \
    --keep_intermediates
