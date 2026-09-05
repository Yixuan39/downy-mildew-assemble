#!/usr/bin/env bash

# Purpose : Split the one SC1982 contig that carries an internal run of N (hard-masked
#           sequence) at its recorded coordinates, dropping only the N characters. The major
#           segment keeps the name Pcub-SC1982_002; the minor segment is named
#           Pcub-SC1982_488 - the first unused contig number. SC1982 has 474 contigs but names
#           running up to _487 (earlier decontamination steps dropped contigs without
#           renumbering), so the naive next number, _475, collides with an existing contig and
#           was rejected by NCBI as a duplicate Sequence ID.
# Inputs  : ${PROJECT_DATA}/results/assembly-qc/nuclear-presplit/Pseudoperonospora_cubensis_SC1982.fasta.gz
# Outputs : ${PROJECT_DATA}/results/assembly-qc/nuclear/Pseudoperonospora_cubensis_SC1982.fasta.gz
# Runs on : ncsu-brc login node, or the short partition; seconds. Needs seqkit.
# Usage   : bash split-contigs.sh
set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

assembly_in="${1:-$PROJECT_DATA/results/assembly-qc/nuclear-presplit/Pseudoperonospora_cubensis_SC1982.fasta.gz}"
assembly_out="${2:-$PROJECT_DATA/results/assembly-qc/nuclear/Pseudoperonospora_cubensis_SC1982.fasta.gz}"

# Position of Pcub-SC1982_002 in the input, so its (shortened) replacement stays in place -
# everything else keeps its original order, and only the new fragment goes at the end.
idx=$(seqkit fx2tab -n -i "$assembly_in" | grep -nx "Pcub-SC1982_002" | cut -d: -f1)

{
  seqkit range -r "1:$((idx - 1))" "$assembly_in"

  seqkit grep -p "Pcub-SC1982_002" "$assembly_in" |
    seqkit subseq -r 1:4523546 |
    seqkit replace -p '^.*$' -r "Pcub-SC1982_002"

  seqkit range -r "$((idx + 1)):-1" "$assembly_in"

  seqkit grep -p "Pcub-SC1982_002" "$assembly_in" |
    seqkit subseq -r 4531928:4835754 |
    seqkit replace -p '^.*$' -r "Pcub-SC1982_488"
} | gzip -c > "$assembly_out"
