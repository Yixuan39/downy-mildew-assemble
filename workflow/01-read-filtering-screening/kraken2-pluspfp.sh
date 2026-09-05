#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24
#SBATCH --mem=220G

# Purpose : Classify the adapter-filtered HiFi reads against Kraken2 PlusPFP to quantify host/microbial
#           content before assembly (Fig. 1 read composition).
# Inputs  : ${PROJECT_DATA}/results/read-filtering-screening/reads/focal/*.fastq.gz; Kraken2 PlusPFP at
#           ${DB_ROOT}/kraken2/PlusPFP
# Outputs : ${PROJECT_DATA}/results/read-filtering-screening/taxonomy/<sample>.{kraken,report}
# Runs on : SLURM array 0-2, 24 cores / 220 GB (the PlusPFP index is loaded into RAM)
# Usage   : sbatch workflow/01-read-filtering-screening/kraken2-pluspfp.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

INPUT_DIR="$PROJECT_DATA/results/read-filtering-screening/reads/focal"
FILES=("$INPUT_DIR"/*.fastq.gz)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
sample="$(basename "$FILE" .fastq.gz)"
RESULT_DIR="$PROJECT_DATA/results/read-filtering-screening/taxonomy"
mkdir -p "$RESULT_DIR"
kraken2 --db "$DB_ROOT/kraken2/PlusPFP" \
    --threads "${SLURM_CPUS_PER_TASK:-24}" --confidence 0 \
    --report "$RESULT_DIR/$sample.kreport" \
    --output "$RESULT_DIR/$sample.kraken" "$FILE"
