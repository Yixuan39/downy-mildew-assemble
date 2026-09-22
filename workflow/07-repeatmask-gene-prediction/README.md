# Stage 07 - Repeat masking and gene prediction

RepeatModeler builds a repeat library, RepeatMasker hard-masks the assemblies, and Helixer predicts
genes from the masked sequence in a GPU container; gffread extracts the protein FASTA used by
stages 08 and 09.

`hard-mask-contigs.sh` and `hard-mask-published-genomes.sh` build one repeat library per genome.

## Scripts

| file | what it does | resources |
|---|---|---|
| `hard-mask-contigs.sh` | Build a per-assembly repeat library with RepeatModeler and hard-mask the three new assemblies with RepeatMasker. | SLURM array 0-3, 32 cores |
| `hard-mask-published-genomes.sh` | Same per-genome RepeatModeler/RepeatMasker treatment for the published genomes, so gene prediction sees comparably masked input. | SLURM array 0-10, 32 cores |
| `helixer-contigs.sh` | Predict genes in the three new assemblies with Helixer (land_plant/fungi model in the v0.3.6 CUDA container) and convert the GFF3 to proteins with gffread. | GPU partition, SLURM array 0-3, 24 cores, apptainer --nv |
| `helixer-published-genomes.sh` | Same Helixer prediction for the published genomes, giving a like-for-like gene set for the annotation comparison. | GPU partition, SLURM array 0-10, 24 cores, apptainer --nv |

## Outputs

| output | path | what it is | consumed by |
|---|---|---|---|
| Hard-masked assemblies | `results/repeatmask-gene-prediction/focal/hardmasked/` | Per-assembly RepeatModeler/RepeatMasker output for the three new assemblies. | helixer-contigs.sh |
| Helixer gene models | `results/repeatmask-gene-prediction/focal/helixer/<assembly>.gff + .faa` | Predicted gene structures and protein sequences for each new assembly. | 08-annotation, 09-synteny-orthology |
| Published-genome masking + Helixer | `results/repeatmask-gene-prediction/references/hardmasked/` and `/helixer/` | Like-for-like masking and gene prediction for the published genomes. | 09-synteny-orthology |
