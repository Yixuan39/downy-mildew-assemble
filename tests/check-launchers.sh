#!/usr/bin/env bash
# Check isolate dispatch and script-relative RNA-seq config without running analyses.
set -euo pipefail
repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin"
for command in nextflow python3; do
    printf '#!/bin/sh\nprintf "%%s\\n" "$@"\n' > "$work/bin/$command"
    chmod +x "$work/bin/$command"
done
export PATH="$work/bin:$PATH" PROJECT_DATA="$work/data" DB_ROOT="$work/db"

for sample in MSU1 SC1982 OR502AA UA202013; do
    case "$sample" in
        MSU1) run=Quesada_SQIIe_MSU1; target=5400000000 ;;
        SC1982) run=Quesada_SQIIe_SC1982; target=5400000000 ;;
        OR502AA) run=Quesada_SQIIe_Phumuli; target=4800000000 ;;
        UA202013) run=UA202013; target= ;;
    esac
    output="$(cd / && bash "$repo/workflow/assembly/run-targetasm.sh" "$sample")"
    [[ "$output" == *"$work/data/results/assembly/$run"* ]]
    if [[ -n "$target" ]]; then [[ "$output" == *"$target"* ]]; else [[ "$output" != *"--target_bases"* ]]; fi
done

for sample in MSU1 SC1982 OR502AA; do
    output="$(cd / && bash "$repo/workflow/rnaseq-support/run-rnaseq.sh" "$sample")"
    [[ "$output" == *"$repo/workflow/rnaseq-support/config/samplesheet_$sample.csv"* ]]
    [[ "$output" == *"$repo/workflow/rnaseq-support/config/custom.config"* ]]
done
printf 'Launcher dispatch and script-relative paths: OK\n'
