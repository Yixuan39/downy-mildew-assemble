# Stage 05 - Assembly quality assessment

compleasm (stramenopiles/eukaryota) plus QUAST for three genome sets: the new assemblies, the
published downy mildew genomes, and the wider oomycete references. The first two use the quality
workflow shipped with targetasm and write their tables into `data/`, which is what the notebooks
read; `ref-genome-quality.sh` runs the same two tools directly through `quality-check.py` on the
cluster.

## Scripts

| file | what it does | resources |
|---|---|---|
| `qc-final-assemblies.sh` | Run the targetasm quality workflow (compleasm + QUAST) over the three final assemblies of this paper. | local or cluster; needs Nextflow with the docker profile |
| `qc-published-genomes.sh` | Same quality workflow over the published downy mildew genomes, so the new assemblies can be compared on identical metrics. | local or cluster; needs Nextflow with the docker profile |
| `quality-check.py` | Run compleasm (stramenopiles) and QUAST on one FASTA and write the merged metrics as quality.csv. Helper for ref-genome-quality.sh; not run directly. | inside the same job as ref-genome-quality.sh |
| `ref-genome-quality.sh` | Score the wider set of oomycete reference genomes with compleasm and QUAST, giving the clade-level context for the assembly quality figure. | SLURM, 24 cores |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| Final-assembly QC | `data/qc_final_assemblies/quality_final_assemblies.tsv (in repo)` | compleasm + QUAST over the three final assemblies. | final-assembly.Rmd (Table 1) | in the repo (committed) |
| Published-genome QC | `data/qc_published_genomes/quality_published_genomes.tsv (in repo)` | Same workflow over the published downy mildew genomes, for the comparison. | ref-genome-quality.Rmd (Supp Table S1) | in the repo (committed) |
| SC1982 gap coverage | `data/sc1982_gap_tail_coverage/ (in repo)` | Read-depth support across the gap on contig Pcub-SC1982_002 (target FASTA, primary-alignment BAM, depth table). | summarize-sc1982-14-gene-support.R (results text) | in the repo (committed) |
| Reference-genome QC (wider set) | `~/project_data/downy/oomycota-genome/compleasm/<genome>/quality.csv` | compleasm + QUAST over the wider oomycete reference set. NOTE: this directory is NOT present on the cluster - see stage notes; the committed Supp Table S1 comes from the published-genome QC above. | ref-genome-quality.Rmd | not deposited (intermediate; currently absent) |

## Notes

`qc-final-assemblies.sh` and `qc-published-genomes.sh` need Nextflow with the `docker` profile and a
checkout of targetasm (`TARGET_ASM_DIR`). `quality-check.py` is a helper - call it through
`ref-genome-quality.sh`, not directly.
