# Stage 08 - RNA-seq support for gene models

nf-core/rnaseq 3.26.0 run against each new assembly, giving transcript-level evidence for the
Helixer gene models. One launcher per isolate; samplesheets and the cluster resource config live in
`workflow/08-rnaseq-support/config/`.

## Scripts

| file | what it does | resources |
|---|---|---|
| `run-nfcore-rnaseq-MSU1.sh` | Run nf-core/rnaseq 3.26.0 against the MSU1 assembly to get transcript-level evidence for the predicted genes. | login node - Nextflow submits its own SLURM jobs; apptainer profile |
| `run-nfcore-rnaseq-OR502AA.sh` | Run nf-core/rnaseq 3.26.0 against the OR502AA assembly. | login node - Nextflow submits its own SLURM jobs; apptainer profile |
| `run-nfcore-rnaseq-SC1982.sh` | Run nf-core/rnaseq 3.26.0 against the SC1982 assembly. | login node - Nextflow submits its own SLURM jobs; apptainer profile |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| nf-core/rnaseq output | `the outdir set inside each run script` | Transcript-level RNA-seq evidence (alignments, quantification, QC) per isolate; supports the annotation. | gene-annotation-report.Rmd (Figure 5 RNA-seq support) | not deposited (large intermediate; raw RNA-seq reads go to SRA) |

## Notes

Like stage 02 these are Nextflow launchers - run them from a login node, not through `sbatch`.
Paths to the samplesheet and config are repo-relative, so run them from the repository root.
