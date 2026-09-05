#!/bin/bash
#SBATCH --job-name=targetp
#SBATCH --array=0-3
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=24:00:00
#SBATCH --output=logs/targetp.%A_%a.out
#SBATCH --error=logs/targetp.%A_%a.err

# ----------------------------------------------------------------------------------------
# Purpose : Cross-reference the SignalP-positive set with TargetP 2.0 to EXCLUDE proteins whose
#           N-terminus is a mitochondrial transit peptide (mTP) rather than a secretion signal.
# Inputs  : $SP.faa  (from 01-signalp6.sh)
# Outputs : $SECR/02-targetp/<ASM>.targetp2.txt; $SECR/02-targetp/<ASM>.mtp.ids (to remove)
# Tool    : TargetP 2.0 (local install $HOME/software/targetp-2.0) - LICENSE-GATED, see README
# Usage   : sbatch workflow/10-secretome-effectome/02-targetp.sh
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

mkdir -p "$SECR/02-targetp" logs
"$HOME/software/targetp-2.0/bin/targetp" -fasta "$SP.faa" -org non-pl -format short \
  -prefix "$SECR/02-targetp/$ASM"
mv -f "$SECR/02-targetp/${ASM}_summary.targetp2" "$SECR/02-targetp/$ASM.targetp2.txt" 2>/dev/null || true
awk '$0!~/^#/ && $2=="mTP"{print $1}' "$SECR/02-targetp/$ASM.targetp2.txt" | sort -u > "$SECR/02-targetp/$ASM.mtp.ids"
