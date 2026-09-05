#!/bin/bash
#SBATCH --job-name=adapterfilt
#SBATCH --cpus-per-task=32

# Purpose : Same HiFiAdapterFilt step for the public P. effusa UA202013 reads. Single library, so it runs as
#           one job; $SLURM_ARRAY_TASK_ID is left unset and resolves to index 0.
# Inputs  : ${PROJECT_DATA}/UA202013/*.fastq.gz
# Outputs : ${PROJECT_DATA}/results/read-filtering-screening/reads/UA202013/*.filt.fastq.gz
# Runs on : SLURM, single job, 32 cores
# Usage   : sbatch workflow/01-read-filtering-screening/UA202013/run-hifiadapterfilt.sh

# After subsetting data with filtlong, we remove adapter sequences using hifiadapterfilt.sh
set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}}/workflow/paths.sh"

INPUT_DIR="$PROJECT_DATA/inputs/hifi/UA202013"
cd "$INPUT_DIR"
FILES=(./*.fastq.gz)
[[ ${#FILES[@]} -eq 1 ]] || { echo "Expected exactly one UA202013 FASTQ" >&2; exit 1; }
FILE="${FILES[0]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
# Publish the original sample basename expected by assembly and Kraken2.
sample="$(basename "$FILE" .fastq.gz)"
FILTERED="$PROJECT_DATA/results/read-filtering-screening/reads/UA202013"
mkdir -p "$FILTERED"
hifiadapterfilt.sh -p "$sample" -o "$FILTERED" -t "${SLURM_CPUS_PER_TASK:-32}"
[[ -s "$FILTERED/$sample.filt.fastq.gz" ]]
mv "$FILTERED/$sample.filt.fastq.gz" "$FILTERED/$sample.fastq.gz"
