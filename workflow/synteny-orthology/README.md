# Synteny and orthology

`orthofinder-contigs.sh` runs OrthoFinder over proteomes already staged under `$PROJECT_DATA/results/synteny-orthology/tmp/`. It writes orthogroups under `results/synteny-orthology/orthofinder/` for the GENESPACE analysis in `analysis/synteny-analysis.Rmd`. Submit it with SLURM after staging the proteomes.
