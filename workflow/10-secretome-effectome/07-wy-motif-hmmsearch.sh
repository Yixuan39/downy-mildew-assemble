#!/bin/bash
#SBATCH --job-name=wy-hmmsearch
#SBATCH --array=0-3
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=1:00:00
#SBATCH --output=logs/wy.%A_%a.out
#SBATCH --error=logs/wy.%A_%a.err

# ----------------------------------------------------------------------------------------
# Purpose : Identify WY-domain effector candidates in the soluble secretome with the published WY
#           HMM (Boutemy et al. 2011) using HMMER (Methods: HMMER v3.4).
# Inputs  : $SECR/05-soluble-secretome/<ASM>_soluble_secretome.faa; WY HMM (see README)
# Outputs : $SECR/07-effectors/<ASM>/WY.{tblout,domtblout,output}
# Tool    : HMMER (conda env `hmmer`)
# Usage   : sbatch workflow/10-secretome-effectome/07-wy-motif-hmmsearch.sh
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

source "$HOME/miniforge3/etc/profile.d/conda.sh"; conda activate hmmer
HMM="$SECR/WY_motif.hmm"
OUT="$SECR/07-effectors/$ASM"; mkdir -p "$OUT" logs
hmmsearch --tblout "$OUT/WY.tblout" --domtblout "$OUT/WY.domtblout" -o "$OUT/WY.output" \
  "$HMM" "$SECR/05-soluble-secretome/${ASM}_soluble_secretome.faa"
