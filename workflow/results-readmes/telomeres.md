# results/telomeres/

tidk telomere-repeat search output and the summary plot, over the final nuclear assemblies in
`results/assembly-qc/nuclear/`. Produced by `workflow/06-telomeres/` in the
`downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `<sample>/lengths.tsv` | Per-contig lengths for the sample's assembly, used to pick the top 20 longest contigs to plot. | `plot-tidk-telomeres.R` | in the repo (mirrored to `data/tidk_telomeres/`) |
| `<sample>/<sample>.TTTAGGG_telomeric_repeat_windows.tsv` | tidk `search` output: windowed TTTAGGG telomeric-repeat counts across each contig. | `plot-tidk-telomeres.R` | in the repo (mirrored to `data/tidk_telomeres/`) |
| `figures/tidk_telomere_profiles_top20_contigs.pdf` | Per-sample telomere-repeat density profiles along the 20 longest contigs. | manuscript figure | in the repo (mirrored to `figures/tidk_telomeres/`) |

## Notes

Runs on the cluster's `tidk` conda env (tidk 0.2.65, seqkit 2.13.0). The `tidk search` motif is
supplied explicitly (`TTTAGGG`), so the `tidk build`/clade-database warning on a fresh env is
harmless.
