# Repeat masking and gene prediction

- `hard-mask-contigs.sh` and `hard-mask-published-genomes.sh`: nuclear FASTA → RepeatModeler/RepeatMasker hard-masked FASTA.
- `helixer-contigs.sh` and `helixer-published-genomes.sh`: hard-masked FASTA → Helixer GFF3 and protein FASTA.

Outputs are in `results/repeatmask-gene-prediction/{focal,references}/`.

The MSU1 and OR502AA results in use are the 2026-05-27 run (restored 2026-10-06); SC1982, UA202013* and the references are the
2026-09-23 run. Both scripts process every isolate in the input directory, and RepeatModeler is not seeded, so a rerun replaces
all four isolates with a slightly different mask.
