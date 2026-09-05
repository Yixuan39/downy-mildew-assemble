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

Paths are under `$PROJECT_DATA` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| Mitochondrial genomes | `results/assembly-preparation/mitochondrial/<assembly>.fasta.gz + .mito.tsv` | Mitochondrial contigs separated from each new assembly, with the contig table. (Source dir on the cluster is misspelled `contigs-renamed/mitochondiral/` — kept as-is in archive/, copied under the corrected name in results/.) | GenBank submission | NCBI GenBank (organelle genomes) |
| Mito BLAST hits (published) | `results/assembly-preparation/reference-mito-hits/<genome>.mito.tsv` | BLASTN locations of mitochondrial contigs in each published genome, against the KT072718.1 reference. | mt-linkage-plot.sh | not deposited (intermediate) |
| Mito linkage plot | `results/assembly-preparation/mt-linkage/mt_linkage.{svg,pdf,png}`, mirrored to `data/mt_linkage/ (in repo)` | Linear synteny/linkage plot of the 14 oomycete mitochondrial genomes. | manuscript figure | in the repo (committed) |

## Notes

`mt-linkage-plot.sh` runs on the cluster now, needs the `gbdraw` conda environment, and calls
`gbdraw-wide.py`, a local patch that makes gbdraw's hardcoded 2000 px canvas width settable. Its long
comment block documents the gbdraw quirks it works around - read it before changing the figure. It
mirrors its final figure + split/blast intermediates back into the repo's `data/mt_linkage/` at the
end, which is what actually gets committed for the manuscript figure.

The BLASTN subject is the published *P. cubensis* mitochondrial genome, NCBI accession KT072718.1,
kept on the cluster at `$PROJECT_DATA/inputs/reference-mitochondria/KT072718.1.fna`.
