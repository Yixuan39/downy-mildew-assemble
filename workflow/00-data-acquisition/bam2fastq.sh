#!/bin/bash
#SBATCH --job-name=bam2fq
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24

# Purpose : Convert the PacBio HiFi BAMs delivered by the sequencing core into gzipped FASTQ, one array task
#           per BAM.
# Inputs  : ${PROJECT_DATA}/inputs/hifi/focal/bam/*/*.bam
# Outputs : ${PROJECT_DATA}/inputs/hifi/focal/fastq/<run>.fastq.gz
# Runs on : SLURM array 0-2 (one task per isolate BAM)
# Usage   : sbatch workflow/00-data-acquisition/bam2fastq.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

INPUT_DIR="$PROJECT_DATA/inputs/hifi/focal/bam"
OUTPUT_DIR="$PROJECT_DATA/inputs/hifi/focal/fastq"
FILES=("$INPUT_DIR"/*/*.bam)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
mkdir -p "$OUTPUT_DIR"
bam2fastq --output "$OUTPUT_DIR/$(basename "$(dirname "$FILE")")" "$FILE"
