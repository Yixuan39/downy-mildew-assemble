#!/bin/bash
#SBATCH --job-name=secretome-effectome
#SBATCH --array=0-3
#SBATCH -c 24

# SignalP -> TargetP/DeepTMHMM/NetGPI -> soluble secretome -> EffectorP/EffectorO.
set -euo pipefail

ASSEMBLIES=(
  Pseudoperonospora_cubensis_MSU1
  Pseudoperonospora_cubensis_SC1982
  Pseudoperonospora_humuli_OR502AA
  Peronospora_effusa_UA202013_star
)
ASM="${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}"

PD="$HOME/project_data/downy"
SOFTWARE="$HOME/software"
HELIXER="$PD/results/repeatmask-gene-prediction/focal/helixer"
SECR="$PD/results/secretome-effectome/$ASM"
SP="$SECR/signalp_positive"
SOL="$SECR/soluble_secretome.faa"

mkdir -p "$SECR/signalp" "$SECR/deeptmhmm/chunks" "$SECR/deeptmhmm/results"

mamba run -n signalp6 signalp6 \
  --fastafile "$HELIXER/$ASM.faa" --organism eukarya \
  --output_dir "$SECR/signalp" --format none --mode fast --torch_num_threads 24
grep -v '^#' "$SECR/signalp/prediction_results.txt" \
  | grep -vE $'\tOTHER(\t|$)' \
  | sed -E 's/^([^[:blank:]]+).*CS pos: ([0-9]+[-^][0-9]+).*/\1\t\2/' \
  | grep -E $'\t[0-9]+[-^](1[0-9]|2[0-9]|3[0-9]|40)$' > "$SP.tsv"
cut -f1 "$SP.tsv" | sort --parallel=24 -u > "$SP.ids"
seqkit grep -j 24 -f "$SP.ids" "$HELIXER/$ASM.faa" > "$SP.faa"

"$SOFTWARE/targetp-2.0/bin/targetp" -fasta "$SP.faa" -org non-pl -format short \
  -prefix "$SECR/$ASM"
grep -v '^#' "$SECR/${ASM}_summary.targetp2" \
  | grep -w 'mTP' \
  | sed -E 's/^([^[:space:]]+).*/\1/' \
  | sort --parallel=24 -u > "$SECR/targetp_mtp.ids"

export BIOLIB_HOME="$SECR/deeptmhmm/biolib_home"
seqkit split2 -j 24 -s 100 -O "$SECR/deeptmhmm/chunks" "$SP.faa"
for fa in "$SECR"/deeptmhmm/chunks/*.f*a; do
  ck=$(basename "$fa")
  ck="${ck%.*}"
  mkdir -p "$SECR/deeptmhmm/results/$ck"
  cp "$fa" "$SECR/deeptmhmm/results/$ck/input.faa"
  (cd "$SECR/deeptmhmm/results/$ck" && "$MAMBA" run -n deeptmhmm biolib run DTU/DeepTMHMM --fasta input.faa)
done
python3 - "$SP.tsv" "$SECR"/deeptmhmm/results/*/predicted_topologies.3line <<'PY' \
  | sort --parallel=24 -u > "$SECR/deeptmhmm_tm_after_40.ids"
import re
import sys

with open(sys.argv[1]) as handle:
    cleavage = {
        fields[0]: int(re.search(r"[-^](\d+)$", fields[1]).group(1))
        for fields in (line.strip().split("\t") for line in handle)
    }

for path in sys.argv[2:]:
    with open(path) as handle:
        header = handle.readline()
        while header:
            protein = header[1:].split()[0]
            handle.readline()
            topology = handle.readline().strip()
            matches = re.finditer(r"M+", topology)
            if any(match.start() + 1 > cleavage[protein] + 40 for match in matches):
                print(protein)
            header = handle.readline()
PY

mamba run -n netgpi netgpi -f "$SP.faa" > "$SECR/netgpi.tsv"
grep -v '^#' "$SECR/netgpi.tsv" | grep 'GPI-Anchored' \
  | cut -f1 | sort --parallel=24 -u > "$SECR/netgpi_gpi.ids"

comm -23 "$SP.ids" "$SECR/targetp_mtp.ids" \
  | comm -23 - "$SECR/deeptmhmm_tm_after_40.ids" \
  | comm -23 - "$SECR/netgpi_gpi.ids" > "$SECR/soluble_secretome.ids"
seqkit grep -j 24 -f "$SECR/soluble_secretome.ids" "$HELIXER/$ASM.faa" > "$SOL"

python3 "$SOFTWARE/EffectorP-3.0/EffectorP.py" -i "$SOL" \
  -o "$SECR/effectorp3.tsv" \
  -E "$SECR/effectorp3.faa" \
  -N "$SECR/effectorp3_noneffector.faa"
grep '^>' "$SECR/effectorp3.faa" | sed 's/^>//; s/ .*//' \
  | sort --parallel=24 -u > "$SECR/effectorp3.ids"

EFFECTORO="$SOFTWARE/oomycete-effector-prediction/machine_learning_classification"
mkdir -p "$SECR/effectoro"
(cd "$SECR/effectoro" && "$MAMBA" run -n effectoro python3 \
  "$EFFECTORO/scripts/predict_effectors.py" "$SOL" \
  "$EFFECTORO/trained_models/RF_88_best.sav")
grep '^>' "$SECR/effectoro/predicted_effectors.fasta" | sed 's/^>//; s/ .*//' \
  | sort --parallel=24 -u > "$SECR/effectoro.ids"

sort --parallel=24 -u "$SECR/effectorp3.ids" "$SECR/effectoro.ids" > "$SECR/effectome.ids"
seqkit grep -j 24 -f "$SECR/effectome.ids" "$SOL" > "$SECR/effectome.faa"
