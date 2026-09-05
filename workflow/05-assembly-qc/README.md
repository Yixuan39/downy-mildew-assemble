# Stage 05 - Assembly quality assessment

compleasm (stramenopiles/eukaryota) plus QUAST for three genome sets: the new assemblies, the
published downy mildew genomes, and the wider oomycete references. The first two use the quality
workflow shipped with targetasm and write their tables into `data/`, which is what the notebooks
read; `ref-genome-quality.sh` runs the same two tools directly through `quality-check.py` on the
cluster.

## Scripts

| file | what it does | where it runs |
|---|---|---|
| `qc-final-assemblies.sh` | Run the targetasm quality workflow (compleasm + QUAST) over the three final assemblies of this paper. | local or cluster; needs Nextflow with the docker profile |
| `qc-published-genomes.sh` | Same quality workflow over the published downy mildew genomes, so the new assemblies can be compared on identical metrics. | local or cluster; needs Nextflow with the docker profile |
| `quality-check.py` | Run compleasm (stramenopiles) and QUAST on one FASTA and write the merged metrics as quality.csv. Helper for ref-genome-quality.sh; not run directly. | NCSU BRC, inside the same job as ref-genome-quality.sh |
| `ref-genome-quality.sh` | Score the wider set of oomycete reference genomes with compleasm and QUAST, giving the clade-level context for the assembly quality figure. | NCSU BRC, SLURM, 24 cores |

## Notes

`qc-final-assemblies.sh` and `qc-published-genomes.sh` need Nextflow with the `docker` profile and a
checkout of targetasm (`TARGET_ASM_DIR`). `quality-check.py` is a helper - call it through
`ref-genome-quality.sh`, not directly.
