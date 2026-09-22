#!/usr/bin/env bash
# Purpose : Two-arm diamond blastp search of every protein-coding gene inside a flagged span
#           (plus flanking control genes) against nr - Arm A unrestricted (full taxonomic
#           spread of the best hits) and Arm B restricted to Oomycota (taxid 4762, the best
#           homolog within the query's own phylum). Comparing the two arms is what separates
#           genuine foreign contamination from a shared/ancestral gene family that is merely
#           under-represented for oomycetes in nr - the ERG3 sterol-desaturase argument in
#           ../ncbi_reply.Rmd.
# Inputs  : ../data/query_proteins.faa            - all span + flank-control proteins, all isolates
#           ../data/spans.tsv, ../data/span_genes.tsv   - span coordinates and per-span gene lists
#           $HOME/db/diamond/nr.dmnd               - local diamond-formatted nr
# Outputs : ../data/blastp_arm_unrestricted.tsv.gz - Arm A (--max-target-seqs 250, no taxon restriction)
#           ../data/blastp_arm_oomycota.tsv        - Arm B (--max-target-seqs 25, --taxonlist 4762)
#           (outfmt 6, with staxids/sphylums/sgenus/sspecies/stitle appended)
# Runs on : SLURM, 32 cores, full node memory (--mem=0); Arm A alone ran ~2.3h wall time
# Usage   : bash blastp_two_arm.sh   (paths are absolute to the cluster project tree;
#           kept as historical record, not meant to be re-run verbatim on a different machine)
PD=$HOME/project_data/downy
OUT=$PD/results/assembly-qc/ncbi-flag-evidence
FMT="qseqid sseqid pident length qlen slen evalue bitscore qcovhsp staxids sphylums sgenus sspecies stitle"

# Arm A: unrestricted nr, deep target list -> full taxonomic spread of homologs
$HOME/miniforge3/bin/mamba run -n diamond diamond blastp \
  --threads 32 --evalue 1e-3 --max-target-seqs 250 --sensitive --index-chunks 1 \
  --db $HOME/db/diamond/nr.dmnd --query $OUT/query_proteins.faa \
  --header simple --out ./blastp_arm_unrestricted.tsv --outfmt 6 $FMT

# Arm B: restricted to Oomycota (taxid 4762) -> best oomycete homolog per query
$HOME/miniforge3/bin/mamba run -n diamond diamond blastp \
  --threads 32 --evalue 1e-3 --max-target-seqs 25 --sensitive --index-chunks 1 \
  --taxonlist 4762 \
  --db $HOME/db/diamond/nr.dmnd --query $OUT/query_proteins.faa \
  --header simple --out ./blastp_arm_oomycota.tsv --outfmt 6 $FMT

cp $OUT/span_genes.tsv $OUT/spans.tsv $OUT/query_proteins_archived_besthit.tsv ./ || true
cp $OUT/query_proteins.faa ./ || true
gzip -f ./blastp_arm_unrestricted.tsv || true
wc -l ./blastp_arm_oomycota.tsv || true
ls -lh ./ || true
