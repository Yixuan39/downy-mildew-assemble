#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Collect every benchmark assembly into one directory and run the targetasm quality workflow over
#           all of them, producing the single table analysis/benchmark.Rmd reads.
# Inputs  : $HOME/project_data/downy/benchmarking/*/*/ assemblies; compleasm lineages at $HOME/db/compleasm;
#           targetasm at $HOME/software/targetasm
# Outputs : data/benchmark_qc/quality_all_benchmarking.tsv
# Runs on : local or cluster; needs Nextflow with the docker profile
# Usage   : bash workflow/03-benchmarking/fasta-quality-table.sh
# ----------------------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BENCHMARK_ROOT="${HOME}/project_data/downy/benchmarking"
TARGET_ASM_DIR="${HOME}/Documents/Projects/targetasm"
if [[ ! -f "${TARGET_ASM_DIR}/run_fasta_quality_table.nf" ]]; then
    TARGET_ASM_DIR="${HOME}/software/targetasm"
fi

QC_DIR="${REPO_DIR}/data/benchmark_qc"
INPUT_DIR="${QC_DIR}/fasta_inputs_all"
OUTPUT_TABLE="${QC_DIR}/quality_all_benchmarking.tsv"
QUALITY_LIBRARY="${HOME}/db/compleasm"
QUALITY_LINEAGE="stramenopiles"
NEXTFLOW_PROFILE="${NEXTFLOW_PROFILE:-docker}"
THREADS="${THREADS:-4}"
MEMORY="${MEMORY:-32 GB}"
MAX_FORKS="${MAX_FORKS:-1}"

mkdir -p "${INPUT_DIR}"
find "${INPUT_DIR}" -type l -name '*.fasta.gz' -delete

find "${BENCHMARK_ROOT}" -type f -name '*.fasta.gz' ! -path '*/metaMDBG/*' | sort |
while IFS= read -r fasta; do
    rel="${fasta#${BENCHMARK_ROOT}/}"
    sample="${rel%.fasta.gz}"
    safe_sample="$(printf '%s' "${sample}" | tr -c '[:alnum:]' '_' | sed 's/_\{1,\}/_/g; s/^_//; s/_$//')"
    ln -sfn "${fasta}" "${INPUT_DIR}/${safe_sample}.fasta.gz"
done

count=$(find "${INPUT_DIR}" -type l -name '*.fasta.gz' | wc -l | tr -d ' ')
echo "FASTA inputs: ${count}"
[[ "${count}" -eq 7 ]] || { echo "Expected 7 FASTA files." >&2; exit 1; }

export NXF_SYNTAX_PARSER="${NXF_SYNTAX_PARSER:-v1}"

nextflow run "${TARGET_ASM_DIR}/run_fasta_quality_table.nf" \
    -c "${TARGET_ASM_DIR}/nextflow.config" \
    -profile "${NEXTFLOW_PROFILE}" \
    -resume \
    -process.maxForks "${MAX_FORKS}" \
    --fasta "${INPUT_DIR}/*.fasta.gz" \
    --output "${OUTPUT_TABLE}" \
    --quality_library "${QUALITY_LIBRARY}" \
    --quality_lineage "${QUALITY_LINEAGE}" \
    --threads "${THREADS}" \
    --memory "${MEMORY}"
