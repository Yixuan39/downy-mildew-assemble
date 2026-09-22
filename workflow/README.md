# workflow/

Every batch script that produced a result in the paper, in the order the analysis ran. Each stage
directory has its own README describing its scripts and outputs.

| stage | what it does |
|---|---|
| [`00-data-acquisition/`](00-data-acquisition/) | Data acquisition |
| [`01-read-filtering-screening/`](01-read-filtering-screening/) | Read filtering and profiling |
| [`02-assembly/`](02-assembly/) | Assembly with targetasm |
| [`03-benchmarking/`](03-benchmarking/) | Assembly benchmarking |
| [`04-mitochondrion/`](04-mitochondrion/) | Mitochondrial genomes |
| [`05-assembly-qc/`](05-assembly-qc/) | Assembly finalization and quality assessment |
| [`06-telomeres/`](06-telomeres/) | Telomere repeats |
| [`07-repeatmask-gene-prediction/`](07-repeatmask-gene-prediction/) | Repeat masking and gene prediction |
| [`08-annotation/`](08-annotation/) | RNA-seq support, functional annotation, secretome and effectome |
| [`09-synteny-orthology/`](09-synteny-orthology/) | Orthology and synteny |

The numbering is the order of execution, not a dependency graph. Stages 04-09 all start from the
finished assemblies and are independent of each other, with one ordering constraint: stage 05 splits
the SC1982 N-gap contig in place, and stages 06-09 read the split assembly.
