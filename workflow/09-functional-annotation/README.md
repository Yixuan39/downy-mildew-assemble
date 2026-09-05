# Stage 09 - Functional annotation

Three independent functional-annotation sources over the Helixer proteomes: eggNOG-mapper,
InterProScan, and DIAMOND blastp against nr. `analysis/gene-annotation-report.Rmd`
combines them into the per-gene support summary reported in the paper.

## Scripts

| file | what it does | resources |
|---|---|---|
| `protein-diamond-blastp.sh` | DIAMOND blastp of the Helixer proteins against NCBI nr, for the homology-based half of the annotation support table. | SLURM array 0-3, 32 cores |
| `protein-eggnog.sh` | Functionally annotate the Helixer proteins with eggNOG-mapper (DIAMOND search mode). | SLURM array 0-3, 24 cores |
| `protein-interproscan.sh` | Assign InterPro domains and GO terms to the Helixer proteins with InterProScan 5.77-108.0 in a container. | SLURM array 0-3, 24 cores, apptainer |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| DIAMOND blastp | `~/project_data/downy/contigs-renamed/blastp/<genome>.tsv` | Helixer proteins vs NCBI nr (homology half of the annotation). | gene-annotation-report.Rmd (Table 2, Figure 5) | Zenodo (functional-annotation tables) |
| eggNOG-mapper | `~/project_data/downy/contigs-renamed/eggnog-mapper/<genome>/` | eggNOG orthology-based functional annotation. NOTE: four empty <genome>_tmp dirs (cleanup: delete). | gene-annotation-report.Rmd | Zenodo (functional-annotation tables) |
| InterProScan | `~/project_data/downy/contigs-renamed/interproscan/<genome>/` | InterPro domains and GO terms. NOTE: four empty <genome>_tmp dirs (cleanup: delete). | gene-annotation-report.Rmd | Zenodo (functional-annotation tables) |

## Notes

All three are SLURM arrays over the four proteomes and expect their databases under `$HOME/db`
(`eggnog`, `interproscan-5.77-108.0`, `nr.dmnd`).
