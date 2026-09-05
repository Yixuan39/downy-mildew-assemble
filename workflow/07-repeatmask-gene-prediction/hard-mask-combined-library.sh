#!/bin/bash
#SBATCH -c 32
#SBATCH --mem=0

# ----------------------------------------------------------------------------------------
# Purpose : Alternative masking strategy: build ONE repeat library from all assemblies combined
#           (deduplicated with seqkit rmdup) and mask every assembly with it. Kept because the combined-
#           library masking is what the annotation comparison used.
# Inputs  : $HOME/project_data/downy/contigs-renamed/cleaned/ (explicit FILES list inside the script)
# Outputs : $HOME/project_data/downy/contigs-renamed/hardmasked-carlos/
# Runs on : NCSU BRC, SLURM, 32 cores
# Usage   : sbatch workflow/07-repeatmask-gene-prediction/hard-mask-combined-library.sh
# ----------------------------------------------------------------------------------------

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

gzip -dc "${FILES[@]}" > "${DB}.fasta"

BuildDatabase \
  -name "$DB" \
  "${DB}.fasta"

RepeatModeler \
  -threads "$THREADS" \
  -database "$DB" > "$TMP_DIR/repeatmodeler.out"

seqkit rmdup -s "${DB}-families.fa" > "${DB}-families-dedup.fa"

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
    -lib "${DB}-families-dedup.fa" \
    -dir "$MASKED_DIR" \
    "$WORK_DIR/${BASENAME}.fasta"

  cp "$MASKED_DIR/${BASENAME}.fasta.masked" "$RESULT_DIR/${BASENAME}.fasta"
  gzip -f "$RESULT_DIR/${BASENAME}.fasta"
done
