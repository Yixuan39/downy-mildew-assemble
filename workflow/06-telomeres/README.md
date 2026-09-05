# Stage 06 - Telomere repeats

tidk search for the TTTAGGG telomere repeat along every contig >= 1 Mb, and the plot of repeat
density along those contigs that supports the chromosome-scale claim.

## Scripts

| file | what it does | resources |
|---|---|---|
| `plot-tidk-telomeres.R` | Plot the tidk telomere-repeat density along each long contig. Called at the end of tidk-telomere-long-contigs.sh. | ncsu-brc login/short partition, R (ggplot2) |
| `tidk-telomere-long-contigs.sh` | Search contigs >=1 Mb for the plant/oomycete telomere repeat TTTAGGG with tidk, then call the plotting script. | ncsu-brc login/short partition, conda env `tidk` |

## Outputs

Paths are under `$PROJECT_DATA` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| tidk telomere profiles | `results/telomeres/<sample>/`, mirrored to `data/tidk_telomeres/<sample>/ (in repo)` | Telomere-repeat (TTTAGGG) density along contigs >=1 Mb: lengths.tsv and tidk search output. | plot-tidk-telomeres.R | in the repo (committed) |
| Telomere figures | `results/telomeres/figures/`, mirrored to `figures/tidk_telomeres/ (in repo)` | Per-contig telomere density plots. | manuscript supplementary figure | in the repo (committed) |

## Notes

Both scripts run on the cluster now (conda env `tidk`, plus R with ggplot2 for the plot). Each
mirrors its final output back into the repo's `data/tidk_telomeres/` and `figures/tidk_telomeres/`
at the end, which is what actually gets committed for the manuscript figure.
