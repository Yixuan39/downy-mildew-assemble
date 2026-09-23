#!/bin/bash

# Purpose : Same quality workflow over the published downy mildew genomes, so the new assemblies can be
#           compared on identical metrics.
# Inputs  : ${PROJECT_DATA}/inputs/reference-genomes/*.fna.gz; compleasm lineages at ${DB_ROOT}/compleasm
# Outputs : data/qc_published_genomes/quality_published_genomes.tsv
# Runs on : local or cluster; Nextflow submits SLURM jobs with Apptainer
# Usage   : bash workflow/05-assembly-qc/qc-published-genomes.sh
set -euo pipefail
export REPO_ROOT="${REPO_ROOT:-$(cd ../.. && pwd)}"
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export DB_ROOT="${DB_ROOT:-$HOME/db}"
export TARGET_ASM_DIR="${TARGET_ASM_DIR:-$HOME/software/targetasm}"
export CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-$(command -v apptainer >/dev/null 2>&1 && echo apptainer || echo singularity)}"

SCRIPT_DIR="$REPO_ROOT/workflow/05-assembly-qc"
REPO_DIR="$REPO_ROOT"
GENOME_DIR="${PROJECT_DATA}/inputs/reference-genomes"
QC_DIR="${REPO_DIR}/data/qc_published_genomes"
INPUT_DIR="${QC_DIR}/fasta_inputs"
OUTPUT_TABLE="${QC_DIR}/quality_published_genomes.tsv"
QUALITY_LIBRARY="${DB_ROOT}/compleasm"
NEXTFLOW_PROFILE="${NEXTFLOW_PROFILE:-slurm,$CONTAINER_RUNTIME}"
THREADS="${THREADS:-$(getconf _NPROCESSORS_ONLN)}"
MEMORY="${MEMORY:-32 GB}"

mkdir -p "${INPUT_DIR}"
find "${INPUT_DIR}" -type l -name '*.fasta.gz' -delete

find -L "${GENOME_DIR}" -maxdepth 1 -type f -name '*.fna.gz' | sort |
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
