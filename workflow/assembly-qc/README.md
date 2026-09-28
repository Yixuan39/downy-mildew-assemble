# Assembly QC

- `prepare-assemblies.R`: targetasm assemblies → renamed, nuclear-presplit and mitochondrial FASTA in `results/assembly-qc/`.
- `blastn-find-mito.sh`: published genomes → mitochondrial BLAST hits in `results/assembly-qc/reference-mito-hits/`.
- `ncbi-screen.sh`: SC1982 nuclear-presplit FASTA → finalized nuclear FASTA (473 contigs, 102,862,537 bp). The other three `nuclear/` files are unchanged copies of `nuclear-presplit/`. The review evidence is in [ncbi-response/](../../ncbi-response/README.md).
- `qc-final-assemblies.sh` and `qc-published-genomes.sh`: assembly FASTA → quality tables in `data/`.
- `mt-linkage-plot.sh`: `data/mt_linkage/14_mitochondrial_genomes.gb` → mitochondrial linkage plot in `results/assembly-qc/mt-linkage/` and `data/mt_linkage/`.
