#!/usr/bin/env bash

# Purpose : Split the SC1982 N-gap contig and remove the two contigs flagged by NCBI.
# Inputs  : ${PROJECT_DATA}/results/assembly-qc/nuclear-presplit/Pseudoperonospora_cubensis_SC1982.fasta.gz
# Outputs : ${PROJECT_DATA}/results/assembly-qc/nuclear/Pseudoperonospora_cubensis_SC1982.fasta.gz
# Runs on : ncsu-brc login node, or the short partition; seconds. Needs seqkit.
# Usage   : bash ncbi-screen.sh
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/paths.sh"

assembly_in="${1:-$PROJECT_DATA/results/assembly-qc/nuclear-presplit/Pseudoperonospora_cubensis_SC1982.fasta.gz}"
assembly_out="${2:-$PROJECT_DATA/results/assembly-qc/nuclear/Pseudoperonospora_cubensis_SC1982.fasta.gz}"

# NCBI's SUB16446400 contamination screen excluded these two whole contigs (CFB group
# bacteria); we accepted the call and drop them here too, so the local final assembly
# matches what is deposited.
drop_contigs=(Pcub-SC1982_037 Pcub-SC1982_071)

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
} | seqkit grep -v -p "${drop_contigs[0]}" -p "${drop_contigs[1]}" | gzip -c > "$assembly_out"
