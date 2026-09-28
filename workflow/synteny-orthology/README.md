# Synteny and orthology

Run in order; outputs are in `$PROJECT_DATA/results/synteny-orthology/`.

1. `stage-genomes.sh`: current Helixer GFF and proteins for the 4 focal and 11 comparison genomes → `genomes/`.
2. `run-genespace.R` (env `downy-report`): GENESPACE annotation parsing → `bed/`, `peptide/`, `tmp/`; stops before OrthoFinder.
3. `orthofinder-contigs.sh` (env `downy`): `tmp/` → `orthofinder/`.
4. `run-genespace.R` again: synteny, pan-genes and riparian data → `results/`, `syntenicHits/`, `pangenes/`, `riparian/`.

`analysis/synteny-analysis.Rmd` reads these results for the manuscript figure.
