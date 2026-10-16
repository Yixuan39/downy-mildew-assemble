# Functional annotation

`protein-diamond-blastp.sh`, `protein-eggnog.sh` and `protein-interproscan.sh` annotate Helixer proteins under `results/functional-annotation/`. `summarize-functions.R` joins these annotations with RNA-seq TPM into `data/annotation_support.tsv`. `build-gene-table.R` (env `R`) adds gene coordinates, per-sample TPM and the secretome/effectome steps into `data/gene_annotation_summary.xlsx`, one sheet per focal isolate.
