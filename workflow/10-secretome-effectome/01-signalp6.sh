#!/bin/bash
#SBATCH --job-name=signalp6
#SBATCH --array=0-3
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=24:00:00
#SBATCH --output=logs/signalp6.%A_%a.out
#SBATCH --error=logs/signalp6.%A_%a.err

# ----------------------------------------------------------------------------------------
# Purpose : Primary secretome filter. SignalP 6 (Fast mode) flags proteins with an N-terminal
#           signal peptide; the positive set seeds every downstream step.
# Inputs  : $HELIXER/<ASM>.faa
# Outputs : $SECR/01-signalp6/<ASM>/ (SignalP 6 output) and
#           $SECR/01-signalp6/<ASM>.signalp_positive.{ids,faa}
# Tool    : SignalP 6 (conda env `signalp6`) - LICENSE-GATED, see README "Required tools"
# Usage   : sbatch workflow/10-secretome-effectome/01-signalp6.sh
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

source "$HOME/miniforge3/etc/profile.d/conda.sh"; conda activate signalp6
mkdir -p "$SECR/01-signalp6/$ASM" logs
signalp6 --fastafile "$HELIXER/$ASM.faa" --organism eukarya \
  --output_dir "$SECR/01-signalp6/$ASM" --format none --mode fast \
  --torch_num_threads "${SLURM_CPUS_PER_TASK:-2}"
# signal-peptide-positive IDs (Prediction != OTHER) -> subset the proteome
awk -F'\t' '$0!~/^#/ && $2!="OTHER"{print $1}' "$SECR/01-signalp6/$ASM/prediction_results.txt" > "$SP.ids"
seqkit grep -f "$SP.ids" "$HELIXER/$ASM.faa" > "$SP.faa"
echo "SignalP6 $ASM: $(wc -l < "$SP.ids") positive"
