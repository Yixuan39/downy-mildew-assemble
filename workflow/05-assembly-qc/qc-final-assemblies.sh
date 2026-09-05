#!/bin/bash

# Purpose : Run the targetasm quality workflow (compleasm + QUAST) over the three final assemblies of this
#           paper.
# Inputs  : ${PROJECT_DATA}/results/assembly-qc/nuclear/*.fasta.gz; compleasm lineages at
#           ${DB_ROOT}/compleasm
# Outputs : data/qc_final_assemblies/quality_final_assemblies.tsv
# Runs on : local or cluster; Nextflow submits SLURM jobs with Apptainer
# Usage   : bash workflow/05-assembly-qc/qc-final-assemblies.sh
set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

SCRIPT_DIR="$REPO_ROOT/workflow/05-assembly-qc"
REPO_DIR="$REPO_ROOT"
GENOME_DIR="${PROJECT_DATA}/results/assembly-qc/nuclear"
QC_DIR="${REPO_DIR}/data/qc_final_assemblies"
INPUT_DIR="${QC_DIR}/fasta_inputs"
OUTPUT_TABLE="${QC_DIR}/quality_final_assemblies.tsv"
QUALITY_LIBRARY="${DB_ROOT}/compleasm"
NEXTFLOW_PROFILE="${NEXTFLOW_PROFILE:-slurm,$CONTAINER_RUNTIME}"
THREADS="${THREADS:-$(getconf _NPROCESSORS_ONLN)}"
MEMORY="${MEMORY:-32 GB}"

mkdir -p "${INPUT_DIR}"
find "${INPUT_DIR}" -type l -name '*.fasta.gz' -delete

find "${GENOME_DIR}" -maxdepth 1 -type f -name '*.fasta.gz' | sort |
while IFS= read -r fasta; do
    ln -sfn "${fasta}" "${INPUT_DIR}/$(basename "${fasta}")"
done

count=$(find "${INPUT_DIR}" -type l -name '*.fasta.gz' | wc -l | tr -d ' ')
echo "FASTA inputs: ${count}"
[[ "${count}" -eq 4 ]] || { echo "Expected 4 mitochondrial-filtered assembly FASTA files." >&2; exit 1; }

export NXF_SYNTAX_PARSER="${NXF_SYNTAX_PARSER:-v1}"

nextflow run "${TARGET_ASM_DIR}/run_fasta_quality_table.nf" \
    -c "${TARGET_ASM_DIR}/nextflow.config" \
    -profile "${NEXTFLOW_PROFILE}" \
    -resume \
    -process.maxForks 1 \
    --fasta "${INPUT_DIR}/*.fasta.gz" \
    --output "${OUTPUT_TABLE}" \
    --quality_library "${QUALITY_LIBRARY}" \
    --quality_lineage stramenopiles \
    --threads "${THREADS}" \
    --memory "${MEMORY}"
