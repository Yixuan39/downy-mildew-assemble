#!/usr/bin/env bash

# Purpose : Split the one SC1982 contig that carries an internal run of N (hard-masked
#           sequence) at its recorded coordinates, dropping only the N characters. The major
#           segment keeps the name Pcub-SC1982_002; the minor segment takes the next contig
#           number and goes at the end of the assembly. Run before this stage's QC and before
#           every downstream stage.
# Inputs  : ~/project_data/downy/results/assembly-qc/nuclear-presplit/Pseudoperonospora_cubensis_SC1982.fasta.gz
# Outputs : ~/project_data/downy/results/assembly-qc/nuclear/Pseudoperonospora_cubensis_SC1982.fasta.gz.
#           The pre-split FCS-GX output stays under nuclear-presplit/.
# Runs on : ncsu-brc login node, or the short partition; seconds. Needs seqkit.
# Usage   : bash split-contigs.sh
set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

cleaned="${PROJECT_DATA}/results/assembly-qc/nuclear"
archive="${PROJECT_DATA}/results/assembly-qc/nuclear-presplit"

contig="Pcub-SC1982_002"
gap_start=4523547                 # 1-based, inclusive: the all-N interval
gap_end=4531927
contig_end=4835754

# Keep the FCS-GX output. The gap coverage check needs the unsplit contig, and reading and
# writing the same file would truncate the input mid-stream.
assembly_in="${1:-$archive/Pseudoperonospora_cubensis_SC1982.fasta.gz}"
assembly_out="${2:-$cleaned/Pseudoperonospora_cubensis_SC1982.fasta.gz}"
[[ "$assembly_in" != "$assembly_out" ]] || { echo "Input and output must differ" >&2; exit 1; }
mkdir -p "$(dirname "$assembly_in")" "$(dirname "$assembly_out")"
[[ -s "$assembly_in" ]] || { echo "Missing stage-04 input: $assembly_in" >&2; exit 1; }
actual_length=$(seqkit grep -p "$contig" "$assembly_in" | seqkit fx2tab -n -i -l | cut -f2)
[[ "$actual_length" == "$contig_end" ]] || { echo "Expected unsplit $contig ($contig_end bp), found $actual_length" >&2; exit 1; }
trap 'rm -f "$assembly_out.tmp"' EXIT

# Refuse unless the interval really is all N - this is what stops a second run from cutting
# resolved sequence out of an already-split assembly.
n_pct=$(seqkit grep -p "$contig" "$assembly_in" |
    seqkit subseq -r "$gap_start:$gap_end" | seqkit fx2tab -n -B N | cut -f2)
[ "$n_pct" = "100.00" ] ||
    { echo "refusing: $contig $gap_start-$gap_end is '$n_pct'% N, expected 100.00" >&2; exit 1; }

# Append the minor segment using the first unused contig number after the true numeric max.
# Contig numbering is not necessarily contiguous with the total contig count (SC1982 has 474
# contigs but names running up to Pcub-SC1982_487, from earlier decontamination steps that
# dropped contigs without renumbering) - naively using n+1 can collide with an existing contig
# and produce a duplicate Sequence ID (caught by NCBI validation on 2026-09-05).
n=$(seqkit fx2tab -n -i "$assembly_in" | wc -l)
max_num=$(seqkit fx2tab -n -i "$assembly_in" | sed -E 's/.*_0*([0-9]+)$/\1/' | sort -n | tail -1)
minor=$(printf "Pcub-SC1982_%03d" $((max_num + 1)))
idx=$(seqkit fx2tab -n -i "$assembly_in" | grep -n -x "$contig" | cut -d: -f1)

{
    if (( idx > 1 )); then seqkit range -r "1:$((idx - 1))" "$assembly_in"; fi

    seqkit grep -p "$contig" "$assembly_in" |
        seqkit subseq -r "1:$((gap_start - 1))" |
        seqkit replace -p '^.*$' -r "$contig"

    if (( idx < n )); then seqkit range -r "$((idx + 1)):-1" "$assembly_in"; fi

    seqkit grep -p "$contig" "$assembly_in" |
        seqkit subseq -r "$((gap_end + 1)):$contig_end" |
        seqkit replace -p '^.*$' -r "$minor"
} | gzip -c > "$assembly_out.tmp"
# Validate before replacing the output, so a failed command cannot publish a partial assembly.
before=$(seqkit fx2tab -n -i -l "$assembly_in" | awk -F'\t' '{sum += $2} END {print sum}')
after=$(seqkit fx2tab -n -i -l "$assembly_out.tmp" | awk -F'\t' '{sum += $2} END {print sum}')
count=$(seqkit fx2tab -n -i "$assembly_out.tmp" | wc -l)
[[ "$count" -eq $((n + 1)) && "$after" -eq $((before - gap_end + gap_start - 1)) ]]
mv "$assembly_out.tmp" "$assembly_out"
seqkit stats -a "$assembly_in" "$assembly_out"
