# results/read-filtering-screening/

Adapter-filtered HiFi reads and Kraken2 taxonomic-screening reports for the three new isolates
(MSU1, OR502AA, SC1982) plus the public *P. effusa* UA202013 dataset. Produced by
`workflow/01-read-filtering-screening/` in the `downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `reads/focal/*.filt.fastq.gz` | HiFiAdapterFilt output for MSU1/OR502AA/SC1982 - the reads that go into assembly. | `results/assembly/` | not deposited (derived from SRA reads) |
| `reads/UA202013/*.filt.fastq.gz` | Same filtering for the public *P. effusa* UA202013 reads. | `results/assembly/` | not deposited (derived from public reads) |
| `taxonomy/<sample>.kreport` | Kraken2 PlusPFP classification summary quantifying host/microbial composition per library. | `read-distribution.Rmd` (Figure 1) | Zenodo (Kraken2 reports) |
| `taxonomy/<sample>.kraken` | Per-read Kraken2 classification calls; large, only the `.kreport` summary is needed downstream. | - | not deposited (intermediate, ~9 GB) |

## Notes

Kraken2 loads the whole PlusPFP index into memory - reruns need a large-memory node (~220 GB).
