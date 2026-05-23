#!/bin/bash
#SBATCH --job-name=benchmark_hifiasm_blastn
#SBATCH -c 24
#SBATCH --mem=0
#SBATCH --output=benchmark_hifiasm_blastn_%j.out

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SH="${COMMON_SH:-}"
if [[ -z "${COMMON_SH}" ]]; then
    for candidate in \
        "${SCRIPT_DIR}/common.sh" \
        "${SLURM_SUBMIT_DIR:-}/benchmarking/common.sh" \
        "${SLURM_SUBMIT_DIR:-}/common.sh" \
        "$(pwd)/benchmarking/common.sh" \
        "$(pwd)/common.sh"; do
        if [[ -f "${candidate}" ]]; then
            COMMON_SH="${candidate}"
            break
        fi
    done
fi
if [[ -z "${COMMON_SH}" || ! -f "${COMMON_SH}" ]]; then
    echo "Could not find common.sh. Submit from the repo root or set COMMON_SH=/path/to/benchmarking/common.sh." >&2
    exit 1
fi
source "${COMMON_SH}"

init_method "hifiasm_blastn"
start_pipeline "HIFIASM-BLASTN"

run_timed "Assembly" \
    run_hifiasm "${READS}" "${OUTDIR}/${SAMPLE}"

run_timed "GFA to FASTA" \
    gfa_to_fasta "${OUTDIR}/${SAMPLE}.p_ctg.gfa" "${OUTDIR}/${SAMPLE}_contigs.fasta"

run_timed "Contig BLASTN" \
    run_blastn "${OUTDIR}/${SAMPLE}_contigs.fasta" "${OUTDIR}/contigs_blast.tsv"

run_timed "Filter oomycete contig ids" \
    filter_blast_taxids "${OUTDIR}/contigs_blast.tsv" "${OUTDIR}/oomycete_contigs.txt"
log "Oomycete contig ids: $(wc -l < "${OUTDIR}/oomycete_contigs.txt")"

run_timed "Write filtered assembly" \
    grep_fasta_ids_gz \
        "${OUTDIR}/oomycete_contigs.txt" \
        "${OUTDIR}/${SAMPLE}_contigs.fasta" \
        "${OUTDIR}/${SAMPLE}.fasta.gz"

finish_pipeline
