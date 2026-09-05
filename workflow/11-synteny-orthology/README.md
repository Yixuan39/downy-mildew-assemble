# Stage 11 - Orthology and synteny

OrthoFinder over the staged proteomes, producing the orthogroups that GENESPACE and the synteny
notebooks (`analysis/synteny-*.Rmd`) build on.

## Scripts

| file | what it does | resources |
|---|---|---|
| `orthofinder-contigs.sh` | Run OrthoFinder over the proteomes staged for GENESPACE, producing the orthogroups behind the synteny figures. | SLURM, 32 cores requested (OrthoFinder is called with -t 10) |

## Notes

The proteomes must already be staged into `genespace-contigs/tmp/`. The job requests 32 cores but
calls OrthoFinder with `-t 10`.
