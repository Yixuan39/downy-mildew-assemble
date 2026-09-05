#!/bin/bash
# ----------------------------------------------------------------------------------------
# Purpose : Per-assembly counts behind the manuscript secretome/effectome table: total proteins,
#           SignalP-positive, mTP/TM/GPI removed, soluble secretome, and the scripted effector sets
#           (WY, RXLR). Effector classes described in Methods but not scripted in this repo
#           (EffectorP, EffectorO, CRN, EffectR, NLP, EPI/EPIC, SCR, CAZymes) are NOT counted here.
# Inputs  : the stage-10 outputs under $SECR
# Outputs : $SECR/secretome_summary.tsv  (copy into data/ for the notebook / manuscript table)
# Usage   : bash workflow/10-secretome-effectome/09-summarize-secretome.sh
# ----------------------------------------------------------------------------------------
set -euo pipefail
# Assemblies processed as a SLURM array (one task per proteome).
ASSEMBLIES=(
  Pseudoperonospora_cubensis_MSU1
  Pseudoperonospora_cubensis_SC1982
  Pseudoperonospora_humuli_OR502AA
  Peronospora_effusa_reassemble
)
ASM="${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}"

HELIXER="$HOME/project_data/downy/contigs-renamed/helixer"      # stage 07 proteomes (<ASM>.faa)
SECR="$HOME/project_data/downy/contigs-renamed/secretome"        # stage 10 output root
SP="$SECR/01-signalp6/$ASM.signalp_positive"                     # SignalP-positive set (.ids/.faa)

OUT="$SECR/secretome_summary.tsv"
printf "assembly\ttotal\tsignalp_pos\tmtp_rm\ttm_rm\tgpi_rm\tsoluble\trxlr\twy\n" > "$OUT"
for ASM in "${ASSEMBLIES[@]}"; do
  SP="$SECR/01-signalp6/$ASM.signalp_positive"
  t=$(grep -c '^>' "$HELIXER/$ASM.faa" 2>/dev/null || echo 0)
  sp=$(wc -l < "$SP.ids" 2>/dev/null || echo 0)
  mtp=$(wc -l < "$SECR/02-targetp/$ASM.mtp.ids" 2>/dev/null || echo 0)
  tm=$(wc -l < "$SECR/03-deeptmhmm/$ASM.tm.ids" 2>/dev/null || echo 0)
  gpi=$(wc -l < "$SECR/04-netgpi/$ASM.gpi.ids" 2>/dev/null || echo 0)
  sol=$(wc -l < "$SECR/05-soluble-secretome/${ASM}_soluble_secretome.ids" 2>/dev/null || echo 0)
  rxlr=$(cat "$SECR/07-effectors/$ASM/rxlr/"*.output 2>/dev/null | grep -c '^>' || echo 0)
  wy=$(grep -vc '^#' "$SECR/07-effectors/$ASM/WY.tblout" 2>/dev/null || echo 0)
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$ASM" "$t" "$sp" "$mtp" "$tm" "$gpi" "$sol" "$rxlr" "$wy" >> "$OUT"
done
column -t "$OUT"
