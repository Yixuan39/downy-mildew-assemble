#!/bin/bash
# Purpose : Per-assembly counts behind the manuscript secretome/effectome table: total proteins,
#           SignalP-positive, mTP/TM/GPI removed, soluble secretome, and the scripted effector sets
#           (WY, RXLR). Effector classes described in Methods but not scripted in this repo
#           (EffectorP, EffectorO, CRN, EffectR, NLP, EPI/EPIC, SCR, CAZymes) are NOT counted here.
# Inputs  : the stage-10 outputs under $SECR
# Outputs : $SECR/secretome_summary.tsv  (copy into data/ for the notebook / manuscript table)
# Usage   : bash workflow/10-secretome-effectome/09-summarize-secretome.sh
set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"
# Assemblies processed as a SLURM array (one task per proteome).
ASSEMBLIES=(
  Pseudoperonospora_cubensis_MSU1
  Pseudoperonospora_cubensis_SC1982
  Pseudoperonospora_humuli_OR502AA
  Peronospora_effusa_UA202013_star
)

HELIXER="${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer"      # stage 07 proteomes (<ASM>.faa)
SECR="${PROJECT_DATA}/results/secretome-effectome"        # stage 10 output root

OUT="$SECR/secretome_summary.tsv"
mkdir -p "$SECR"
trap 'rm -f "$OUT.tmp"' EXIT
printf "assembly\ttotal\tsignalp_pos\tmtp_rm\ttm_rm\tgpi_rm\tsoluble\trxlr\twy\n" > "$OUT.tmp"
for ASM in "${ASSEMBLIES[@]}"; do
  SP="$SECR/01-signalp6/$ASM.signalp_positive"
  t=$(awk '/^>/{n++} END {print n+0}' "$HELIXER/$ASM.faa")
  sp=$(wc -l < "$SP.ids")
  mtp=$(wc -l < "$SECR/02-targetp/$ASM.mtp.ids")
  tm=$(wc -l < "$SECR/03-deeptmhmm/$ASM.tm.ids")
  gpi=$(wc -l < "$SECR/04-netgpi/$ASM.gpi.ids")
  sol=$(wc -l < "$SECR/05-soluble-secretome/${ASM}_soluble_secretome.ids")
  rxlr=$(awk '/^>/{seen[$1]=1} END {for (id in seen) n++; print n+0}' "$SECR/07-effectors/$ASM/rxlr/"*.output)
  wy=$(awk '!/^#/ && NF {seen[$1]=1} END {for (id in seen) n++; print n+0}' "$SECR/07-effectors/$ASM/WY.tblout")
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$ASM" "$t" "$sp" "$mtp" "$tm" "$gpi" "$sol" "$rxlr" "$wy" >> "$OUT.tmp"
done
mv "$OUT.tmp" "$OUT"
cat "$OUT"
