# Functional annotation

`protein-diamond-blastp.sh`, `protein-eggnog.sh` and `protein-interproscan.sh` annotate the focal Helixer proteins. They read `results/repeatmask-gene-prediction/focal/helixer/*.faa` and write to `results/functional-annotation/{blastp,eggnog-mapper,interproscan}/`. DIAMOND and eggNOG use mamba environments; InterProScan uses the installed Apptainer image and database.

After RNA-seq and existing `results/secretome-effectome/` ID lists are available, `summarize-functions.R` combines annotation sources, maximum TPM and secretome/effectome flags into `data/annotation_support.tsv`. This repository no longer includes a secretome/effectome generation script.
