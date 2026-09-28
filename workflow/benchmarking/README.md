# Assembly benchmarking

- `submit-all.sh` runs the hifiasm, hifiasm plus BLASTN, and targetasm comparisons on the selected `BENCHMARK_NODE`; outputs are in `results/benchmarking/<isolate>/{hifiasm,hifiasm_blastn,targetasm_no_downsample,targetasm_downsample}/` (downsampling for MSU1 only).
- `fasta-quality-table.sh` writes `data/benchmark_qc/quality_all_benchmarking.tsv` from the benchmark assemblies.
