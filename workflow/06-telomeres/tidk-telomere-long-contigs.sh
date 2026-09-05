#!/usr/bin/env bash

# Purpose : Search contigs >=1 Mb for the plant/oomycete telomere repeat TTTAGGG with tidk, then call the
#           plotting script. Reads assemblies from a LOCAL path - edit the fasta glob before running
#           elsewhere.
# Inputs  : contigs-renamed/cleaned/*.fasta.gz (currently ${PROJECT_DATA}/...)
# Outputs : data/tidk_telomeres/<sample>/ (lengths.tsv, tidk search output) and figures/tidk_telomeres/
# Runs on : local macOS workstation
# Usage   : bash workflow/06-telomeres/tidk-telomere-long-contigs.sh
set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

out="$REPO_ROOT/data/tidk_telomeres"
mkdir -p "${out}"

for fasta in "${PROJECT_DATA}/results/assembly-qc/nuclear"/*.fasta.gz; do
    sample="$(basename "${fasta}" .fasta.gz)"
    dir="${out}/${sample}"
    mkdir -p "${dir}"

    seqkit seq -m 1000000 -w 0 "${fasta}" > "${dir}/${sample}.fa"
    seqkit fx2tab -n -l "${dir}/${sample}.fa" > "${dir}/lengths.tsv"
    tidk search -s TTTAGGG -w 10000 -o "${sample}.TTTAGGG" -d "${dir}" "${dir}/${sample}.fa"
done

cd "$REPO_ROOT"
Rscript workflow/06-telomeres/plot-tidk-telomeres.R
