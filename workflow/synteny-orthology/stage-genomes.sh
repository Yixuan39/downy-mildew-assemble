#!/usr/bin/env bash
# Link the current Helixer GFF/protein pairs (4 focal + 11 comparison genomes) for GENESPACE.
set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"

helixer="$PROJECT_DATA/results/repeatmask-gene-prediction"
genomes="$PROJECT_DATA/results/synteny-orthology/genomes"
mkdir -p "$genomes"
for gff in "$helixer"/focal/helixer/*.gff "$helixer"/references/helixer/*/*.gff; do
    asm="$(basename "$gff" .gff)"
    faa="${gff%.gff}.faa"
    [[ -s "$faa" ]] || { echo "Missing $faa" >&2; exit 1; }
    mkdir -p "$genomes/$asm"
    ln -sfn "$gff" "$genomes/$asm/$asm.gff"
    ln -sfn "$faa" "$genomes/$asm/$asm.faa"
done
n="$(find "$genomes" -mindepth 1 -maxdepth 1 -type d | wc -l)"
[[ "$n" -eq 15 ]] || { echo "Expected 15 genomes, found $n" >&2; exit 1; }
