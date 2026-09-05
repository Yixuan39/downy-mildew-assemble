#!/bin/bash
#SBATCH --job-name=benchmark_hifiasm
#SBATCH -c 32
#SBATCH --mem=512G
#SBATCH --output=benchmark_hifiasm_%j.out

# Purpose : Benchmark arm 1: hifiasm on the raw filtered reads, with no contamination handling. Records wall
#           time to timing.tsv.
# Inputs  : $SAMPLE reads under $PROJECT_DATA (MSU1 or UA202013)
# Outputs : $PROJECT_DATA/results/benchmarking/$SAMPLE/hifiasm/ incl. timing.tsv
# Runs on : SLURM, 32 cores, all three arms on one large-memory node
# Usage   : sbatch --export=ALL,SAMPLE=MSU1 workflow/03-benchmarking/hifiasm.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

SAMPLE="${SAMPLE:-UA202013}"
THREADS="${SLURM_CPUS_PER_TASK:-32}"

case "${SAMPLE}" in
    UA202013)
        READS="${PROJECT_DATA}/results/read-filtering-screening/reads/UA202013/UA202013.fastq.gz"
        ;;
    MSU1|Quesada_SQIIe_MSU1)
        SAMPLE="MSU1"
        READS="${PROJECT_DATA}/results/read-filtering-screening/reads/focal/Quesada_SQIIe_MSU1.fastq.gz"
        ;;
    *)
        echo "Unknown SAMPLE=${SAMPLE}. Use SAMPLE=UA202013 or SAMPLE=MSU1." >&2
        exit 1
        ;;
esac

OUTDIR="${PROJECT_DATA}/results/benchmarking/${SAMPLE}/hifiasm"
TIMING="${OUTDIR}/timing.tsv"

mkdir -p "${OUTDIR}"
printf "step\tseconds\n" > "${TIMING}"

run_step() {
    local step="$1"
    shift
    local start end seconds

    echo "[$(date '+%F %T')] ${step}"
    start=$(date +%s)
    "$@"
    end=$(date +%s)
    seconds=$((end - start))
    printf "%s\t%s\n" "${step}" "${seconds}" >> "${TIMING}"
}

total_start=$(date +%s)

echo "Sample: ${SAMPLE}"
echo "Reads: ${READS}"
echo "Output: ${OUTDIR}"
echo "Threads: ${THREADS}"

run_step "assembly" \
    hifiasm \
        -t "${THREADS}" \
        -l 2 \
        --primary \
        -o "${OUTDIR}/${SAMPLE}" \
        "${READS}"

run_step "gfa_to_fasta" \
    bash -o pipefail -c 'gfatools gfa2fa "$1" | gzip > "$2"' \
        _ \
        "${OUTDIR}/${SAMPLE}.p_ctg.gfa" \
        "${OUTDIR}/${SAMPLE}.fasta.gz"

printf "Total\t%s\n" "$(( $(date +%s) - total_start ))" >> "${TIMING}"
echo "Done: ${OUTDIR}/${SAMPLE}.fasta.gz"
