# Telomeres

`tidk-telomere-long-contigs.sh` searches finalized nuclear contigs of at least 1 Mb for TTTAGGG and calls `plot-tidk-telomeres.R`. Inputs are `results/assembly-qc/nuclear/*.fasta.gz`; profiles and the PDF go to `results/telomeres/` and are mirrored to `data/tidk_telomeres/` and `figures/tidk_telomeres/`. It needs seqkit, the `tidk` environment and R.
