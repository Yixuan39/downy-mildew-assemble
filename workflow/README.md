# workflow/

Every batch script that produced a result in the paper, in the order the analysis ran. Each stage
directory has its own README describing what it does, what it reads, what it writes and where it
runs; every script carries a `Purpose / Inputs / Outputs / Runs on / Usage` header block.

| stage | what it does |
|---|---|
| [`00-data-acquisition/`](workflow/00-data-acquisition/) | Data acquisition |
| [`01-read-filtering/`](workflow/01-read-filtering/) | Read filtering and profiling |
| [`02-assembly/`](workflow/02-assembly/) | Assembly with targetasm |
| [`03-benchmarking/`](workflow/03-benchmarking/) | Assembly benchmarking |
| [`04-mitochondrion/`](workflow/04-mitochondrion/) | Mitochondrial genomes |
| [`05-assembly-qc/`](workflow/05-assembly-qc/) | Assembly finalization (N-gap contig split) and quality assessment |
| [`06-telomeres/`](workflow/06-telomeres/) | Telomere repeats |
| [`07-repeatmask-gene-prediction/`](workflow/07-repeatmask-gene-prediction/) | Repeat masking and gene prediction |
| [`08-rnaseq-support/`](workflow/08-rnaseq-support/) | RNA-seq support for gene models |
| [`09-functional-annotation/`](workflow/09-functional-annotation/) | Functional annotation |
| [`10-secretome-effectome/`](workflow/10-secretome-effectome/) | Secretome and effector prediction |
| [`11-synteny-orthology/`](workflow/11-synteny-orthology/) | Orthology and synteny |

The numbering is the order of execution, not a dependency graph. Stages 04-11 all start from the
finished assemblies and are independent of each other, with one ordering constraint: stage 05 splits
the SC1982 N-gap contig in place, and stages 06-11 read the split assembly.
