#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
DB_ROOT="${DB_ROOT:-$HOME/db}"

case "${1:-}" in
    MSU1) assembly=Pseudoperonospora_cubensis_MSU1; output=Pcub_MSU1 ;;
    SC1982) assembly=Pseudoperonospora_cubensis_SC1982; output=Pcub_SC1982 ;;
    OR502AA) assembly=Pseudoperonospora_humuli_OR502AA; output=Phum_OR502AA ;;
    *) echo "Usage: $0 MSU1|SC1982|OR502AA" >&2; exit 2 ;;
esac

samplesheets="$PROJECT_DATA/results/rnaseq-support/samplesheets"
mkdir -p "$samplesheets"
python3 "$SCRIPT_DIR/prepare-samplesheet.py" \
    "$SCRIPT_DIR/config/samplesheet_$1.csv" "$samplesheets/$1.csv"

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input "$samplesheets/$1.csv" \
    --outdir "$PROJECT_DATA/results/rnaseq-support/$output" \
    --gff "$PROJECT_DATA/results/repeatmask-gene-prediction/focal/helixer/$assembly.gff" \
    --fasta "$PROJECT_DATA/results/assembly-qc/nuclear/$assembly.fasta.gz" \
    --contaminant_screening kraken2_bracken --kraken_db "$DB_ROOT/kraken2/PlusPFP" \
    --aligner star_salmon \
    --skip_biotype_qc true \
    --featurecounts_feature_type exon \
    --featurecounts_group_type gene_id \
    --min_mapped_reads 0 \
    -profile apptainer \
    -c "$SCRIPT_DIR/config/custom.config"
