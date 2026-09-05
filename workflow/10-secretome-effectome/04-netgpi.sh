#!/bin/bash
#SBATCH --job-name=netgpi
#SBATCH --array=0-3
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=logs/netgpi.%A_%a.out
#SBATCH --error=logs/netgpi.%A_%a.err

# Purpose : Remove proteins with a predicted GPI anchor (membrane-tethered, not soluble) from the
#           SignalP-positive set, using NetGPI 1.1.
# Inputs  : $SP.faa  (from 01-signalp6.sh)
# Outputs : $SECR/04-netgpi/<ASM>.netgpi.txt; $SECR/04-netgpi/<ASM>.gpi.ids (to remove)
# Tool    : NetGPI 1.1 (conda env `netgpi`) - LICENSE-GATED, see README "Required tools"
# NOTE    : Confirm the NetGPI CLI and output column against a real run; the parse below assumes a
#           tab table with a "GPI-Anchored" prediction label.
# Usage   : sbatch workflow/10-secretome-effectome/04-netgpi.sh
set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"
# Assemblies processed as a SLURM array (one task per proteome).
ASSEMBLIES=(
  Pseudoperonospora_cubensis_MSU1
  Pseudoperonospora_cubensis_SC1982
  Pseudoperonospora_humuli_OR502AA
  Peronospora_effusa_UA202013_star
)
ASM="${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}"

HELIXER="${PROJECT_DATA}/results/repeatmask-gene-prediction/focal/helixer"      # stage 07 proteomes (<ASM>.faa)
SECR="${PROJECT_DATA}/results/secretome-effectome"        # stage 10 output root
SP="$SECR/01-signalp6/$ASM.signalp_positive"                     # SignalP-positive set (.ids/.faa)

mkdir -p "$SECR/04-netgpi" logs
netgpi -f "$SP.faa" > "$SECR/04-netgpi/$ASM.netgpi.txt"
awk -F'\t' '$0!~/^#/ && $2 ~ /GPI-Anchored/{print $1}' "$SECR/04-netgpi/$ASM.netgpi.txt" | sort -u > "$SECR/04-netgpi/$ASM.gpi.ids"
