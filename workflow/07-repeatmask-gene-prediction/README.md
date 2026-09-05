# Stage 07 - Repeat masking and gene prediction

RepeatModeler builds a repeat library, RepeatMasker hard-masks the assemblies, and Helixer predicts
genes from the masked sequence in a GPU container; gffread extracts the protein FASTA that stages
09 to 11 consume.

Two masking strategies are kept. `hard-mask-contigs.sh` / `hard-mask-published-genomes.sh` build one
library per genome. `hard-mask-combined-library.sh` builds a single deduplicated library from all
assemblies together and masks everything with it - that is the variant the annotation comparison
used, writing to `hardmasked-carlos/`.

## Scripts

| file | what it does | resources |
|---|---|---|
| `hard-mask-combined-library.sh` | Alternative masking strategy: build ONE repeat library from all assemblies combined (deduplicated with seqkit rmdup) and mask every assembly with it. Kept because the combined-library masking is what the annotation comparison used. | SLURM, 32 cores |
| `hard-mask-contigs.sh` | Build a per-assembly repeat library with RepeatModeler and hard-mask the three new assemblies with RepeatMasker. | SLURM array 0-3, 32 cores |
| `hard-mask-published-genomes.sh` | Same per-genome RepeatModeler/RepeatMasker treatment for the published genomes, so gene prediction sees comparably masked input. | SLURM array 0-10, 32 cores |
| `helixer-contigs.sh` | Predict genes in the three new assemblies with Helixer (land_plant/fungi model in the v0.3.6 CUDA container) and convert the GFF3 to proteins with gffread. | GPU partition, SLURM array 0-3, 24 cores, apptainer --nv |
| `helixer-published-genomes.sh` | Same Helixer prediction for the published genomes, giving a like-for-like gene set for the annotation comparison. | GPU partition, SLURM array 0-10, 24 cores, apptainer --nv |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| Hard-masked assemblies | `~/project_data/downy/contigs-renamed/hardmasked/` | Per-assembly RepeatModeler/RepeatMasker output for the three new assemblies. | helixer-contigs.sh | not deposited (regenerable intermediate) |
| Helixer gene models | `~/project_data/downy/contigs-renamed/helixer/<assembly>.gff + .faa` | Predicted gene structures (GFF3) and protein sequences (FASTA) for each new assembly. | 08-rnaseq-support, 09-functional-annotation, 10-secretome-effectome, 11-synteny-orthology | Zenodo (annotations + predicted proteomes) |
| Published-genome masking + Helixer | `~/project_data/downy/downy-mildew-genomes/hardmasked/ and /helixer/` | Like-for-like masking and gene prediction for the published genomes. | 11-synteny-orthology | Zenodo (predicted proteomes); masking not deposited |
| Combined-library masking (abandoned) | `~/project_data/downy/contigs-renamed/hardmasked-carlos/ + .tar.gz` | Alternative single-combined-library masking strategy; not used in the manuscript. | - | delete (cleanup: 1.2 GB dir + redundant 383 MB tarball) |

## Notes

Helixer needs the GPU partition and `apptainer --nv`; the container tag is pinned in the script
(`helixer_v0.3.6_cuda_12.2.2-cudnn8`). RepeatModeler is the slow step - expect days per genome.
