#!/bin/bash
#SBATCH --job-name=benchmark_tea
#SBATCH -c 24
#SBATCH --mem=500G
#SBATCH --output=benchmark_tea_%j.out

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAMPLE="${SAMPLE:-p_effusa}"
source "${SCRIPT_DIR}/common.sh"

MSU1_TARGET_BASES_DEFAULT="${MSU1_TARGET_BASES_DEFAULT:-5400000000}"

if [[ -z "${METHOD:-}" ]]; then
    if [[ "${SAMPLE}" == "MSU1" || "${SAMPLE}" == "Quesada_SQIIe_MSU1" ]]; then
        if [[ -n "${TARGET_BASES}" ]]; then
            METHOD="tea_downsample"
        else
            METHOD="tea_no_downsample"
        fi
    elif [[ -n "${TARGET_BASES}" ]]; then
        METHOD="tea_downsample"
    else
        METHOD="tea"
    fi
fi

case "${METHOD}" in
    tea)
        if [[ "${SAMPLE}" == "MSU1" || "${SAMPLE}" == "Quesada_SQIIe_MSU1" ]]; then
            echo "METHOD=tea is for non-MSU1 TEA benchmarks. Use METHOD=tea_no_downsample for ${SAMPLE}." >&2
            exit 1
        fi
        if [[ -n "${TARGET_BASES}" ]]; then
            echo "METHOD=tea should not set TARGET_BASES." >&2
            exit 1
        fi
        ;;
    tea_downsample)
        if [[ "${SAMPLE}" != "MSU1" && "${SAMPLE}" != "Quesada_SQIIe_MSU1" ]]; then
            echo "METHOD=tea_downsample is only for MSU1. Got SAMPLE=${SAMPLE}." >&2
            exit 1
        fi
        TARGET_BASES="${TARGET_BASES:-${MSU1_TARGET_BASES_DEFAULT}}"
        ;;
    tea_no_downsample)
        if [[ "${SAMPLE}" != "MSU1" && "${SAMPLE}" != "Quesada_SQIIe_MSU1" ]]; then
            echo "METHOD=tea_no_downsample is only for MSU1. Use METHOD=tea for ${SAMPLE}." >&2
            exit 1
        fi
        if [[ -n "${TARGET_BASES}" ]]; then
            echo "METHOD=tea_no_downsample should not set TARGET_BASES." >&2
            exit 1
        fi
        ;;
    *)
        echo "TEA benchmark METHOD must be tea, tea_downsample, or tea_no_downsample. Got METHOD=${METHOD}." >&2
        exit 1
        ;;
esac

init_method "${METHOD}"

tea_args=(
    nextflow run "${TEA_MAIN}"
    -profile apptainer
    --reads "${READS}"
    --outdir "${OUTDIR}"
    --gx_db "${GX_DB}"
    --tax_id 4762
    --hifiasm_option "-l 2"
    --threads "${THREADS}"
    --rasusa_seed "${RASUSA_SEED}"
    --keep_intermediates
)

if [[ -n "${TARGET_BASES}" ]]; then
    tea_args+=(--target_bases "${TARGET_BASES}")
fi

start_pipeline "TEA"

if [[ -n "${TARGET_BASES}" ]]; then
    log "Target bases: ${TARGET_BASES}"
else
    log "Target bases: none"
fi

run_timed "TEA pipeline" "${tea_args[@]}"

link_final_fasta "${OUTDIR}/${READS_STEM}.fasta.gz"

finish_pipeline
