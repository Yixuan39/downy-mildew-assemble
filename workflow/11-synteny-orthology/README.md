# Stage 11 - Orthology and synteny

OrthoFinder over the staged proteomes, producing the orthogroups that GENESPACE and the synteny
notebooks (`analysis/synteny-*.Rmd`) build on.

## Scripts

| file | what it does | resources |
|---|---|---|
| `orthofinder-contigs.sh` | Run OrthoFinder over the proteomes staged for GENESPACE, producing the orthogroups behind the synteny figures. | SLURM, 32 cores requested (OrthoFinder is called with -t 10) |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| OrthoFinder orthogroups | `~/project_data/downy/genespace-contigs/orthofinder/` | Orthogroups across the staged proteomes; the OrthoFinder species tree. | synteny-analysis.Rmd (Figure 6) | Zenodo (orthology outputs) |
| GENESPACE outputs | `~/project_data/downy/genespace-contigs/ (bed, results, syntenicHits, pangenes, riparian)` | GENESPACE synteny: syntenic hits, pangenes, and per-genome riparian plots. | synteny-analysis.Rmd (Figure 6) | Zenodo (GENESPACE outputs; large riparian/results intermediates may be trimmed) |

## Notes

The proteomes must already be staged into `genespace-contigs/tmp/`. The job requests 32 cores but
calls OrthoFinder with `-t 10`.
