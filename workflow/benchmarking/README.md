# Assembly benchmarking

`submit-all.sh` submits the hifiasm, hifiasm plus BLASTN, and targetasm comparisons to one selected high-memory node. Set `BENCHMARK_NODE` first. The arm scripts write assemblies and `timing.tsv` under `$PROJECT_DATA/results/benchmarking/<sample>/<method>/`.

`fasta-quality-table.sh` collects seven benchmark FASTAs and runs the targetasm quality workflow, writing `data/benchmark_qc/quality_all_benchmarking.tsv`. The existing `tea` method names are retained because the result directories and `analysis/benchmark.Rmd` use them.
