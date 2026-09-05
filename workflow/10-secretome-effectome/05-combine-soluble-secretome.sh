#!/bin/bash
#SBATCH --job-name=soluble-secretome
#SBATCH --array=0-3
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=1:00:00
#SBATCH --output=logs/combine.%A_%a.out
#SBATCH --error=logs/combine.%A_%a.err

# ----------------------------------------------------------------------------------------
# Purpose : Build the soluble secretome per Methods: SignalP-positive proteins MINUS TargetP-mTP
#           MINUS DeepTMHMM transmembrane MINUS NetGPI GPI-anchored. (DeepLoc is NOT a filter here;
#           it is run separately in 06 as a supplementary localization assessment.)
# Inputs  : $SP.ids, 02-targetp/<ASM>.mtp.ids, 03-deeptmhmm/<ASM>.tm.ids, 04-netgpi/<ASM>.gpi.ids
# Outputs : $SECR/05-soluble-secretome/<ASM>_soluble_secretome.{ids,faa}
# Usage   : sbatch workflow/10-secretome-effectome/05-combine-soluble-secretome.sh
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

OUT="$SECR/05-soluble-secretome"; mkdir -p "$OUT" logs
sort -u "$SP.ids" \
  | comm -23 - "$SECR/02-targetp/$ASM.mtp.ids" \
  | comm -23 - "$SECR/03-deeptmhmm/$ASM.tm.ids" \
  | comm -23 - "$SECR/04-netgpi/$ASM.gpi.ids" \
  > "$OUT/${ASM}_soluble_secretome.ids"
seqkit grep -f "$OUT/${ASM}_soluble_secretome.ids" "$HELIXER/$ASM.faa" > "$OUT/${ASM}_soluble_secretome.faa"
echo "$ASM soluble secretome: $(wc -l < "$OUT/${ASM}_soluble_secretome.ids")"
