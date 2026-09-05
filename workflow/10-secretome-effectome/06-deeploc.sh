#!/bin/bash
#SBATCH --job-name=deeploc2
#SBATCH --array=0-3
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=6:00:00
#SBATCH --output=logs/deeploc2.%A_%a.out
#SBATCH --error=logs/deeploc2.%A_%a.err

# Purpose : SUPPLEMENTARY (not a secretome filter). DeepLoc 2.1 (Fast mode) annotates subcellular
#           localization of the soluble secretome and flags alternative secretory pathways.
# Inputs  : $SECR/05-soluble-secretome/<ASM>_soluble_secretome.faa
# Outputs : $SECR/06-deeploc/<ASM>/results_*.csv
# Tool    : DeepLoc 2.1 (conda env `deeploc2`) - LICENSE-GATED, see README "Required tools"
# Usage   : sbatch workflow/10-secretome-effectome/06-deeploc.sh
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

CACHE="$SECR/06-deeploc/.cache"; mkdir -p "$CACHE"
export HF_HOME="$CACHE/hf" TORCH_HOME="$CACHE/torch" MPLCONFIGDIR="$CACHE/mpl" XDG_CACHE_HOME="$CACHE" TMPDIR="$CACHE/tmp"
mkdir -p "$HF_HOME" "$TORCH_HOME" "$MPLCONFIGDIR" "$TMPDIR" "$SECR/06-deeploc/$ASM" logs
deeploc2 --fasta "$SECR/05-soluble-secretome/${ASM}_soluble_secretome.faa" \
  --output "$SECR/06-deeploc/$ASM" --model Fast
