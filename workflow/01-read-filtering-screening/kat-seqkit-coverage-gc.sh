#!/bin/bash
#SBATCH --job-name=kat-seqkit
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32
#SBATCH --mem=100G

# Purpose : Per-read k-mer coverage (KAT sect, self-comparison) and per-read GC content
#           (seqkit fx2tab) for the adapter-filtered HiFi reads, one array task per library.
#           These are the two axes of the read-level coverage-vs-GC blob plot used to check
#           whether target Oomycota reads can be visually separated from contaminant/host
#           reads (analysis/read-distribution.Rmd).
# Inputs  : ${PROJECT_DATA}/results/read-filtering-screening/reads/focal/*.fastq.gz
# Outputs : ${PROJECT_DATA}/results/read-filtering-screening/coverage-gc/<sample>-sect-stats.tsv
#           (KAT: per-read median/mean 21-mer coverage, KAT's own GC%, length)
#           ${PROJECT_DATA}/results/read-filtering-screening/coverage-gc/<sample>-gc.tsv
#           (seqkit: per-read GC%, name + GC only)
# Runs on : SLURM array 0-2, 32 cores / 100 GB per task
# Usage   : sbatch workflow/01-read-filtering-screening/coverage-gc/kat-seqkit-coverage-gc.sh
# Notes   : KAT sect's own stats output already carries a per-read GC% column, but seqkit's
#           fx2tab GC is kept as an independent cross-check and is what analysis/read-distribution.Rmd
#           actually plots. `seqkit` must be on PATH (conda/module load it before submitting) -
#           Run KAT from the dedicated mamba environment: `mamba run -n kat kat`.

set -uo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"

INPUT_DIR="$PROJECT_DATA/results/read-filtering-screening/reads/focal"
FILES=("$INPUT_DIR"/*.fastq.gz)
FILE="${FILES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"
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
time mamba run -n kat kat sect -n -t "${SLURM_CPUS_PER_TASK:-32}" -m 21 -H 2000000000 \
    -o "${sample}_sect" "$READS" "$READS"
cp "${sample}_sect-stats.tsv" "$OUT/$sample-sect-stats.tsv"

echo "=== output files ==="
ls -la "$OUT"
wc -l "$OUT/$sample-gc.tsv" "$OUT/$sample-sect-stats.tsv"
