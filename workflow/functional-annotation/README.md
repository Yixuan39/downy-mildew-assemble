# Functional annotation

`protein-diamond-blastp.sh`, `protein-eggnog.sh` and `protein-interproscan.sh` annotate Helixer proteins under `results/functional-annotation/`. `summarize-functions.R` joins these annotations with RNA-seq TPM into `data/annotation_support.tsv`. Secretome/effectome columns are omitted until that workflow is available.
