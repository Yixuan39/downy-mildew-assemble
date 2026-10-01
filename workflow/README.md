# Workflow

`$PROJECT_DATA` defaults to `$HOME/project_data/downy`. Each directory below contains the scripts for one part of the manuscript analysis.

| Directory | Input → output |
|---|---|
| [data-acquisition/](data-acquisition/) | HiFi BAMs → FASTQ; NCBI taxonomy → oomycete taxids |
| [read-filtering-screening/](read-filtering-screening/) | FASTQ → adapter-filtered reads and read QC |
| [assembly/](assembly/) | filtered reads → targetasm assemblies |
| [benchmarking/](benchmarking/) | filtered reads → benchmark assemblies and quality table |
| [assembly-qc/](assembly-qc/) | assemblies → finalized nuclear and mitochondrial FASTA, quality tables and mitochondrial plot |
| [telomeres/](telomeres/) | finalized nuclear FASTA → telomere profiles |
| [repeatmask-gene-prediction/](repeatmask-gene-prediction/) | nuclear FASTA → masked FASTA and Helixer genes |
| [rnaseq-support/](rnaseq-support/) | RNA-seq reads and gene models → transcript support |
| [functional-annotation/](functional-annotation/) | Helixer proteins → functional annotation table |
| [synteny-orthology/](synteny-orthology/) | Helixer annotations → OrthoFinder orthogroups and GENESPACE synteny |

Read processing precedes assembly; assembly QC supplies the finalized FASTA used by downstream analyses. Benchmarking runs from the filtered reads.
