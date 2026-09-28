# Read filtering and screening

`run-hifiadapterfilt.sh` removes PacBio adapters from the three focal FASTQs; `UA202013/run-hifiadapterfilt.sh` does the same for the public library. They write `results/read-filtering-screening/reads/{focal,UA202013}/*.fastq.gz`. These scripts do not run filtlong.

`kraken2-pluspfp.sh` and its `UA202013/` counterpart classify the filtered reads against `$DB_ROOT/kraken2/PlusPFP`, writing `.kraken` and `.kreport` files under `results/read-filtering-screening/taxonomy/`.

`kat-seqkit-coverage-gc.sh` and its `UA202013/` counterpart write per-read KAT self-coverage and seqkit GC tables under `results/read-filtering-screening/coverage-gc/`. `analysis/read-distribution.Rmd` uses these with the Kraken2 outputs. Submit the focal scripts as SLURM arrays; the UA202013 scripts are single jobs.
