#!/bin/bash
#SBATCH --job-name=secretome-effectome
#SBATCH --array=0-2
#SBATCH -c 24
#SBATCH --mem=64G

# Stage 1 of 3. Helixer proteins -> SignalP 6 (fast; cleavage 10-40 aa) -> drop TargetP mTP
# -> drop DeepTMHMM TM helices after the cleavage site. Next: netgpi.R (login node), effectorp.sh.
set -euo pipefail

ASSEMBLIES=(
  Pseudoperonospora_cubensis_MSU1
  Pseudoperonospora_cubensis_SC1982
  Pseudoperonospora_humuli_OR502AA
)
ASM="${ASSEMBLIES[${SLURM_ARRAY_TASK_ID:?Submit with sbatch --array}]}"

PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
PROTEINS="$PROJECT_DATA/results/repeatmask-gene-prediction/focal/helixer/$ASM.faa"
OUT="$PROJECT_DATA/results/secretome-effectome/$ASM"
MAMBA="$HOME/miniforge3/bin/mamba"
SEQKIT="$HOME/miniforge3/envs/downy/bin/seqkit"
DEEPTMHMM_DIR="${DEEPTMHMM_DIR:-$HOME/software/DeepTMHMM-Academic-License-v1.0}"
THREADS="${SLURM_CPUS_PER_TASK:-24}"
[[ -s "$PROTEINS" ]] || { echo "Missing input: $PROTEINS" >&2; exit 1; }
mkdir -p "$OUT/signalp6" "$OUT/targetp2"

# SignalP 6 fast mode; keep SP with the cleavage site (last SP residue) at 10-40 aa.
[[ -s "$OUT/signalp6/prediction_results.txt" ]] ||
  "$MAMBA" run -n signalp6 signalp6 --fastafile "$PROTEINS" --organism eukarya \
  --output_dir "$OUT/signalp6" --format none --mode fast --torch_num_threads "$THREADS"
awk -F'\t' '!/^#/ && $2 == "SP" && match($NF, /CS pos: [0-9]+-/) {
  cs = substr($NF, RSTART + 8, RLENGTH - 9) + 0
  if (cs >= 10 && cs <= 40) print $1 "\t" cs
}' "$OUT/signalp6/prediction_results.txt" | sort -u > "$OUT/signalp_cs10-40.tsv"
cut -f1 "$OUT/signalp_cs10-40.tsv" > "$OUT/signalp_cs10-40.ids"
"$SEQKIT" grep -f "$OUT/signalp_cs10-40.ids" "$PROTEINS" > "$OUT/signalp_cs10-40.faa"

# TargetP 2 (non-plant); remove mitochondrial transit peptides.
"$MAMBA" run -n targetp targetp -fasta "$OUT/signalp_cs10-40.faa" -org non-pl \
  -format short -prefix "$OUT/targetp2/$ASM"
awk -F'\t' '!/^#/ && $2 == "mTP" {print $1}' "$OUT/targetp2/${ASM}_summary.targetp2" \
  | sort -u > "$OUT/targetp_mtp.ids"
sort "$OUT/signalp_cs10-40.ids" | comm -23 - "$OUT/targetp_mtp.ids" > "$OUT/signalp_no_mtp.ids"
"$SEQKIT" grep -f "$OUT/signalp_no_mtp.ids" "$PROTEINS" > "$OUT/signalp_no_mtp.faa"

# DeepTMHMM 1.0 (academic standalone; loads models from its own directory). Drop proteins with
# any TM-helix residue after the SignalP cleavage site.
rm -rf "$OUT/deeptmhmm"
(cd "$DEEPTMHMM_DIR" && OMP_NUM_THREADS="$THREADS" "$HOME/miniforge3/envs/deeptmhmm/bin/python" predict.py \
  --fasta "$OUT/signalp_no_mtp.faa" --output-dir "$OUT/deeptmhmm")
rm -rf "$OUT/deeptmhmm/embeddings"
awk 'NR == FNR {cs[$1] = $2; next}
/^>/ {id = substr($1, 2); getline; getline topo; if (index(substr(topo, cs[id] + 1), "M")) print id}
' "$OUT/signalp_cs10-40.tsv" "$OUT/deeptmhmm/predicted_topologies.3line" | sort -u > "$OUT/deeptmhmm_tm.ids"
sort "$OUT/signalp_no_mtp.ids" | comm -23 - "$OUT/deeptmhmm_tm.ids" > "$OUT/signalp_no_mtp_no_tm.ids"
"$SEQKIT" grep -f "$OUT/signalp_no_mtp_no_tm.ids" "$PROTEINS" > "$OUT/signalp_no_mtp_no_tm.faa"
