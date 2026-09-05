#!/bin/bash
#SBATCH --job-name=rxlr-mining
#SBATCH --array=0-3
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=1:00:00
#SBATCH --output=logs/rxlr.%A_%a.out
#SBATCH --error=logs/rxlr.%A_%a.err

# Purpose : Identify RXLR and RXLR-like effectors in the soluble secretome with the modified custom
#           motif scripts (Win et al. 2007): motif within 10-110 aa of the N-terminus, downstream
#           of the signal-peptide cleavage site.
# Inputs  : $SECR/05-soluble-secretome/<ASM>_soluble_secretome.faa; find_*.pl scripts (see README)
# Outputs : $SECR/07-effectors/<ASM>/rxlr/<ASM>_<motif>.output
# Tool    : Perl + collaborator find_*.pl scripts (NOT in this repo - see README "Required tools")
# Usage   : sbatch workflow/10-secretome-effectome/08-mining-rxlr.sh
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

SCRIPT_DIR="${SOFTWARE_ROOT}/mining_RLXR"
IN="$SECR/05-soluble-secretome/${ASM}_soluble_secretome.faa"
OUT="$SECR/07-effectors/$ASM/rxlr"; mkdir -p "$OUT" logs
for s in "$SCRIPT_DIR"/find_*.pl; do
  [ -e "$s" ] || { echo "no find_*.pl in $SCRIPT_DIR"; exit 1; }
  name=$(basename "$s" .pl)
  printf "%s\n%s\n" "$IN" "$OUT/${ASM}_${name}.output" | perl "$s"
done
