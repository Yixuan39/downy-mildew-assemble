# Functional annotation

`protein-diamond-blastp.sh`, `protein-eggnog.sh` and `protein-interproscan.sh` annotate the focal Helixer proteins. They read `results/repeatmask-gene-prediction/focal/helixer/*.faa` and write to `results/functional-annotation/{blastp,eggnog-mapper,interproscan}/`. DIAMOND and eggNOG use mamba environments; InterProScan uses the installed Apptainer image and database.

After RNA-seq and secretome/effectome results are available, `summarize-functions.R` combines annotation sources, maximum TPM and secretome/effectome flags into the committed `data/annotation_support.tsv`.
