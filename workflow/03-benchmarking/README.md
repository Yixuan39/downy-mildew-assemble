# Stage 03 - Assembly benchmarking

The three-arm comparison behind the benchmarking figure and table: plain hifiasm, hifiasm plus a
BLASTN contaminant-removal pass, and targetasm. Each arm writes its own `timing.tsv`, and
`fasta-quality-table.sh` collects every resulting assembly into one metrics table.

All arms are submitted to the same node (`-p bigmem -w node95`) by `submit-all.sh` so that the
wall-time comparison is not confounded by hardware.

## Scripts

| file | what it does | where it runs |
|---|---|---|
| `fasta-quality-table.sh` | Collect every benchmark assembly into one directory and run the targetasm quality workflow over all of them, producing the single table analysis/benchmark.Rmd reads. | local or cluster; needs Nextflow with the docker profile |
| `hifiasm-blastn.sh` | Benchmark arm 2: hifiasm followed by a BLASTN-based contaminant removal pass (the conventional post-hoc approach targetasm is compared against). | NCSU BRC, SLURM, 32 cores, -p bigmem -w node95 |
| `hifiasm.sh` | Benchmark arm 1: hifiasm on the raw filtered reads, with no contamination handling. Records wall time to timing.tsv. | NCSU BRC, SLURM, 32 cores, submitted to -p bigmem -w node95 so all three arms share one node |
| `submit-all.sh` | Submit all seven benchmark runs (3 arms x 2 isolates, plus the two MSU1 downsampling variants) to the same node so the wall-time comparison is fair. | NCSU BRC login node |
| `targetasm.sh` | Benchmark arm 3: the targetasm pipeline itself, in three variants selected by METHOD (tea = no downsampling, tea_no_downsample / tea_downsample for MSU1). NOTE: the METHOD values still read 'tea', the pipeline's former name; they are also the output directory names under benchmarking/ and the labels analysis/benchmark.Rmd matches on, so they are deliberately left unchanged. | NCSU BRC, SLURM, 32 cores / 500 GB, -p bigmem -w node95 |

## Notes

`METHOD` values are `tea`, `tea_no_downsample` and `tea_downsample`. `tea` is the pipeline's
former name; these strings are also the output **directory** names under
`project_data/downy/benchmarking/` and the labels `analysis/benchmark.Rmd` matches on. They were
deliberately left unchanged so the existing results stay readable - do not rename them without
also renaming the result directories and updating the notebook.
