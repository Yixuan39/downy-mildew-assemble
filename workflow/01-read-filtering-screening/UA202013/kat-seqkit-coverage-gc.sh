#!/bin/bash
#SBATCH --job-name=kat-seqkit
#SBATCH --cpus-per-task=32
#SBATCH --mem=100G

# Purpose : Same per-read KAT sect self-coverage and seqkit fx2tab GC content as
#           coverage-gc/kat-seqkit-coverage-gc.sh, for the public P. effusa (UA202013) reads,
#           which live in their own directory and are a single file (no array).
# Inputs  : ${PROJECT_DATA}/results/read-filtering-screening/reads/UA202013/*.fastq.gz
# Outputs : ${PROJECT_DATA}/results/read-filtering-screening/coverage-gc/<sample>-sect-stats.tsv
#           ${PROJECT_DATA}/results/read-filtering-screening/coverage-gc/<sample>-gc.tsv
# Runs on : SLURM, single job, 32 cores / 100 GB
# Usage   : sbatch workflow/01-read-filtering-screening/UA202013/kat-seqkit-coverage-gc.sh
# Notes   : `seqkit` must be on PATH (conda/module load it before submitting) - unlike kraken2
#           and kat, no container for it is provisioned under $DB_ROOT/containers.

set -uo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}}/workflow/paths.sh"

INPUT_DIR="$PROJECT_DATA/results/read-filtering-screening/reads/UA202013"
FILES=("$INPUT_DIR"/*.fastq.gz)
[[ ${#FILES[@]} -eq 1 ]] || { echo "Expected exactly one UA202013 FASTQ" >&2; exit 1; }
FILE="${FILES[0]}"
[[ -s "$FILE" ]] || { echo "Missing input: $FILE" >&2; exit 1; }
sample="$(basename "$FILE" .fastq.gz)"

OUT="$PROJECT_DATA/results/read-filtering-screening/coverage-gc"
mkdir -p "$OUT"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
READS="$WORK/$sample.fastq"

echo "=== decompressing reads ==="
time zcat "$FILE" > "$READS"

echo "=== seqkit fx2tab: per-read GC% ==="
time seqkit fx2tab -n -g -j "${SLURM_CPUS_PER_TASK:-32}" "$READS" \
    > "$OUT/$sample-gc.tsv"

echo "=== kat sect: per-read 21-mer self-coverage ==="
cd "$WORK"
time singularity exec "$DB_ROOT/containers/kat_2.4.2.sif" kat sect -n -t "${SLURM_CPUS_PER_TASK:-32}" -m 21 -H 2000000000 \
    -o "${sample}_sect" "$READS" "$READS"
cp "${sample}_sect-stats.tsv" "$OUT/$sample-sect-stats.tsv"

echo "=== output files ==="
ls -la "$OUT"
wc -l "$OUT/$sample-gc.tsv" "$OUT/$sample-sect-stats.tsv"
