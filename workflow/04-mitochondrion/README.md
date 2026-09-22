# Stage 04 - Mitochondrial genomes

Identification and comparison of the mitochondrial genomes. BLASTN locates mitochondrial contigs in
each published assembly; `mt-linkage-plot.sh` then splits a curated multi-record GenBank file (`data/mt_linkage/14_mitochondrial_genomes.gb`),
runs the pairwise BLASTN comparisons and renders the linear linkage figure with gbdraw, in a row
order that mirrors the nuclear synteny figure.

## Scripts

| file | what it does | resources |
|---|---|---|
| `blastn-find-mito.sh` | Locate mitochondrial contigs in each published downy mildew genome by BLASTN against a reference mitochondrial genome. | SLURM array 0-10 (one task per published genome) |
| `gbdraw-wide.py` | Thin wrapper around gbdraw 0.13 that makes the hardcoded 2000 px canvas width settable via GBDRAW_WIDTH, and the label stroke via GBDRAW_LABEL_STROKE. Called by mt-linkage-plot.sh, not run directly. | conda env 'gbdraw' |
| `mt-label-orf-only.tsv` | Label overrides for the mitochondrial plot: features to render as ORF-only. | data file |
| `mt-linkage-plot.sh` | Draw the linear synteny/linkage plot of the 14 oomycete mitochondrial genomes with gbdraw; row order mirrors the nuclear synteny figure. | ncsu-brc login/short partition, conda env `gbdraw` |

## Outputs

| output | path | what it is | consumed by |
|---|---|---|---|
| Mitochondrial genomes | `results/assembly-qc/mitochondrial/<assembly>.fasta.gz + .mito.tsv` | Mitochondrial contigs separated from each new assembly, with the contig table. | GenBank submission |
| Mito BLAST hits (published) | `results/assembly-qc/reference-mito-hits/<genome>.mito.tsv` | BLASTN locations of mitochondrial contigs in each published genome. | mt-linkage-plot.sh |
| Mito linkage plot | `results/assembly-qc/mt-linkage/mt_linkage.{svg,pdf,png}`, mirrored to `data/mt_linkage/` | Linear linkage plot of the 14 oomycete mitochondrial genomes. | manuscript figure |
