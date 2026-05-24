#!/bin/bash
#SBATCH --job-name=benchmark_hifiasm_blastn
#SBATCH -c 24
#SBATCH --mem=0
#SBATCH --output=benchmark_hifiasm_blastn_%j.out

set -euo pipefail

SAMPLE="${SAMPLE:-p_effusa}"
THREADS="${SLURM_CPUS_PER_TASK:-24}"
PROJECT_DATA="${PROJECT_DATA:-${HOME}/project_data/downy}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUBMIT_DIR="${SLURM_SUBMIT_DIR:-$PWD}"
TAXIDS_FILE="${TAXIDS_FILE:-}"

case "${SAMPLE}" in
    p_effusa)
        READS="${PROJECT_DATA}/p_effusa/filtered/p_effusa.fastq.gz"
        ;;
    MSU1|Quesada_SQIIe_MSU1)
        SAMPLE="MSU1"
        READS="${PROJECT_DATA}/GSL_Data/fastq/filtered/Quesada_SQIIe_MSU1.fastq.gz"
        ;;
    *)
        echo "Unknown SAMPLE=${SAMPLE}. Use SAMPLE=p_effusa or SAMPLE=MSU1." >&2
        exit 1
        ;;
esac

OUTDIR="${PROJECT_DATA}/benchmarking/${SAMPLE}/hifiasm_blastn"
TIMING="${OUTDIR}/timing.tsv"

if [[ -z "${TAXIDS_FILE}" ]]; then
    for candidate in \
        "${SUBMIT_DIR}/data/oomycete_taxids.txt" \
        "${SUBMIT_DIR}/../data/oomycete_taxids.txt" \
        "${SCRIPT_DIR}/../data/oomycete_taxids.txt" \
        "${PWD}/data/oomycete_taxids.txt"; do
        if [[ -s "${candidate}" ]]; then
            TAXIDS_FILE="${candidate}"
            break
        fi
    done
fi

if [[ ! -s "${TAXIDS_FILE}" ]]; then
    echo "Missing oomycete taxid file: ${TAXIDS_FILE}" >&2
    exit 1
fi

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
echo "Taxids: ${TAXIDS_FILE}"
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
    bash -c 'gfatools gfa2fa "$1" > "$2"' \
        _ \
        "${OUTDIR}/${SAMPLE}.p_ctg.gfa" \
        "${OUTDIR}/${SAMPLE}_contigs.fasta"

run_step "blastn_contigs" \
    blastn \
        -query "${OUTDIR}/${SAMPLE}_contigs.fasta" \
        -db nt \
        -outfmt "6 qseqid sseqid pident length qlen slen evalue staxids" \
        -max_target_seqs 1 \
        -max_hsps 1 \
        -evalue 1e-10 \
        -perc_identity 95 \
        -num_threads "${THREADS}" \
        -out "${OUTDIR}/contigs_blast.tsv"

run_step "filter_oomycete_contigs" \
    bash -c '
        awk -F"\t" '\''
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
        '\'' "$1" "$2" > "$3"
    ' \
        _ \
        "${TAXIDS_FILE}" \
        "${OUTDIR}/contigs_blast.tsv" \
        "${OUTDIR}/oomycete_contigs.txt"

echo "Oomycete contigs: $(wc -l < "${OUTDIR}/oomycete_contigs.txt")"

run_step "write_filtered_fasta" \
    bash -c 'seqkit grep -f "$1" "$2" --threads "$3" | gzip > "$4"' \
        _ \
        "${OUTDIR}/oomycete_contigs.txt" \
        "${OUTDIR}/${SAMPLE}_contigs.fasta" \
        "${THREADS}" \
        "${OUTDIR}/${SAMPLE}.fasta.gz"

printf "Total\t%s\n" "$(( $(date +%s) - total_start ))" >> "${TIMING}"
echo "Done: ${OUTDIR}/${SAMPLE}.fasta.gz"
