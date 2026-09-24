#!/bin/bash

# Purpose : Run nf-core/rnaseq 3.26.0 against the SC1982 assembly.
# Inputs  : config/samplesheet_SC1982.csv, config/custom.config, the SC1982 assembly + Helixer
#           GFF3
# Outputs : the nf-core/rnaseq outdir set inside the script
# Runs on : login node - Nextflow submits its own SLURM jobs; apptainer profile
# Usage   : bash run-nfcore-rnaseq-SC1982.sh

set -euo pipefail

export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export DB_ROOT="${DB_ROOT:-$HOME/db}"
SAMPLESHEET_DIR="$PROJECT_DATA/results/rnaseq-support/samplesheets"
mkdir -p "$SAMPLESHEET_DIR"
python3 prepare-samplesheet.py \
    config/samplesheet_SC1982.csv \
    "$SAMPLESHEET_DIR/SC1982.csv"

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input "$SAMPLESHEET_DIR/SC1982.csv" \
    --outdir "$PROJECT_DATA/results/rnaseq-support/Pcub_SC1982" \
    --gff "$PROJECT_DATA/results/repeatmask-gene-prediction/focal/helixer/Pseudoperonospora_cubensis_SC1982.gff" \
    --fasta "$PROJECT_DATA/results/assembly-qc/nuclear/Pseudoperonospora_cubensis_SC1982.fasta.gz" \
    --contaminant_screening 'kraken2_bracken' --kraken_db "$DB_ROOT/kraken2/PlusPFP" \
    --aligner star_salmon \
    --skip_biotype_qc true \
    --featurecounts_feature_type exon \
    --featurecounts_group_type gene_id \
    --min_mapped_reads 0 \
    -profile apptainer \
    -c config/custom.config
