# Stage 09 - Functional annotation

Four independent functional-annotation sources over the Helixer proteomes: eggNOG-mapper,
InterProScan, DIAMOND blastp against nr, and ProteInfer. `analysis/gene_annotation_report.Rmd`
combines them into the per-gene support summary reported in the paper.

## Scripts

| file | what it does | resources |
|---|---|---|
| `protein-diamond-blastp.sh` | DIAMOND blastp of the Helixer proteins against NCBI nr, for the homology-based half of the annotation support table. | SLURM array 0-3, 32 cores |
| `protein-eggnog.sh` | Functionally annotate the Helixer proteins with eggNOG-mapper (DIAMOND search mode). | SLURM array 0-3, 24 cores |
| `protein-interproscan.sh` | Assign InterPro domains and GO terms to the Helixer proteins with InterProScan 5.77-108.0 in a container. | SLURM array 0-3, 24 cores, apptainer |
| `protein-proteinfer.sh` | Predict protein function with ProteInfer, the fourth independent annotation source in the gene-support comparison. | SLURM array 0-3, 24 cores |

## Notes

All four are SLURM arrays over the four proteomes and expect their databases under `$HOME/db`
(`eggnog`, `interproscan-5.77-108.0`, `nr.dmnd`).
