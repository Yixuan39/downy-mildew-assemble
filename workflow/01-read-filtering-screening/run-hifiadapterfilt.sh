#!/bin/bash
#SBATCH --job-name=adapterfilt
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

# Purpose : Remove PacBio adapter sequence from the filtlong-subset HiFi reads with HiFiAdapterFilt, one
#           array task per library.
# Inputs  : ${PROJECT_DATA}/inputs/hifi/focal/fastq/*.fastq.gz
# Outputs : ${PROJECT_DATA}/results/read-filtering-screening/reads/focal/*.filt.fastq.gz
# Runs on : SLURM, array 0-2, 32 cores per task
# Usage   : sbatch workflow/01-read-filtering-screening/run-hifiadapterfilt.sh

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"

INPUT_DIR="$PROJECT_DATA/inputs/hifi/focal/fastq"
cd "$INPUT_DIR"
FILES=(./*.fastq.gz)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
# Publish the original sample basename expected by assembly and Kraken2.
sample="$(basename "$FILE" .fastq.gz)"
FILTERED="$PROJECT_DATA/results/read-filtering-screening/reads/focal"
mkdir -p "$FILTERED"
hifiadapterfilt.sh -p "$sample" -o "$FILTERED" -t "${SLURM_CPUS_PER_TASK:-32}"
[[ -s "$FILTERED/$sample.filt.fastq.gz" ]]
mv "$FILTERED/$sample.filt.fastq.gz" "$FILTERED/$sample.fastq.gz"
