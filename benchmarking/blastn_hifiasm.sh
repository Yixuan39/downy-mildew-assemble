#!/bin/bash
#SBATCH --job-name=benchmark_blastn_hifiasm
#SBATCH -c 24
#SBATCH --mem=0
#SBATCH --output=benchmark_blastn_hifiasm_%j.out

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

init_method "blastn_hifiasm"
require_long_read_blast_approval
start_pipeline "BLASTN-HIFIASM"

run_timed "FASTQ to FASTA" \
    seqkit fq2fa \
        --threads "${THREADS}" \
        --out-file "${OUTDIR}/${SAMPLE}_reads.fasta" \
        "${READS}"

run_timed "Read BLASTN" \
    run_blastn "${OUTDIR}/${SAMPLE}_reads.fasta" "${OUTDIR}/reads_blast.tsv"

run_timed "Filter oomycete read ids" \
    filter_blast_taxids "${OUTDIR}/reads_blast.tsv" "${OUTDIR}/oomycete_reads.txt"
log "Oomycete read ids: $(wc -l < "${OUTDIR}/oomycete_reads.txt")"

run_timed "Write filtered reads" \
    seqkit grep \
        -f "${OUTDIR}/oomycete_reads.txt" \
        "${READS}" \
        --threads "${THREADS}" \
        -o "${OUTDIR}/${SAMPLE}_oomycete_reads.fastq.gz"

run_timed "Assembly" \
    run_hifiasm "${OUTDIR}/${SAMPLE}_oomycete_reads.fastq.gz" "${OUTDIR}/${SAMPLE}"

run_timed "GFA to FASTA" \
    gfa_to_fasta_gz "${OUTDIR}/${SAMPLE}.p_ctg.gfa" "${OUTDIR}/${SAMPLE}.fasta.gz"

finish_pipeline
