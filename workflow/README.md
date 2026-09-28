# Analysis workflow

Scripts use `$PROJECT_DATA` (default `$HOME/project_data/downy`) for cluster inputs and large results. Run SLURM scripts with `sbatch`; run the Nextflow launchers from a login node. Commands and outputs are listed in each script.

| workflow directory | main input → output |
|---|---|
| [data-acquisition/](data-acquisition/) | HiFi BAMs → FASTQ; NCBI taxonomy → oomycete taxids |
| [read-filtering-screening/](read-filtering-screening/) | HiFi FASTQ → adapter-filtered reads, Kraken2 and coverage/GC tables |
| [assembly/](assembly/) | filtered reads → `results/assembly/` targetasm runs |
| [benchmarking/](benchmarking/) | filtered reads → `results/benchmarking/` comparisons |
| [assembly-qc/](assembly-qc/) | assemblies → finalized nuclear/mitochondrial FASTA, QC tables and mitochondrial plot |
| [telomeres/](telomeres/) | finalized nuclear FASTA → `results/telomeres/` |
| [repeatmask-gene-prediction/](repeatmask-gene-prediction/) | finalized nuclear FASTA → masked FASTA and Helixer gene models |
| [rnaseq-support/](rnaseq-support/) | RNA-seq reads and gene models → `results/rnaseq-support/` |
| [functional-annotation/](functional-annotation/) | Helixer proteins → `results/functional-annotation/` and derived annotation table |
| [synteny-orthology/](synteny-orthology/) | staged proteomes → `results/synteny-orthology/` |

Run data acquisition and read filtering before assembly. Assembly QC finalizes the nuclear FASTA used by telomere searches, masking, gene prediction and later analyses. Benchmarking branches from filtered reads. RNA-seq support, functional annotation and orthology use the resulting gene models. `summarize-functions.R` also reads existing RNA-seq and secretome/effectome result files.
