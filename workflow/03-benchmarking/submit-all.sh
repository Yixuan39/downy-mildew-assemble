#!/bin/bash

# Purpose : Submit all seven benchmark runs (3 arms x 2 isolates, plus the two MSU1 downsampling variants)
#           to the same node so the wall-time comparison is fair.
# Inputs  : the three arm scripts in this directory
# Outputs : seven queued SLURM jobs
# Runs on : login node
# Usage   : bash workflow/03-benchmarking/submit-all.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

# Set BENCHMARK_NODE to the same high-memory node for all arms; jobs run serially.
: "${BENCHMARK_NODE:?Set BENCHMARK_NODE to a high-memory SLURM node}"
SCRIPT_DIR="$REPO_ROOT/workflow/03-benchmarking"
dependency=()
for sample in UA202013 MSU1; do
    for method in hifiasm hifiasm_blastn tea_no_downsample tea_downsample; do
        if [[ "$sample" == UA202013 ]]; then
            [[ "$method" != tea_downsample ]] || continue
            [[ "$method" != tea_no_downsample ]] || method=tea
        fi
        case "$method" in
            hifiasm) script=hifiasm.sh ;;
            hifiasm_blastn) script=hifiasm-blastn.sh ;;
            *) script=targetasm.sh ;;
        esac
        job=$(sbatch --parsable --exclusive --mem=512G \
            -p "${BENCHMARK_PARTITION:-bigmem}" -w "$BENCHMARK_NODE" \
            "${dependency[@]}" --export="ALL,SAMPLE=$sample,METHOD=$method" "$SCRIPT_DIR/$script")
        job=${job%%;*}
        echo "$sample $method: $job"
        dependency=(--dependency="afterok:$job")
    done
done
