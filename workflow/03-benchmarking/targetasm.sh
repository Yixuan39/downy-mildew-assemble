#!/bin/bash
#SBATCH --job-name=benchmark_targetasm
#SBATCH -c 32
#SBATCH --mem=512G
#SBATCH --output=benchmark_targetasm_%j.out

# Purpose : Benchmark arm 3: the targetasm pipeline itself, in three variants selected by METHOD (tea = no
#           downsampling, tea_no_downsample / tea_downsample for MSU1). NOTE: the METHOD values still read
#           'tea', the pipeline's former name; they are also the output directory names under benchmarking/
#           and the labels analysis/benchmark.Rmd matches on, so they are deliberately left unchanged.
# Inputs  : $SAMPLE reads under $PROJECT_DATA; targetasm at ${SOFTWARE_ROOT}/targetasm; FCS-GX at
#           ${DB_ROOT}/fcs-gx
# Outputs : $PROJECT_DATA/results/benchmarking/$SAMPLE/$METHOD/ incl. timing.tsv
# Runs on : SLURM, 32 cores / 512 GB, one large-memory node
# Usage   : sbatch --export=ALL,SAMPLE=MSU1,METHOD=tea_downsample workflow/03-benchmarking/targetasm.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

SAMPLE="${SAMPLE:-UA202013}"
THREADS="${SLURM_CPUS_PER_TASK:-32}"
TARGET_ASM_MAIN="${TARGET_ASM_MAIN:-$TARGET_ASM_DIR/main.nf}"
NEXTFLOW_PROFILE="${BENCHMARK_PROFILE:-$CONTAINER_RUNTIME}"
GX_DB="${GX_DB:-${DB_ROOT}/fcs-gx/all}"
RASUSA_SEED="${RASUSA_SEED:-2025}"
MSU1_TARGET_BASES="${MSU1_TARGET_BASES:-5400000000}"

case "${SAMPLE}" in
    UA202013)
        READS="${PROJECT_DATA}/results/read-filtering-screening/reads/UA202013/UA202013.fastq.gz"
        METHOD="${METHOD:-tea}"
        FINAL_NAME="UA202013.fasta.gz"
        ;;
    MSU1|Quesada_SQIIe_MSU1)
        SAMPLE="MSU1"
        READS="${PROJECT_DATA}/results/read-filtering-screening/reads/focal/Quesada_SQIIe_MSU1.fastq.gz"
        METHOD="${METHOD:-tea_no_downsample}"
        FINAL_NAME="Quesada_SQIIe_MSU1.fasta.gz"
        ;;
    *)
        echo "Unknown SAMPLE=${SAMPLE}. Use SAMPLE=UA202013 or SAMPLE=MSU1." >&2
        exit 1
        ;;
esac

case "${METHOD}" in
    tea)
        if [[ "${SAMPLE}" == "MSU1" ]]; then
            echo "Use METHOD=tea_no_downsample or METHOD=tea_downsample for MSU1." >&2
            exit 1
        fi
        TARGET_BASES=""
        ;;
    tea_no_downsample)
        if [[ "${SAMPLE}" != "MSU1" ]]; then
            echo "METHOD=tea_no_downsample is only for MSU1." >&2
            exit 1
        fi
        TARGET_BASES=""
        ;;
    tea_downsample)
        if [[ "${SAMPLE}" != "MSU1" ]]; then
            echo "METHOD=tea_downsample is only for MSU1." >&2
            exit 1
        fi
        TARGET_BASES="${TARGET_BASES:-${MSU1_TARGET_BASES}}"
        ;;
    *)
        echo "Unknown METHOD=${METHOD}. Use tea, tea_no_downsample, or tea_downsample." >&2
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
    echo "Expected final target-asm assembly was not created: ${FINAL_FASTA}" >&2
    exit 1
fi

seconds=$(( $(date +%s) - start ))
printf "target-asm\t%s\n" "${seconds}" >> "${TIMING}"
printf "Total\t%s\n" "${seconds}" >> "${TIMING}"

if [[ "${FINAL_NAME}" != "${SAMPLE}.fasta.gz" ]]; then
    ln -sfn "${FINAL_FASTA}" "${OUTDIR}/${SAMPLE}.fasta.gz"
fi

echo "Done: ${OUTDIR}/${SAMPLE}.fasta.gz"
