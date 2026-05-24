#!/bin/bash
#SBATCH --job-name=benchmark_tea
#SBATCH -c 32
#SBATCH --mem=500G
#SBATCH --output=benchmark_tea_%j.out

set -euo pipefail

SAMPLE="${SAMPLE:-p_effusa}"
THREADS="${SLURM_CPUS_PER_TASK:-32}"
PROJECT_DATA="${PROJECT_DATA:-${HOME}/project_data/downy}"
TEA_MAIN="${TEA_MAIN:-${HOME}/software/TEA/main.nf}"
GX_DB="${GX_DB:-${PROJECT_DATA}/fcs-db}"
RASUSA_SEED="${RASUSA_SEED:-2025}"
MSU1_TARGET_BASES="${MSU1_TARGET_BASES:-5400000000}"

case "${SAMPLE}" in
    p_effusa)
        READS="${PROJECT_DATA}/p_effusa/filtered/p_effusa.fastq.gz"
        METHOD="${METHOD:-tea}"
        FINAL_NAME="p_effusa.fasta.gz"
        ;;
    MSU1|Quesada_SQIIe_MSU1)
        SAMPLE="MSU1"
        READS="${PROJECT_DATA}/GSL_Data/fastq/filtered/Quesada_SQIIe_MSU1.fastq.gz"
        METHOD="${METHOD:-tea_no_downsample}"
        FINAL_NAME="Quesada_SQIIe_MSU1.fasta.gz"
        ;;
    *)
        echo "Unknown SAMPLE=${SAMPLE}. Use SAMPLE=p_effusa or SAMPLE=MSU1." >&2
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

OUTDIR="${PROJECT_DATA}/benchmarking/${SAMPLE}/${METHOD}"
TIMING="${OUTDIR}/timing.tsv"

mkdir -p "${OUTDIR}"
printf "step\tseconds\n" > "${TIMING}"

start=$(date +%s)

echo "Sample: ${SAMPLE}"
echo "Method: ${METHOD}"
echo "Reads: ${READS}"
echo "Output: ${OUTDIR}"
echo "Threads: ${THREADS}"
echo "Target bases: ${TARGET_BASES:-none}"

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

"${tea_args[@]}"

seconds=$(( $(date +%s) - start ))
printf "TEA\t%s\n" "${seconds}" >> "${TIMING}"
printf "Total\t%s\n" "${seconds}" >> "${TIMING}"

if [[ "${FINAL_NAME}" != "${SAMPLE}.fasta.gz" ]]; then
    ln -sfn "${OUTDIR}/${FINAL_NAME}" "${OUTDIR}/${SAMPLE}.fasta.gz"
fi

echo "Done: ${OUTDIR}/${SAMPLE}.fasta.gz"
