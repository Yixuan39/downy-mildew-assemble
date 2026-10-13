#!/bin/bash

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
GFFREAD_BIN="${GFFREAD_BIN:-$HOME/miniforge3/envs/downy/bin/gffread}"

GENOME_DIR=${PROJECT_DATA}/results/assembly-qc/nuclear
RESULT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Spliced transcripts and CDS come from the unmasked assembly, so they carry no masked
# bases; the proteins (helixer-contigs.sh) were translated from the hard-masked assembly.
for gff in "$RESULT_DIR"/*.gff; do
  BASENAME=$(basename "$gff" .gff)
  gzip -dc "$GENOME_DIR/$BASENAME.fasta.gz" > "$TMP_DIR/$BASENAME.fasta"
  "$GFFREAD_BIN" "$gff" -g "$TMP_DIR/$BASENAME.fasta" \
    -w "$RESULT_DIR/$BASENAME.transcripts.fna" \
    -x "$RESULT_DIR/$BASENAME.cds.fna"
done
