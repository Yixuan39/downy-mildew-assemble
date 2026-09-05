# results/functional-annotation/

Three independent functional-annotation sources over the Helixer proteomes: eggNOG-mapper,
InterProScan, and DIAMOND blastp against nr. Produced by `workflow/09-functional-annotation/` in
the `downy-mildew-assemble` repo; combined into the per-gene support summary by
`analysis/gene-annotation-report.Rmd`.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `blastp/<genome>.tsv` | DIAMOND blastp of the Helixer proteins against NCBI nr (homology half of the annotation support table). | `gene-annotation-report.Rmd` (Table 2, Figure 5) | Zenodo (functional-annotation tables) |
| `eggnog-mapper/<genome>/` | eggNOG orthology-based functional annotation. | `gene-annotation-report.Rmd` | Zenodo (functional-annotation tables) |
| `interproscan/<genome>/` | InterPro domains and GO terms (InterProScan 5.77-108.0). | `gene-annotation-report.Rmd` | Zenodo (functional-annotation tables) |

## Notes

All three are SLURM arrays over the four proteomes and expect their databases under `$HOME/db`
(`eggnog`, `interproscan-5.77-108.0`, `nr.dmnd`). A fourth source (ProteInfer) was previously
part of this comparison but is not used in the manuscript and is not part of this results tree.
