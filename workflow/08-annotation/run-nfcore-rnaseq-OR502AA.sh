#!/bin/bash

# Purpose : Run nf-core/rnaseq 3.26.0 against the OR502AA assembly.
# Inputs  : config/samplesheet_OR502AA.csv, config/custom.config, the OR502AA assembly +
#           Helixer GFF3
# Outputs : the nf-core/rnaseq outdir set inside the script
# Runs on : login node - Nextflow submits its own SLURM jobs; apptainer profile
# Usage   : bash run-nfcore-rnaseq-OR502AA.sh

set -euo pipefail

export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export DB_ROOT="${DB_ROOT:-$HOME/db}"
SAMPLESHEET_DIR="$PROJECT_DATA/results/rnaseq-support/samplesheets"
mkdir -p "$SAMPLESHEET_DIR"
python3 prepare-samplesheet.py \
    config/samplesheet_OR502AA.csv \
    "$SAMPLESHEET_DIR/OR502AA.csv"

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input "$SAMPLESHEET_DIR/OR502AA.csv" \
    --outdir "$PROJECT_DATA/results/rnaseq-support/Phum_OR502AA" \
    --gff "$PROJECT_DATA/results/repeatmask-gene-prediction/focal/helixer/Pseudoperonospora_humuli_OR502AA.gff" \
    --fasta "$PROJECT_DATA/results/assembly-qc/nuclear/Pseudoperonospora_humuli_OR502AA.fasta.gz" \
    --contaminant_screening 'kraken2_bracken' --kraken_db "$DB_ROOT/kraken2/PlusPFP" \
    --aligner star_salmon \
    --skip_biotype_qc true \
    --featurecounts_feature_type exon \
    --featurecounts_group_type gene_id \
    --min_mapped_reads 0 \
    -profile apptainer \
    -c config/custom.config
