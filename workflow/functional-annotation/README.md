# Functional annotation

`protein-diamond-blastp.sh`, `protein-eggnog.sh` and `protein-interproscan.sh` annotate Helixer proteins under `results/functional-annotation/`. `summarize-functions.R` joins these annotations with RNA-seq TPM into `data/annotation_support.tsv`. `build-gene-table.R` (env `R`) adds gene coordinates, per-sample TPM and the secretome/effectome steps into `data/gene_annotation_summary.xlsx`, one sheet per focal isolate.

The manuscript workbook includes one manual curation: `Pcub-MSU1_003_000782.1` is excluded from the final soluble secretome as a suspected gene-model artifact, with the reason in `curation_note` and raw tool predictions retained. Reapply this curation after rebuilding the workbook; the uncurated pipeline contains 799 MSU1 secretome proteins, versus 798 after curation. Predicted gene and effector counts are unchanged.
