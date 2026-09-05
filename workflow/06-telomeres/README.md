# Stage 06 - Telomere repeats

tidk search for the TTTAGGG telomere repeat along every contig >= 1 Mb, and the plot of repeat
density along those contigs that supports the chromosome-scale claim.

## Scripts

| file | what it does | resources |
|---|---|---|
| `plot-tidk-telomeres.R` | Plot the tidk telomere-repeat density along each long contig. Called at the end of tidk-telomere-long-contigs.sh. | local, R |
| `tidk-telomere-long-contigs.sh` | Search contigs >=1 Mb for the plant/oomycete telomere repeat TTTAGGG with tidk, then call the plotting script. Reads assemblies from a LOCAL path - edit the fasta glob before running elsewhere. | local workstation |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| tidk telomere profiles | `data/tidk_telomeres/<sample>/ (in repo)` | Telomere-repeat (TTTAGGG) density along contigs >=1 Mb: lengths.tsv and tidk search output. | plot-tidk-telomeres.R | in the repo (committed) |
| Telomere figures | `figures/tidk_telomeres/ (in repo)` | Per-contig telomere density plots. | manuscript supplementary figure | in the repo (committed) |

## Notes

Both scripts run **locally**, not on the cluster, and the shell script points at
`/Users/yixuanyang/project_data/downy/contigs-renamed/cleaned/`. Change that glob before running it
on another machine.
