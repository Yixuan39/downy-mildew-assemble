# Repeat masking and gene prediction

`hard-mask-contigs.sh` and `hard-mask-published-genomes.sh` build a RepeatModeler library for each genome, then hard-mask with RepeatMasker. They read finalized focal FASTAs or published references and write under `results/repeatmask-gene-prediction/{focal,references}/hardmasked/`.

`helixer-contigs.sh` and `helixer-published-genomes.sh` run the Helixer v0.3.6 fungi model on GPU jobs, then use gffread to write GFF3 and protein FASTA under the matching `helixer/` directories. They use the cluster-local Apptainer image at `$HOME/software/helixer-docker_helixer_v0.3.6_cuda_12.2.2-cudnn8.sif`.
