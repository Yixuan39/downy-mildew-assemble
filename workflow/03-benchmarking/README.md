# Stage 03 - Assembly benchmarking

The three-arm comparison behind the benchmarking figure and table: plain hifiasm, hifiasm plus a
BLASTN contaminant-removal pass, and targetasm. Each arm writes its own `timing.tsv`, and
`fasta-quality-table.sh` collects every resulting assembly into one metrics table.

All arms are submitted to the same node (`one large-memory node`) by `submit-all.sh` so that the
wall-time comparison is not confounded by hardware.

## Scripts

| file | what it does | resources |
|---|---|---|
| `fasta-quality-table.sh` | Collect every benchmark assembly into one directory and run the targetasm quality workflow over all of them, producing the single table analysis/benchmark.Rmd reads. | local or cluster; needs Nextflow with the docker profile |
| `hifiasm-blastn.sh` | Benchmark arm 2: hifiasm followed by a BLASTN-based contaminant removal pass (the conventional post-hoc approach targetasm is compared against). | SLURM, 32 cores, one large-memory node |
| `hifiasm.sh` | Benchmark arm 1: hifiasm on the raw filtered reads, with no contamination handling. Records wall time to timing.tsv. | SLURM, 32 cores, all three arms on one large-memory node |
| `submit-all.sh` | Submit all seven benchmark runs (3 arms x 2 isolates, plus the two MSU1 downsampling variants) to the same node so the wall-time comparison is fair. | login node |
| `targetasm.sh` | Benchmark arm 3: the targetasm pipeline itself, in the variants selected by `METHOD`. | SLURM, 32 cores / 500 GB, one large-memory node |

## Outputs

| output | path | what it is | consumed by |
|---|---|---|---|
| Benchmark runs | `~/project_data/downy/results/benchmarking/<sample>/<method>/` | One directory per arm and isolate, each with `timing.tsv`. | fasta-quality-table.sh |
| Benchmark quality table | `data/benchmark_qc/quality_all_benchmarking.tsv` | compleasm and QUAST metrics for every benchmark assembly. | benchmark.Rmd |

## Notes

`METHOD` values are `tea`, `tea_no_downsample` and `tea_downsample`; they are existing output
directory names and analysis labels.
