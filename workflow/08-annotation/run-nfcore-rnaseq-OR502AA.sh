#!/bin/bash

# Purpose : Run nf-core/rnaseq 3.26.0 against the OR502AA assembly.
# Inputs  : workflow/08-annotation/config/samplesheet_OR502AA.csv, workflow/08-annotation/config/custom.config, the OR502AA assembly +
#           Helixer GFF3
# Outputs : the nf-core/rnaseq outdir set inside the script
# Runs on : login node - Nextflow submits its own SLURM jobs; apptainer profile
# Usage   : bash workflow/08-annotation/run-nfcore-rnaseq-OR502AA.sh

set -euo pipefail

PD="$HOME/project_data/downy"
SAMPLESHEET_DIR="$PD/results/rnaseq-support/samplesheets"
mkdir -p "$SAMPLESHEET_DIR"
PROJECT_DATA="$PD" python3 workflow/08-annotation/prepare-samplesheet.py \
    workflow/08-annotation/config/samplesheet_OR502AA.csv \
    "$SAMPLESHEET_DIR/OR502AA.csv"

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input "$SAMPLESHEET_DIR/OR502AA.csv" \
    --outdir "$PD/results/rnaseq-support/Phum_OR502AA" \
    --gff "$PD/results/repeatmask-gene-prediction/focal/helixer/Pseudoperonospora_humuli_OR502AA.gff" \
    --fasta "$PD/results/assembly-qc/nuclear/Pseudoperonospora_humuli_OR502AA.fasta.gz" \
    --contaminant_screening 'kraken2_bracken' --kraken_db "$HOME/db/kraken2/PlusPFP" \
    --aligner star_salmon \
    --skip_biotype_qc true \
    --featurecounts_feature_type exon \
    --featurecounts_group_type gene_id \
    --min_mapped_reads 0 \
    -profile apptainer \
    -c workflow/08-annotation/config/custom.config
