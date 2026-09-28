#!/bin/bash

set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Set BENCHMARK_NODE to the same high-memory node for all arms; jobs run serially.
: "${BENCHMARK_NODE:?Set BENCHMARK_NODE to a high-memory SLURM node}"
dependency=()
for sample in UA202013 MSU1; do
    for method in hifiasm hifiasm_blastn targetasm_no_downsample targetasm_downsample; do
        [[ "$sample" == MSU1 || "$method" != targetasm_downsample ]] || continue
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
