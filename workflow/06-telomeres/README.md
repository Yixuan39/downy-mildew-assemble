# Stage 06 - Telomere repeats

tidk search for the TTTAGGG telomere repeat along every contig >= 1 Mb, and the plot of repeat
density along those contigs that supports the chromosome-scale claim.

## Scripts

| file | what it does | resources |
|---|---|---|
| `plot-tidk-telomeres.R` | Plot the tidk telomere-repeat density along each long contig. Called at the end of tidk-telomere-long-contigs.sh. | ncsu-brc login/short partition, R (ggplot2) |
| `tidk-telomere-long-contigs.sh` | Search contigs >=1 Mb for the plant/oomycete telomere repeat TTTAGGG with tidk, then call the plotting script. | ncsu-brc login/short partition, conda env `tidk` |

## Outputs

| output | path | what it is |
|---|---|---|
| tidk telomere profiles | `results/telomeres/<sample>/`, mirrored to `data/tidk_telomeres/<sample>/` | Telomere-repeat density along contigs >=1 Mb. |
| Telomere figures | `results/telomeres/figures/`, mirrored to `figures/tidk_telomeres/` | Per-contig telomere density plots. |
