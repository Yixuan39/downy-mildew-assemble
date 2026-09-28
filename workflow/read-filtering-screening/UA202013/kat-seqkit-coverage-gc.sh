#!/bin/bash
#SBATCH --job-name=kat-seqkit
#SBATCH --cpus-per-task=32
#SBATCH --mem=100G

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"

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
time seqkit fx2tab -n -g -j "$SLURM_CPUS_PER_TASK" "$READS" \
    > "$OUT/$sample-gc.tsv"

echo "=== kat sect: per-read 21-mer self-coverage ==="
cd "$WORK"
time mamba run -n kat kat sect -n -t "$SLURM_CPUS_PER_TASK" -m 21 -H 2000000000 \
    -o "${sample}_sect" "$READS" "$READS"
cp "${sample}_sect-stats.tsv" "$OUT/$sample-sect-stats.tsv"

echo "=== output files ==="
ls -la "$OUT"
wc -l "$OUT/$sample-gc.tsv" "$OUT/$sample-sect-stats.tsv"
