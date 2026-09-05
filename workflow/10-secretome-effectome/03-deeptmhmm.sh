#!/bin/bash
#SBATCH --job-name=deeptmhmm
#SBATCH --array=0-3
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --output=logs/deeptmhmm.%A_%a.out
#SBATCH --error=logs/deeptmhmm.%A_%a.err

# ----------------------------------------------------------------------------------------
# Purpose : Screen the SignalP-positive set for transmembrane helices (DeepTMHMM), in 100-seq
#           chunks. Proteins with a TM helix downstream of the signal-peptide cleavage site are
#           removed from the soluble secretome (see 05-combine).
# Inputs  : $SP.faa  (from 01-signalp6.sh)
# Outputs : $SECR/03-deeptmhmm/<ASM>/results/<chunk>/predicted_topologies.3line;
#           $SECR/03-deeptmhmm/<ASM>.tm.ids (proteins with >=1 TM helix, to remove)
# Tool    : DeepTMHMM via BioLib (conda env `deeptmhmm`, `pip install pybiolib`) - internet + BioLib token
# NOTE    : Methods restricts removal to TM helices >40 aa downstream of the cleavage site; the
#           .tm.ids list here is all TMhelix-bearing proteins. Refine against the SignalP cleavage
#           position once the tools are installed (see README).
# Usage   : sbatch workflow/10-secretome-effectome/03-deeptmhmm.sh
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

source "$HOME/miniforge3/etc/profile.d/conda.sh"; conda activate deeptmhmm
export BIOLIB_HOME="$SECR/03-deeptmhmm/biolib_home"; mkdir -p "$BIOLIB_HOME"
CH="$SECR/03-deeptmhmm/$ASM/chunks_100"; OB="$SECR/03-deeptmhmm/$ASM/results"
mkdir -p "$CH" "$OB" logs
seqkit split2 -s 100 -O "$CH" "$SP.faa"
for fa in "$CH"/*.f*a; do
  [ -e "$fa" ] || continue
  ck=$(basename "$fa"); ck="${ck%.*}"; od="$OB/$ck"; mkdir -p "$od"
  [ -f "$od/COMPLETED.ok" ] && continue
  cp "$fa" "$od/input.faa"; ( cd "$od" && biolib run DTU/DeepTMHMM --fasta input.faa ) && touch "$od/COMPLETED.ok" || { echo "FAILED $ck"; break; }
done
awk '/^>/{id=substr($1,2)} /TMhelix/{print id}' "$OB"/*/predicted_topologies.3line 2>/dev/null | sort -u > "$SECR/03-deeptmhmm/$ASM.tm.ids" || true
