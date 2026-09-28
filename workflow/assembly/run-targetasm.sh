#!/usr/bin/env bash

set -euo pipefail

PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
DB_ROOT="${DB_ROOT:-$HOME/db}"
SOFTWARE_ROOT="${SOFTWARE_ROOT:-$HOME/software}"
CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-$(command -v apptainer >/dev/null 2>&1 && echo apptainer || echo singularity)}"

case "${1:-}" in
    MSU1) run=Quesada_SQIIe_MSU1; target_bases=5400000000 ;;
    SC1982) run=Quesada_SQIIe_SC1982; target_bases=5400000000 ;;
    OR502AA) run=Quesada_SQIIe_Phumuli; target_bases=4800000000 ;;
    UA202013) run=UA202013; target_bases= ;;
    *) echo "Usage: $0 MSU1|SC1982|OR502AA|UA202013" >&2; exit 2 ;;
esac

if [[ "$run" == UA202013 ]]; then
    reads="$PROJECT_DATA/results/read-filtering-screening/reads/UA202013/p_effusa.fastq.gz"
else
    reads="$PROJECT_DATA/results/read-filtering-screening/reads/focal/$run.fastq.gz"
fi

args=()
if [[ -n "$target_bases" ]]; then
    args=(--target_bases "$target_bases" --rasusa_seed 2025)
fi
nextflow run "${TARGET_ASM_DIR:-$SOFTWARE_ROOT/targetasm}/main.nf" \
    -profile "${NEXTFLOW_PROFILE:-slurm,$CONTAINER_RUNTIME}" \
    --reads "$reads" \
    --outdir "$PROJECT_DATA/results/assembly/$run" \
    --gx_db "$DB_ROOT/fcs-gx/all" \
    --tax_id 4762 \
    "${args[@]}" \
    --hifiasm_option '-l 2' \
    --threads 32 \
    --quality_library "$DB_ROOT/compleasm" \
    --quality_lineage stramenopiles \
    --keep_intermediates
