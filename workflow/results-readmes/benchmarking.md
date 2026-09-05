# results/benchmarking/

The three-arm assembler comparison behind the benchmarking figure and table: plain hifiasm,
hifiasm plus a BLASTN contaminant-removal pass, and targetasm. Produced by
`workflow/03-benchmarking/` in the `downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `<sample>/<method>/` | One directory per arm x isolate (`hifiasm`, `hifiasm_blastn`, `tea`/`tea_no_downsample`/`tea_downsample`), each with `timing.tsv`. | `fasta-quality-table.sh` (repo) | not deposited (114 GB) |

Per-assembly compleasm + QUAST metrics collected across every benchmark run are committed in the
repo at `data/benchmark_qc/quality_all_benchmarking.tsv`, not duplicated here.

## Notes

`tea`, `tea_no_downsample` and `tea_downsample` are directory-name/method labels left over from
targetasm's former name (`TEA`). They are also the labels `analysis/benchmark.Rmd` matches on -
do not rename them without also renaming these directories and updating the notebook.
