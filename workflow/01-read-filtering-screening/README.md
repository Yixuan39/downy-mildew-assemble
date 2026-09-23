# Stage 01 - Read filtering and profiling

Adapter removal and read-composition profiling. HiFiAdapterFilt strips residual PacBio adapter,
and Kraken2 against the PlusPFP index quantifies how much of each library is host, microbial or
target - the numbers behind the read-composition panel and the motivation for target-aware assembly.

The `UA202013/` subdirectory holds the same two steps adapted for the public *P. effusa* reads: same
tools and databases, different input directory and no SLURM array (one file instead of three). The
`coverage-gc/` subdirectory holds the read-level coverage/GC profiling step (see below). Its
outputs are joined with the Kraken2 profile directly in `analysis/read-distribution.Rmd`.

## Scripts

| file | what it does | resources |
|---|---|---|
| `kraken2-pluspfp.sh` | Classify the adapter-filtered HiFi reads against Kraken2 PlusPFP to quantify host/microbial content before assembly (Fig. 1 read composition). | SLURM array 0-2, 24 cores / 220 GB (the PlusPFP index is loaded into RAM) |
| `UA202013/kraken2-pluspfp.sh` | Same Kraken2 PlusPFP classification for the public P. effusa reads, which live in their own directory and are a single file (no array). | SLURM, 24 cores / 220 GB |
| `UA202013/run-hifiadapterfilt.sh` | Same filtlong + HiFiAdapterFilt step for the public P. effusa reads (single file, no array). | SLURM, 32 cores |
| `run-hifiadapterfilt.sh` | Subset reads with filtlong and remove PacBio adapter sequence with HiFiAdapterFilt. | SLURM array 0-2, 32 cores |
| `coverage-gc/kat-seqkit-coverage-gc.sh` | Per-read 21-mer self-coverage (KAT sect, via `mamba run -n kat kat`) and per-read GC content (seqkit fx2tab) on the adapter-filtered HiFi reads - the coverage/GC axes behind the blob-style separability check (`analysis/read-distribution.Rmd`). | SLURM array 0-2, 32 cores / 100 GB |
| `UA202013/kat-seqkit-coverage-gc.sh` | Same KAT/seqkit coverage-GC step for the public P. effusa reads (KAT via `mamba run -n kat kat`; single file, no array). | SLURM, 32 cores / 100 GB |

## Outputs

| output | path | what it is | consumed by |
|---|---|---|---|
| Adapter-filtered reads | `~/project_data/downy/results/read-filtering-screening/reads/focal/*.filt.fastq.gz` | HiFiAdapterFilt output on the three new isolates; the reads that go into assembly. | 02-assembly |
| Adapter-filtered reads (public) | `~/project_data/downy/results/read-filtering-screening/reads/UA202013/*.filt.fastq.gz` | Same filtering for the public *P. effusa* UA202013 reads. | 02-assembly |
| Kraken2 report | `~/project_data/downy/results/read-filtering-screening/taxonomy/<sample>.kreport` | PlusPFP classification summary for each library. | read-distribution.Rmd |
| Kraken2 per-read output | `~/project_data/downy/results/read-filtering-screening/taxonomy/<sample>.kraken` | Per-read classifications used by the coverage-GC summary. | `analysis/read-distribution.Rmd` |
| Coverage-GC intermediates | `~/project_data/downy/results/read-filtering-screening/coverage-gc/` | KAT self-coverage and seqkit GC tables used by the blob plot. | `analysis/read-distribution.Rmd` |
| Coverage-GC summary | `data/blobplot-category-summary-by-isolate.tsv` | Full-read category statistics for all four isolates, written while knitting `analysis/read-distribution.Rmd`. | `analysis/read-distribution.Rmd` |
