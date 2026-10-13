# Repeat masking and gene prediction

- `hard-mask-contigs.sh` and `hard-mask-published-genomes.sh`: nuclear FASTA → RepeatModeler/RepeatMasker hard-masked FASTA.
- `helixer-contigs.sh` and `helixer-published-genomes.sh`: hard-masked FASTA → Helixer GFF3 and protein FASTA.
- `extract-transcripts-cds.sh`: Helixer GFF3 and unmasked nuclear FASTA → spliced transcript (`.transcripts.fna`) and CDS (`.cds.fna`) FASTA in `focal/helixer/`.
- `extract-ltr-unknown.sh`: RepeatMasker `.fasta.out` → LTR and unclassified (`Unknown`) repeat coordinates (`.ltr_unknown.tsv`) and sequences (`.ltr_unknown.fna`) in `focal/ltr-unknown/`.

Outputs are in `results/repeatmask-gene-prediction/{focal,references}/`.
