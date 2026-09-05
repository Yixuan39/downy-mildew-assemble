#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Same quality workflow over the published downy mildew genomes, so the new assemblies can be
#           compared on identical metrics.
# Inputs  : $HOME/project_data/downy/downy-mildew-genomes/*.fna.gz; compleasm lineages at $HOME/db/compleasm
# Outputs : data/qc_published_genomes/quality_published_genomes.tsv
# Runs on : local or cluster; needs Nextflow with the docker profile
# Usage   : bash workflow/05-assembly-qc/qc-other-genomes.sh
# ----------------------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
GENOME_DIR="${HOME}/project_data/downy/downy-mildew-genomes"
QC_DIR="${REPO_DIR}/data/qc_published_genomes"
INPUT_DIR="${QC_DIR}/fasta_inputs"
OUTPUT_TABLE="${QC_DIR}/quality_published_genomes.tsv"
TARGET_ASM_DIR="${HOME}/Documents/Projects/targetasm"
QUALITY_LIBRARY="${HOME}/db/compleasm"
NEXTFLOW_PROFILE="${NEXTFLOW_PROFILE:-docker}"
THREADS="${THREADS:-$(getconf _NPROCESSORS_ONLN)}"
MEMORY="${MEMORY:-32 GB}"

mkdir -p "${INPUT_DIR}"
find "${INPUT_DIR}" -type l -name '*.fasta.gz' -delete

find "${GENOME_DIR}" -maxdepth 1 -type f -name '*.fna.gz' | sort |
while IFS= read -r fasta; do
    sample="$(basename "${fasta}" .fna.gz)"
    ln -sfn "${fasta}" "${INPUT_DIR}/${sample}.fasta.gz"
done

count=$(find "${INPUT_DIR}" -type l -name '*.fasta.gz' | wc -l | tr -d ' ')
echo "FASTA inputs: ${count}"
[[ "${count}" -eq 11 ]] || { echo "Expected 11 original genome FASTA files." >&2; exit 1; }

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
