#!/bin/bash

# Purpose : Run nf-core/rnaseq 3.26.0 against the MSU1 assembly to get transcript-level evidence for the
#           predicted genes.
# Inputs  : workflow/08-rnaseq-support/config/samplesheet_MSU1.csv, workflow/08-rnaseq-support/config/custom.config, the MSU1 assembly + Helixer
#           GFF3
# Outputs : the nf-core/rnaseq outdir set inside the script
# Runs on : login node - Nextflow submits its own SLURM jobs; apptainer profile
# Usage   : bash workflow/08-rnaseq-support/run-nfcore-rnaseq-MSU1.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

SAMPLESHEET_DIR="$PROJECT_DATA/results/rnaseq-support/samplesheets"
mkdir -p "$SAMPLESHEET_DIR"
python3 "$REPO_ROOT/workflow/08-rnaseq-support/prepare-samplesheet.py" \
    "$REPO_ROOT/workflow/08-rnaseq-support/config/samplesheet_MSU1.csv" \
    "$SAMPLESHEET_DIR/MSU1.csv"

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input "$SAMPLESHEET_DIR/MSU1.csv" \
    --outdir "${PROJECT_DATA}/results/rnaseq-support/Pcub_MSU1" \
    --gff "${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer/Pseudoperonospora_cubensis_MSU1.gff" \
    --fasta "${PROJECT_DATA}/results/assembly-qc/nuclear/Pseudoperonospora_cubensis_MSU1.fasta.gz" \
    --contaminant_screening 'kraken2_bracken' --kraken_db "${DB_ROOT}/kraken2/PlusPFP" \
    --aligner star_salmon \
    --skip_biotype_qc true \
    --featurecounts_feature_type exon \
    --featurecounts_group_type gene_id \
    --min_mapped_reads 0 \
    -profile "${RNASEQ_PROFILE:-$CONTAINER_RUNTIME}" \
    -c "$REPO_ROOT/workflow/08-rnaseq-support/config/custom.config"
