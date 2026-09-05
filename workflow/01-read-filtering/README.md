# Stage 01 - Read filtering and profiling

Adapter removal and read-composition profiling. HiFiAdapterFilt strips residual PacBio adapter,
and Kraken2 against the PlusPFP index quantifies how much of each library is host, microbial or
target - the numbers behind the read-composition panel and the motivation for target-aware assembly.

The `p_effusa/` subdirectory holds the same two steps adapted for the public *P. effusa* reads: same
tools and databases, different input directory and no SLURM array (one file instead of three).

## Scripts

| file | what it does | where it runs |
|---|---|---|
| `kraken2-pluspfp.sh` | Classify the adapter-filtered HiFi reads against Kraken2 PlusPFP to quantify host/microbial content before assembly (Fig. 1 read composition). | NCSU BRC, SLURM array 0-2, 24 cores / 220 GB (the PlusPFP index is loaded into RAM) |
| `p_effusa/kraken2-pluspfp.sh` | Same Kraken2 PlusPFP classification for the public P. effusa reads, which live in their own directory and are a single file (no array). | NCSU BRC, SLURM, 24 cores / 220 GB |
| `p_effusa/run-hifiadapterfilt.sh` | Same filtlong + HiFiAdapterFilt step for the public P. effusa reads (single file, no array). | NCSU BRC, SLURM, 32 cores |
| `run-hifiadapterfilt.sh` | Subset reads with filtlong and remove PacBio adapter sequence with HiFiAdapterFilt. | NCSU BRC, SLURM array 0-2, 32 cores |

## Notes

Kraken2 loads the whole PlusPFP index into memory - the 220 GB request is not padding. Run it on
a large-memory node.
