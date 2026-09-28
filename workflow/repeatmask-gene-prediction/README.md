# Repeat masking and gene prediction

`hard-mask-contigs.sh` and `hard-mask-published-genomes.sh` build a RepeatModeler library for each genome, then hard-mask with RepeatMasker. They read finalized focal FASTAs or published references and write under `results/repeatmask-gene-prediction/{focal,references}/hardmasked/`.

`helixer-contigs.sh` and `helixer-published-genomes.sh` run the Helixer v0.3.6 fungi model on GPU jobs, then use gffread to write GFF3 and protein FASTA under the matching `helixer/` directories. The Apptainer image requires the locally built `helixer_post_bin` and its HDF5 library; the scripts bind both from `$SOFTWARE_ROOT` and the HelixerPost environment.
