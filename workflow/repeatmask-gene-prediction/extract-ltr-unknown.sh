#!/bin/bash

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export PATH="${DOWNY_ENV:-$HOME/miniforge3/envs/downy}/bin:$PATH"

GENOME_DIR=${PROJECT_DATA}/results/assembly-qc/nuclear
MASK_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/hardmasked
RESULT_DIR=${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/ltr-unknown
mkdir -p "$RESULT_DIR"

# LTR (all LTR/* families) and unclassified (Unknown) RepeatMasker hits from <name>.fasta.out:
# a coordinate table, and the hit sequences from the unmasked assembly in repeat orientation.
for out in "$MASK_DIR"/*_masked/*.fasta.out; do
  BASENAME=$(basename "$out" .fasta.out)
  [[ -s "$GENOME_DIR/$BASENAME.fasta.gz" ]] || continue
  TSV="$RESULT_DIR/$BASENAME.ltr_unknown.tsv"

  awk -v OFS='\t' 'NR > 3 && ($11 ~ /^LTR/ || $11 == "Unknown") {
      split($5, tag, "_")
      printf "%s_rep%06d\t%s\t%d\t%d\t%s\t%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", tag[1], ++n,
        $5, $6, $7, ($9 == "C" ? "-" : "+"), $7 - $6 + 1, $10, $11, $1, $2, $3, $4, $15
    }
    BEGIN { print "repeat_id", "contig", "start", "end", "strand", "length_bp", "repeat_family",
                  "repeat_class", "sw_score", "perc_div", "perc_del", "perc_ins", "rm_id" }' \
    "$out" > "$TSV"

  # BED is 0-based; header = repeat_id contig:start-end(strand) family class
  BED="$(mktemp)"
  tail -n +2 "$TSV" |
    awk -v OFS='\t' '{print $2, $3 - 1, $4, $1" "$2":"$3"-"$4"("$5") "$7" "$8, 0, $5}' > "$BED"
  seqkit subseq --bed "$BED" "$GENOME_DIR/$BASENAME.fasta.gz" |
    sed -E 's/^>[^ ]+ />/' > "$RESULT_DIR/$BASENAME.ltr_unknown.fna"
  rm -f "$BED"
done
