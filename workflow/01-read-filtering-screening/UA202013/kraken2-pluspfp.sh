#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --cpus-per-task=24
#SBATCH --mem=220G

# Purpose : Same Kraken2 PlusPFP classification for the public P. effusa reads, which live in their own
#           directory and are a single file (no array).
# Inputs  : ${PROJECT_DATA}/results/read-filtering-screening/reads/UA202013/*.fastq.gz; Kraken2 PlusPFP at
#           ${DB_ROOT}/kraken2/PlusPFP
# Outputs : ${PROJECT_DATA}/results/read-filtering-screening/taxonomy/<sample>.{kraken,report}
# Runs on : SLURM, 24 cores / 220 GB
# Usage   : sbatch workflow/01-read-filtering-screening/UA202013/kraken2-pluspfp.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}}/workflow/paths.sh"

INPUT_DIR="$PROJECT_DATA/results/read-filtering-screening/reads/UA202013"
FILES=("$INPUT_DIR"/*.fastq.gz)
[[ ${#FILES[@]} -eq 1 ]] || { echo "Expected exactly one UA202013 FASTQ" >&2; exit 1; }
FILE="${FILES[0]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
sample="$(basename "$FILE" .fastq.gz)"
RESULT_DIR="$PROJECT_DATA/results/read-filtering-screening/taxonomy"
mkdir -p "$RESULT_DIR"
kraken2 --db "$DB_ROOT/kraken2/PlusPFP" \
    --threads "${SLURM_CPUS_PER_TASK:-24}" --confidence 0 \
    --report "$RESULT_DIR/$sample.kreport" \
    --output "$RESULT_DIR/$sample.kraken" "$FILE"
