# Stage 01 - Read filtering and profiling

Adapter removal and read-composition profiling. HiFiAdapterFilt strips residual PacBio adapter,
and Kraken2 against the PlusPFP index quantifies how much of each library is host, microbial or
target - the numbers behind the read-composition panel and the motivation for target-aware assembly.

The `UA202013/` subdirectory holds the same two steps adapted for the public *P. effusa* reads: same
tools and databases, different input directory and no SLURM array (one file instead of three).

## Scripts

| file | what it does | resources |
|---|---|---|
| `kraken2-pluspfp.sh` | Classify the adapter-filtered HiFi reads against Kraken2 PlusPFP to quantify host/microbial content before assembly (Fig. 1 read composition). | SLURM array 0-2, 24 cores / 220 GB (the PlusPFP index is loaded into RAM) |
| `UA202013/kraken2-pluspfp.sh` | Same Kraken2 PlusPFP classification for the public P. effusa reads, which live in their own directory and are a single file (no array). | SLURM, 24 cores / 220 GB |
| `UA202013/run-hifiadapterfilt.sh` | Same filtlong + HiFiAdapterFilt step for the public P. effusa reads (single file, no array). | SLURM, 32 cores |
| `run-hifiadapterfilt.sh` | Subset reads with filtlong and remove PacBio adapter sequence with HiFiAdapterFilt. | SLURM array 0-2, 32 cores |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| Adapter-filtered reads | `~/project_data/downy/GSL_Data/fastq/filtered/*.filt.fastq.gz` | HiFiAdapterFilt output on the three new isolates; the reads that go into assembly. | 02-assembly | not deposited (derived from SRA reads) |
| Adapter-filtered reads (public) | `~/project_data/downy/UA202013/filtered/*.filt.fastq.gz` | Same filtering for the public P. effusa UA202013 reads. | 02-assembly | not deposited (derived from public reads) |
| Kraken2 report | `~/project_data/downy/k2_pfp/<sample>.kreport` | PlusPFP classification summary quantifying host/microbial composition per library. | read-distribution.Rmd (Figure 1) | Zenodo (Kraken2 reports) |
| Kraken2 per-read output | `~/project_data/downy/k2_pfp/<sample>.kraken` | Per-read classification calls; large, only the .kreport summary is needed downstream. | - | not deposited (intermediate, ~9 GB) |

## Notes

Kraken2 loads the whole PlusPFP index into memory - the 220 GB request is not padding. Run it on
a large-memory node.
