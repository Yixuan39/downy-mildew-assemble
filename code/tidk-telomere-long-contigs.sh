#!/usr/bin/env bash
set -euo pipefail

out="data/tidk_telomeres"
mkdir -p "${out}"

for fasta in /Users/yixuanyang/project_data/downy/contigs-renamed/cleaned/*.fasta.gz; do
    sample="$(basename "${fasta}" .fasta.gz)"
    dir="${out}/${sample}"
    mkdir -p "${dir}"

    seqkit seq -g -m 1000000 -w 0 "${fasta}" > "${dir}/${sample}.fa"
    seqkit fx2tab -n -l "${dir}/${sample}.fa" > "${dir}/lengths.tsv"
    tidk search -s TTTAGGG -w 10000 -o "${sample}.TTTAGGG" -d "${dir}" "${dir}/${sample}.fa"
done

Rscript code/plot-tidk-telomeres.R
