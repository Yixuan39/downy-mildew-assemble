#!/bin/bash

set -euo pipefail

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${COMMON_DIR}/.." && pwd)"

SAMPLE="${SAMPLE:-p_effusa}"
THREADS="${THREADS:-${SLURM_CPUS_PER_TASK:-32}}"
PROJECT_DATA="${PROJECT_DATA:-${HOME}/project_data/downy}"
BENCH_ROOT="${BENCH_ROOT:-${PROJECT_DATA}/benchmarking/${SAMPLE}}"

case "${SAMPLE}" in
    p_effusa)
        DEFAULT_READS="${PROJECT_DATA}/p_effusa/filtered/p_effusa.fastq.gz"
        ;;
    MSU1|Quesada_SQIIe_MSU1)
        DEFAULT_READS="${PROJECT_DATA}/GSL_Data/fastq/filtered/Quesada_SQIIe_MSU1.fastq.gz"
        ;;
    *)
        DEFAULT_READS="${PROJECT_DATA}/${SAMPLE}/filtered/${SAMPLE}.fastq.gz"
        ;;
esac

READS="${READS:-${DEFAULT_READS}}"
READS_BASENAME="$(basename "${READS}")"
READS_STEM="${READS_BASENAME%.fastq.gz}"
READS_STEM="${READS_STEM%.fq.gz}"
READS_STEM="${READS_STEM%.fastq}"
READS_STEM="${READS_STEM%.fq}"
TEA_MAIN="${TEA_MAIN:-${HOME}/software/TEA/main.nf}"
GX_DB="${GX_DB:-${PROJECT_DATA}/fcs-db}"
BUSCO_DB="${BUSCO_DB:-${PROJECT_DATA}/BUSCO_DB}"
TAXIDS_FILE="${TAXIDS_FILE:-${REPO_ROOT}/data/oomycete_taxids.txt}"
BLAST_DB="${BLAST_DB:-nt}"
BLAST_OUTFMT="${BLAST_OUTFMT:-6 qseqid sseqid pident length qlen slen evalue staxids}"
BLAST_EVALUE="${BLAST_EVALUE:-1e-10}"
BLAST_PIDENT="${BLAST_PIDENT:-95}"
TARGET_BASES="${TARGET_BASES:-}"
RASUSA_SEED="${RASUSA_SEED:-2025}"
HIFIASM_OPTIONS=(${HIFIASM_OPTIONS:- -l 2 --primary})

log() {
    echo "[$(date '+%F %T')] $*"
}

now_seconds() {
    if [[ -n "${EPOCHREALTIME:-}" ]]; then
        echo "${EPOCHREALTIME}"
    else
        date +%s
    fi
}

elapsed() {
    echo "$(now_seconds) - $1" | bc -l
}

init_method() {
    METHOD="$1"
    OUTDIR="${BENCH_ROOT}/${METHOD}"
    TIMING_FILE="${OUTDIR}/timing.tsv"
    mkdir -p "${OUTDIR}"
    printf "step\tseconds\n" > "${TIMING_FILE}"

    log "Sample: ${SAMPLE}"
    log "Method: ${METHOD}"
    log "Reads: ${READS}"
    log "Output: ${OUTDIR}"
    log "Threads: ${THREADS}"
}

start_pipeline() {
    PIPELINE_NAME="$1"
    total_start=$(now_seconds)
    log "${PIPELINE_NAME} pipeline started"
}

finish_pipeline() {
    local total_runtime
    total_runtime=$(elapsed "${total_start}")
    log "Pipeline completed"
    log "Total runtime: ${total_runtime} seconds"
    printf "Total\t%s\n" "${total_runtime}" >> "${TIMING_FILE}"
}

run_timed() {
    local label="$1"
    shift
    local start
    local seconds
    start=$(now_seconds)
    "$@"
    seconds=$(elapsed "${start}")
    log "${label}: ${seconds} seconds"
    printf "%s\t%s\n" "${label}" "${seconds}" >> "${TIMING_FILE}"
}

run_hifiasm() {
    local reads="$1"
    local prefix="$2"

    hifiasm \
        -t "${THREADS}" \
        "${HIFIASM_OPTIONS[@]}" \
        -o "${prefix}" \
        "${reads}"
}

run_blastn() {
    local query="$1"
    local out="$2"

    blastn \
        -query "${query}" \
        -db "${BLAST_DB}" \
        -outfmt "${BLAST_OUTFMT}" \
        -max_target_seqs 1 \
        -max_hsps 1 \
        -evalue "${BLAST_EVALUE}" \
        -perc_identity "${BLAST_PIDENT}" \
        -num_threads "${THREADS}" \
        -out "${out}"
}

filter_blast_taxids() {
    local blast_tsv="$1"
    local out_ids="$2"

    awk -F'\t' '
        NR == FNR {
            wanted[$1] = 1
            next
        }
        {
            n = split($8, taxids, /;/)
            for (i = 1; i <= n; i++) {
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", taxids[i])
                if (taxids[i] in wanted) {
                    print $1
                    next
                }
            }
        }
    ' "${TAXIDS_FILE}" "${blast_tsv}" | sort -u > "${out_ids}"
}

gfa_to_fasta() {
    local gfa="$1"
    local fasta="$2"

    gfatools gfa2fa "${gfa}" > "${fasta}"
}

gfa_to_fasta_gz() {
    local gfa="$1"
    local fasta_gz="$2"

    gfatools gfa2fa "${gfa}" | gzip > "${fasta_gz}"
}

grep_fasta_ids_gz() {
    local ids="$1"
    local fasta="$2"
    local fasta_gz="$3"

    seqkit grep -f "${ids}" "${fasta}" --threads "${THREADS}" | gzip > "${fasta_gz}"
}

link_final_fasta() {
    local source_fasta="$1"
    local target_fasta="${OUTDIR}/${SAMPLE}.fasta.gz"

    if [[ ! -s "${source_fasta}" ]]; then
        echo "Missing final FASTA: ${source_fasta}" >&2
        exit 1
    fi
    if [[ "${source_fasta}" != "${target_fasta}" ]]; then
        ln -sfn "${source_fasta}" "${target_fasta}"
    fi
}

require_long_read_blast_approval() {
    if [[ "${SAMPLE}" == "MSU1" || "${SAMPLE}" == "Quesada_SQIIe_MSU1" ]]; then
        if [[ "${ALLOW_LONG_READ_BLAST:-0}" != "1" ]]; then
            cat >&2 <<EOF
Refusing to run read-level BLASTN on ${SAMPLE}.

MSU1 has very high coverage, so blastn_hifiasm-style methods can spend many
days BLASTing raw reads before any assembly benchmark starts. Set
ALLOW_LONG_READ_BLAST=1 only if you intentionally want to run that expensive
raw-read BLAST benchmark.
EOF
            exit 1
        fi
    fi
}
