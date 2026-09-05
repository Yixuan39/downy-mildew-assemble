# Stage 04 - Mitochondrial genomes

Identification and comparison of the mitochondrial genomes. BLASTN locates mitochondrial contigs in
each published assembly; `mt-linkage-plot.sh` then splits a curated multi-record GenBank file,
runs the pairwise BLASTN comparisons and renders the linear linkage figure with gbdraw, in a row
order that mirrors the nuclear synteny figure.

## Scripts

| file | what it does | where it runs |
|---|---|---|
| `blastn-find-mito.sh` | Locate mitochondrial contigs in each published downy mildew genome by BLASTN against a reference mitochondrial genome. | NCSU BRC, SLURM array 0-10 (one task per published genome) |
| `gbdraw-wide.py` | Thin wrapper around gbdraw 0.13 that makes the hardcoded 2000 px canvas width settable via GBDRAW_WIDTH, and the label stroke via GBDRAW_LABEL_STROKE. Called by mt-linkage-plot.sh, not run directly. | conda env 'gbdraw' |
| `mt-label-orf-only.tsv` | Label overrides for the mitochondrial plot: features to render as ORF-only. | data file |
| `mt-linkage-plot.sh` | Draw the linear synteny/linkage plot of the 14 oomycete mitochondrial genomes with gbdraw; row order mirrors the nuclear synteny figure. | local, conda env `gbdraw` |

## Notes

`mt-linkage-plot.sh` needs the `gbdraw` conda environment and calls `gbdraw-wide.py`, a local patch
that makes gbdraw's hardcoded 2000 px canvas width settable. Its long comment block documents the
gbdraw quirks it works around - read it before changing the figure.

The BLASTN subject is the published *P. cubensis* mitochondrial genome, NCBI accession KT072718.1,
kept on the cluster at `$HOME/project_data/downy/mitochondrial-genome/KT072718.1.fna`.
