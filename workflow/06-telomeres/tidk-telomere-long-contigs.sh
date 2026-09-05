#!/usr/bin/env bash

# Purpose : Search contigs >=1 Mb for the plant/oomycete telomere repeat TTTAGGG with tidk, then call the
#           plotting script.
# Inputs  : ${PROJECT_DATA}/results/assembly-qc/nuclear/*.fasta.gz
# Outputs : ${PROJECT_DATA}/results/telomeres/<sample>/ (lengths.tsv, tidk search output) and
#           ${PROJECT_DATA}/results/telomeres/figures/; the per-sample output and figure are also
#           mirrored into data/tidk_telomeres/ and figures/tidk_telomeres/ in the repo (committed).
# Runs on : ncsu-brc login node or the short partition; needs the `tidk` conda env and R (ggplot2).
# Usage   : bash workflow/06-telomeres/tidk-telomere-long-contigs.sh
set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

out="${PROJECT_DATA}/results/telomeres"
mkdir -p "${out}"

for fasta in "${PROJECT_DATA}/results/assembly-qc/nuclear"/*.fasta.gz; do
    sample="$(basename "${fasta}" .fasta.gz)"
    dir="${out}/${sample}"
    mkdir -p "${dir}"

    seqkit seq -m 1000000 -w 0 "${fasta}" > "${dir}/${sample}.fa"
    seqkit fx2tab -n -l "${dir}/${sample}.fa" > "${dir}/lengths.tsv"
    tidk search -s TTTAGGG -w 10000 -o "${sample}.TTTAGGG" -d "${dir}" "${dir}/${sample}.fa"
done

Rscript "$REPO_ROOT/workflow/06-telomeres/plot-tidk-telomeres.R"

# mirror the per-sample output + figure into the repo, which is what's actually committed
mkdir -p "$REPO_ROOT/data/tidk_telomeres" "$REPO_ROOT/figures/tidk_telomeres"
for dir in "${out}"/*/; do
    sample="$(basename "${dir}")"
    [[ "${sample}" == figures ]] && continue
    mkdir -p "$REPO_ROOT/data/tidk_telomeres/${sample}"
    cp "${dir}/${sample}.TTTAGGG_telomeric_repeat_windows.tsv" "${dir}/${sample}.TTAGGG_telomeric_repeat_windows.tsv" \
       "${dir}/lengths.tsv" "$REPO_ROOT/data/tidk_telomeres/${sample}/" 2>/dev/null || true
done
cp "${out}/figures/tidk_telomere_profiles_top20_contigs.pdf" "$REPO_ROOT/figures/tidk_telomeres/"
echo "-> mirrored into $REPO_ROOT/data/tidk_telomeres/ and figures/tidk_telomeres/ (git add + commit there to update the manuscript figure)"
