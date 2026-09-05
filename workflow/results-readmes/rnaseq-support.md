# results/rnaseq-support/

nf-core/rnaseq 3.26.0 output per isolate, giving transcript-level evidence for the Helixer gene
models. Produced by `workflow/08-rnaseq-support/` in the `downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `<isolate>/` | Full nf-core/rnaseq output (alignments, quantification, QC) for MSU1, OR502AA, and SC1982. | `gene-annotation-report.Rmd` (Figure 5 RNA-seq support) | not deposited (large intermediate; raw RNA-seq reads go to SRA) |

## Notes

These are Nextflow launchers - run from a login node (Nextflow submits its own SLURM jobs), not
via `sbatch`. Paths to the samplesheet and cluster resource config are repo-relative
(`workflow/08-rnaseq-support/config/`), so launch from the repository root.
