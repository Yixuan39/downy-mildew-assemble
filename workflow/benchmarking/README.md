# Assembly benchmarking

- `submit-all.sh` runs the hifiasm, hifiasm plus BLASTN, and targetasm comparisons on the selected `BENCHMARK_NODE`; outputs are in `results/benchmarking/`.
- `fasta-quality-table.sh` writes `data/benchmark_qc/quality_all_benchmarking.tsv` from the benchmark assemblies.
