#!/bin/bash
#SBATCH --job-name=benchmark_summary
#SBATCH -c 24
#SBATCH --mem=64G
#SBATCH --output=benchmark_summary_%j.out

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

if [[ -z "${METHODS:-}" ]]; then
    case "${SAMPLE}" in
        MSU1|Quesada_SQIIe_MSU1)
            METHODS="hifiasm hifiasm_blastn tea_no_downsample tea_downsample"
            ;;
        *)
            METHODS="hifiasm blastn_hifiasm hifiasm_blastn blastn_hifiasm_blastn tea"
            ;;
    esac
fi
METHODS=(${METHODS})
SUMMARY_DIR="${SUMMARY_DIR:-${BENCH_ROOT}/summary}"
QC_FASTA_DIR="${SUMMARY_DIR}/fasta"
QC_TABLE="${SUMMARY_DIR}/quality.tsv"
SUMMARY_TABLE="${SUMMARY_DIR}/benchmark_summary.tsv"
QUALITY_TABLE_NF="${QUALITY_TABLE_NF:-/Users/yixuanyang/Documents/Projects/TEA/run_fasta_quality_table.nf}"
QUALITY_PROFILE="${QUALITY_PROFILE:-apptainer}"
QUALITY_LINEAGE="${QUALITY_LINEAGE:-stramenopiles}"
QUALITY_MEMORY="${QUALITY_MEMORY:-64 GB}"

mkdir -p "${QC_FASTA_DIR}"

log "Benchmark summary"
log "Sample: ${SAMPLE}"
log "Benchmark root: ${BENCH_ROOT}"
log "Summary dir: ${SUMMARY_DIR}"

for method in "${METHODS[@]}"; do
    fasta="${BENCH_ROOT}/${method}/${SAMPLE}.fasta.gz"
    link="${QC_FASTA_DIR}/${method}.fasta.gz"

    if [[ ! -s "${fasta}" ]]; then
        echo "Missing final FASTA for ${method}: ${fasta}" >&2
        exit 1
    fi
    if [[ -e "${link}" && ! -L "${link}" ]]; then
        echo "Refusing to overwrite non-symlink QC input: ${link}" >&2
        exit 1
    fi

    ln -sfn "${fasta}" "${link}"
done

log "Running TEA FASTA quality helper"
nextflow run "${QUALITY_TABLE_NF}" \
    -profile "${QUALITY_PROFILE}" \
    --fasta "${QC_FASTA_DIR}/*.fasta.gz" \
    --output "${QC_TABLE}" \
    --quality_library "${BUSCO_DB}" \
    --quality_lineage "${QUALITY_LINEAGE}" \
    --threads "${THREADS}" \
    --memory "${QUALITY_MEMORY}"

log "Writing ${SUMMARY_TABLE}"
awk -F'\t' -v OFS='\t' -v bench_root="${BENCH_ROOT}" -v sample="${SAMPLE}" '
    function normalize(name, x) {
        x = tolower(name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", x)
        gsub(/[[:space:]_]+/, " ", x)
        return x
    }

    function pick_seconds(method, file, seconds, step, value) {
        file = bench_root "/" method "/timing.tsv"
        seconds = "NA"
        while ((getline line < file) > 0) {
            split(line, fields, "\t")
            step = fields[1]
            value = fields[2]
            if (step == "Total") {
                seconds = value
            }
        }
        close(file)
        return seconds
    }

    NR == 1 {
        for (i = 1; i <= NF; i++) {
            key = normalize($i)
            if (key == "file") method_col = i
            if (key == "# contigs") contig_col = i
            if (key == "s" || key ~ /^single/ || key ~ /single-copy/) single_col = i
            if (key == "d" || key ~ /^duplicated/ || key ~ /^duplicate/) duplicate_col = i
        }

        if (!method_col || !contig_col || !single_col || !duplicate_col) {
            print "Could not find required columns in quality table header:" > "/dev/stderr"
            print $0 > "/dev/stderr"
            exit 1
        }

        print "sample", "method", "fasta", "contigs", "compleasm_single", "compleasm_duplicate", "runtime_seconds"
        next
    }

    {
        method = $method_col
        fasta = bench_root "/" method "/" sample ".fasta.gz"
        print sample, method, fasta, $contig_col, $single_col, $duplicate_col, pick_seconds(method)
    }
' "${QC_TABLE}" > "${SUMMARY_TABLE}"

log "Done"
log "Summary table: ${SUMMARY_TABLE}"
