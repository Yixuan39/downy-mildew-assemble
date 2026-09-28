#!/bin/bash
#SBATCH --job-name=benchmark_targetasm
#SBATCH -c 32
#SBATCH --mem=512G
#SBATCH --output=benchmark_targetasm_%j.out

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export DB_ROOT="${DB_ROOT:-$HOME/db}"
export TARGET_ASM_DIR="${TARGET_ASM_DIR:-$HOME/software/targetasm}"
export CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-$(command -v apptainer >/dev/null 2>&1 && echo apptainer || echo singularity)}"

SAMPLE="${SAMPLE:-UA202013}"
THREADS="$SLURM_CPUS_PER_TASK"
TARGET_ASM_MAIN="${TARGET_ASM_MAIN:-$TARGET_ASM_DIR/main.nf}"
NEXTFLOW_PROFILE="${BENCHMARK_PROFILE:-$CONTAINER_RUNTIME}"
GX_DB="${GX_DB:-${DB_ROOT}/fcs-gx/all}"
RASUSA_SEED="${RASUSA_SEED:-2025}"
MSU1_TARGET_BASES="${MSU1_TARGET_BASES:-5400000000}"

case "${SAMPLE}" in
    UA202013)
        READS="${PROJECT_DATA}/results/read-filtering-screening/reads/UA202013/UA202013.fastq.gz"
        FINAL_NAME="UA202013.fasta.gz"
        ;;
    MSU1|Quesada_SQIIe_MSU1)
        SAMPLE="MSU1"
        READS="${PROJECT_DATA}/results/read-filtering-screening/reads/focal/Quesada_SQIIe_MSU1.fastq.gz"
        FINAL_NAME="Quesada_SQIIe_MSU1.fasta.gz"
        ;;
    *)
        echo "Unknown SAMPLE=${SAMPLE}. Use SAMPLE=UA202013 or SAMPLE=MSU1." >&2
        exit 1
        ;;
esac

METHOD="${METHOD:-targetasm_no_downsample}"
case "${METHOD}" in
    targetasm_no_downsample)
        TARGET_BASES=""
        ;;
    targetasm_downsample)
        if [[ "${SAMPLE}" != "MSU1" ]]; then
            echo "METHOD=targetasm_downsample is only for MSU1." >&2
            exit 1
        fi
        TARGET_BASES="${TARGET_BASES:-${MSU1_TARGET_BASES}}"
        ;;
    *)
        echo "Unknown METHOD=${METHOD}. Use targetasm_no_downsample or targetasm_downsample." >&2
        exit 1
        ;;
esac

OUTDIR="${PROJECT_DATA}/results/benchmarking/${SAMPLE}/${METHOD}"
TIMING="${OUTDIR}/timing.tsv"

mkdir -p "${OUTDIR}"
printf "step\tseconds\n" > "${TIMING}"

start=$(date +%s)

echo "Sample: ${SAMPLE}"
echo "Method: ${METHOD}"
echo "Reads: ${READS}"
echo "Output: ${OUTDIR}"
echo "Threads: ${THREADS}"
echo "Nextflow profile: ${NEXTFLOW_PROFILE}"
echo "Target bases: ${TARGET_BASES:-none}"

target_asm_args=(
    nextflow run "${TARGET_ASM_MAIN}"
    -profile "${NEXTFLOW_PROFILE}"
    --reads "${READS}"
    --outdir "${OUTDIR}"
    --gx_db "${GX_DB}"
    --tax_id 4762
    --hifiasm_option "-l 2"
    --threads "${THREADS}"
    --rasusa_seed "${RASUSA_SEED}"
)

if [[ -n "${TARGET_BASES}" ]]; then
    target_asm_args+=(--target_bases "${TARGET_BASES}")
fi

"${target_asm_args[@]}"

FINAL_FASTA="${OUTDIR}/${FINAL_NAME}"
if [[ ! -s "${FINAL_FASTA}" ]]; then
    echo "Expected final targetasm assembly was not created: ${FINAL_FASTA}" >&2
    exit 1
fi

seconds=$(( $(date +%s) - start ))
printf "targetasm\t%s\n" "${seconds}" >> "${TIMING}"
printf "Total\t%s\n" "${seconds}" >> "${TIMING}"

if [[ "${FINAL_NAME}" != "${SAMPLE}.fasta.gz" ]]; then
    ln -sfn "${FINAL_FASTA}" "${OUTDIR}/${SAMPLE}.fasta.gz"
fi

echo "Done: ${OUTDIR}/${SAMPLE}.fasta.gz"
