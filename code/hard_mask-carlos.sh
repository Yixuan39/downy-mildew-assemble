#!/bin/bash
#SBATCH -c 32
#SBATCH --mem=0

set -euo pipefail

THREADS="${SLURM_CPUS_PER_TASK:-32}"
INPUT_DIR="$HOME/project_data/downy/contigs-renamed/cleaned"
RESULT_DIR="$HOME/project_data/downy/contigs-renamed/hardmasked-carlos"
TMP_DIR="$RESULT_DIR/tmp"
DB="$TMP_DIR/combined_genome"

FILES=(
  "$INPUT_DIR/Pseudoperonospora_cubensis_MSU1.fasta.gz"
  "$INPUT_DIR/Pseudoperonospora_cubensis_SC1982.fasta.gz"
  "$INPUT_DIR/Pseudoperonospora_humuli_OR502AA.fasta.gz"
)

mkdir -p "$TMP_DIR" "$RESULT_DIR"

gzip -dc "${FILES[@]}" > "${DB}.raw.fasta"
seqkit rmdup -s "${DB}.raw.fasta" > "${DB}.fasta"

BuildDatabase \
  -name "$DB" \
  "${DB}.fasta"

RepeatModeler \
  -threads "$THREADS" \
  -database "$DB" > "$TMP_DIR/repeatmodeler.out"

for FILE in "${FILES[@]}"; do
  BASENAME=$(basename "$FILE")
  BASENAME=${BASENAME%.fasta.gz}
  WORK_DIR="$TMP_DIR/$BASENAME"
  MASKED_DIR="$WORK_DIR/masked"

  echo "Processing: $FILE"
  mkdir -p "$WORK_DIR" "$MASKED_DIR"
  gzip -dc "$FILE" > "$WORK_DIR/${BASENAME}.fasta"

  RepeatMasker \
    -engine ncbi \
    -parallel $((THREADS / 4)) \
    -gff \
    -lib "${DB}-families.fa" \
    -dir "$MASKED_DIR" \
    "$WORK_DIR/${BASENAME}.fasta"

  cp "$MASKED_DIR/${BASENAME}.fasta.masked" "$RESULT_DIR/${BASENAME}.fasta"
  gzip -f "$RESULT_DIR/${BASENAME}.fasta"
done
