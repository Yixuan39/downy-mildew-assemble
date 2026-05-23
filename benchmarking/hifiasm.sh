#!/bin/bash
#SBATCH --job-name=benchmark_hifiasm
#SBATCH -c 24
#SBATCH --mem=0
#SBATCH --output=benchmark_hifiasm_%j.out

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

init_method "hifiasm"
start_pipeline "HIFIASM"

run_timed "Assembly" \
    run_hifiasm "${READS}" "${OUTDIR}/${SAMPLE}"

run_timed "GFA to FASTA" \
    gfa_to_fasta_gz "${OUTDIR}/${SAMPLE}.p_ctg.gfa" "${OUTDIR}/${SAMPLE}.fasta.gz"

finish_pipeline
