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
| `targetasm.sh` | Benchmark arm 3: the targetasm pipeline itself, in three variants selected by METHOD (tea = no downsampling, tea_no_downsample / tea_downsample for MSU1). NOTE: the METHOD values still read 'tea', the pipeline's former name; they are also the output directory names under benchmarking/ and the labels analysis/benchmark.Rmd matches on, so they are deliberately left unchanged. | SLURM, 32 cores / 500 GB, one large-memory node |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| Benchmark runs | `~/project_data/downy/benchmarking/<sample>/<method>/` | One directory per arm x isolate (hifiasm, hifiasm_blastn, targetasm tea/te/full, plus MSU1 downsample variants), each with timing.tsv. | fasta-quality-table.sh | not deposited (114 GB) |
| Benchmark quality table | `data/benchmark_qc/quality_all_benchmarking.tsv (in repo)` | compleasm + QUAST metrics for every benchmark assembly. | benchmark.Rmd (Figures 3, 4) | in the repo (committed) |

## Notes

`METHOD` values are `tea`, `tea_no_downsample` and `tea_downsample`. `tea` is the pipeline's
former name; these strings are also the output **directory** names under
`project_data/downy/benchmarking/` and the labels `analysis/benchmark.Rmd` matches on. They were
deliberately left unchanged so the existing results stay readable - do not rename them without
also renaming the result directories and updating the notebook.
