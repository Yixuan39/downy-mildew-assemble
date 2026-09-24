#!/bin/bash

# Purpose : Run nf-core/rnaseq 3.26.0 against the MSU1 assembly to get transcript-level evidence for the
#           predicted genes.
# Inputs  : config/samplesheet_MSU1.csv, config/custom.config, the MSU1 assembly + Helixer
#           GFF3
# Outputs : the nf-core/rnaseq outdir set inside the script
# Runs on : login node - Nextflow submits its own SLURM jobs; apptainer profile
# Usage   : bash run-nfcore-rnaseq-MSU1.sh

set -euo pipefail

export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export DB_ROOT="${DB_ROOT:-$HOME/db}"
SAMPLESHEET_DIR="$PROJECT_DATA/results/rnaseq-support/samplesheets"
mkdir -p "$SAMPLESHEET_DIR"
python3 prepare-samplesheet.py \
    config/samplesheet_MSU1.csv \
    "$SAMPLESHEET_DIR/MSU1.csv"

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input "$SAMPLESHEET_DIR/MSU1.csv" \
    --outdir "$PROJECT_DATA/results/rnaseq-support/Pcub_MSU1" \
    --gff "$PROJECT_DATA/results/repeatmask-gene-prediction/focal/helixer/Pseudoperonospora_cubensis_MSU1.gff" \
    --fasta "$PROJECT_DATA/results/assembly-qc/nuclear/Pseudoperonospora_cubensis_MSU1.fasta.gz" \
    --contaminant_screening 'kraken2_bracken' --kraken_db "$DB_ROOT/kraken2/PlusPFP" \
    --aligner star_salmon \
    --skip_biotype_qc true \
    --featurecounts_feature_type exon \
    --featurecounts_group_type gene_id \
    --min_mapped_reads 0 \
    -profile apptainer \
    -c config/custom.config
