#!/bin/bash
#SBATCH --job-name=benchmark_hifiasm_blastn
#SBATCH -c 32
#SBATCH --mem=512G
#SBATCH --output=benchmark_hifiasm_blastn_%j.out

# Purpose : Benchmark arm 2: hifiasm followed by a BLASTN-based contaminant removal pass (the conventional
#           post-hoc approach targetasm is compared against).
# Inputs  : $SAMPLE reads under $PROJECT_DATA; NCBI nt and the oomycete taxid list
# Outputs : $PROJECT_DATA/results/benchmarking/$SAMPLE/hifiasm_blastn/ incl. timing.tsv
# Runs on : SLURM, 32 cores, one large-memory node
# Usage   : sbatch --export=ALL,SAMPLE=MSU1 workflow/03-benchmarking/hifiasm-blastn.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

SAMPLE="${SAMPLE:-UA202013}"
THREADS="${SLURM_CPUS_PER_TASK:-32}"
SCRIPT_DIR="$REPO_ROOT/workflow/03-benchmarking"
TAXIDS_FILE="${TAXIDS_FILE:-$REPO_ROOT/data/oomycete_taxids.txt}"

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

OUTDIR="${PROJECT_DATA}/results/benchmarking/${SAMPLE}/hifiasm_blastn"
TIMING="${OUTDIR}/timing.tsv"


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
    bash -o pipefail -c 'gfatools gfa2fa "$1" > "$2"' \
        _ \
        "${OUTDIR}/${SAMPLE}.p_ctg.gfa" \
        "${OUTDIR}/${SAMPLE}_contigs.fasta"

run_step "blastn_contigs" \
    blastn \
        -query "${OUTDIR}/${SAMPLE}_contigs.fasta" \
        -db "${NT_DB:-$DB_ROOT/nt/nt}" \
        -outfmt "6 qseqid sseqid pident length qlen slen evalue staxids" \
        -max_target_seqs 1 \
        -max_hsps 1 \
        -evalue 1e-10 \
        -perc_identity 95 \
        -num_threads "${THREADS}" \
        -out "${OUTDIR}/contigs_blast.tsv"

run_step "filter_oomycete_contigs" \
    bash -o pipefail -c '
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
    bash -o pipefail -c 'seqkit grep -f "$1" "$2" --threads "$3" | gzip > "$4"' \
        _ \
        "${OUTDIR}/oomycete_contigs.txt" \
        "${OUTDIR}/${SAMPLE}_contigs.fasta" \
        "${THREADS}" \
        "${OUTDIR}/${SAMPLE}.fasta.gz"

printf "Total\t%s\n" "$(( $(date +%s) - total_start ))" >> "${TIMING}"
echo "Done: ${OUTDIR}/${SAMPLE}.fasta.gz"
