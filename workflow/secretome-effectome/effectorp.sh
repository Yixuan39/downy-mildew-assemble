#!/bin/bash
#SBATCH --job-name=effectorp
#SBATCH --array=0-2
#SBATCH -c 4
#SBATCH --mem=8G

# Stage 3 of 3. Drop NetGPI GPI-anchored proteins -> soluble secretome -> EffectorP 3.0
# (default mode, fungi + oomycetes).
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
SEQKIT="$HOME/miniforge3/envs/downy/bin/seqkit"
EFFECTORP="${EFFECTORP:-$HOME/software/EffectorP-3.0/EffectorP.py}"
[[ -s "$OUT/netgpi.tsv" ]] || { echo "Run netgpi.R first: $OUT/netgpi.tsv" >&2; exit 1; }

awk -F'\t' 'NR > 1 && $3 == "TRUE" {print $1}' "$OUT/netgpi.tsv" | sort -u > "$OUT/netgpi_gpi.ids"
comm -23 "$OUT/signalp_no_mtp_no_tm.ids" "$OUT/netgpi_gpi.ids" > "$OUT/soluble_secretome.ids"
"$SEQKIT" grep -f "$OUT/soluble_secretome.ids" "$PROTEINS" > "$OUT/soluble_secretome.faa"

python3 "$EFFECTORP" -i "$OUT/soluble_secretome.faa" -o "$OUT/effectorp3.tsv" \
  -E "$OUT/effectorp3_effectors.faa"
