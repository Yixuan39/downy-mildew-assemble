# Assembly QC and mitochondrial analysis

`prepare-assemblies.R` renames targetasm contigs, finds mitochondrial candidates against `inputs/reference-mitochondria/KT072718.1.fna`, and writes `results/assembly-qc/{renamed,mitochondrial,nuclear-presplit}/`. It requires Biostrings and BLASTN and refuses to overwrite existing nuclear FASTAs. `blastn-find-mito.sh` screens published genomes against the same reference.

`ncbi-screen.sh` splits the internal N-run in SC1982 and removes the two whole contigs flagged by NCBI (`Pcub-SC1982_037` and `Pcub-SC1982_071`). Its finalized `results/assembly-qc/nuclear/Pseudoperonospora_cubensis_SC1982.fasta.gz` has 473 contigs and 102,862,537 bp. The supporting review is in [ncbi-response/](../../ncbi-response/). The other three finalized nuclear FASTAs match those under `nuclear-presplit/`.

`qc-final-assemblies.sh` and `qc-published-genomes.sh` write the committed quality tables under `data/qc_final_assemblies/` and `data/qc_published_genomes/`. `mt-linkage-plot.sh` uses the curated `data/mt_linkage/14_mitochondrial_genomes.gb` to produce the mitochondrial linkage figure under `results/assembly-qc/mt-linkage/`, mirrored to `data/mt_linkage/`; it needs the gbdraw environment and BLASTN.
