# $PROJECT_DATA/downy

This tree is produced by `workflow/prepare-results.sh` (see the `downy-mildew-assemble` repo) and
mirrors the repo's `workflow/` stages, without the numeric prefixes:

| folder | corresponds to | what's in it |
|---|---|---|
| `inputs/` | (raw data staging) | Raw HiFi/RNA-seq reads and reference genomes, symlinked back to `archive/previous-results/`. Never modified. |
| `results/read-filtering-screening/` | `workflow/01-read-filtering-screening/` | Filtered reads and Kraken2 taxonomic-screening reports. |
| `results/assembly/` | `workflow/02-assembly/` | targetasm working directories for the four assemblies. |
| `results/benchmarking/` | `workflow/03-benchmarking/` | Benchmark assemblies and timings across assemblers. |
| `results/assembly-preparation/` | `workflow/04-mitochondrion/` + `workflow/05-assembly-qc/` (renaming/splitting) | Renamed contigs, nuclear/mitochondrial split, and the reference-genome mitochondrial BLASTN hits / linkage figure. |
| `results/assembly-qc/` | `workflow/05-assembly-qc/` | Final nuclear assemblies (post N-gap split) plus compleasm/QUAST quality metrics. |
| `results/telomeres/` | `workflow/06-telomeres/` | tidk telomere-repeat search output and the summary plot. |
| `results/repeatmask-gene-prediction/` | `workflow/07-repeatmask-gene-prediction/` | RepeatModeler/RepeatMasker hardmasked genomes and Helixer gene models + predicted proteomes, for both the focal assemblies and the published reference genomes. |
| `results/rnaseq-support/` | `workflow/08-rnaseq-support/` | nf-core/rnaseq output per isolate, supporting the gene models. |
| `results/functional-annotation/` | `workflow/09-functional-annotation/` | eggNOG-mapper, InterProScan, and DIAMOND-blastp-vs-nr tables. |
| `results/secretome-effectome/` | `workflow/10-secretome-effectome/` | SignalP6/TargetP/DeepTMHMM/NetGPI/DeepLoc and RxLR/WY-motif effector-candidate tables. |
| `results/synteny-orthology/` | `workflow/11-synteny-orthology/` | OrthoFinder orthogroups and GENESPACE synteny output. |
| `archive/previous-results/` | (history) | The original, pre-reorganization tree, preserved as-is. `results/` holds independent copies of stages 0-3 from here; `inputs/` still symlinks to it for raw data. |

Each `results/<stage>/` folder has its own `README.md` describing its specific contents. See the
`downy-mildew-assemble` repo's `workflow/<NN>-<stage>/README.md` for the scripts that produced them
and `DATA_DEPOSITION.md` for what ultimately gets deposited to NCBI/Zenodo vs. kept cluster-side only.
