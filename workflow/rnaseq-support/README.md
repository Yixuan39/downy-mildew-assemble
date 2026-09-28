# RNA-seq support

`run-rnaseq.sh MSU1|SC1982|OR502AA` runs nf-core/rnaseq 3.26.0 with STAR/Salmon and the matching finalized assembly and Helixer GFF. It resolves the checked-in `config/` samplesheet and cluster config from its own location, validates FASTQ paths with `prepare-samplesheet.py`, and writes to `$PROJECT_DATA/results/rnaseq-support/`. Run it from a login node; Nextflow submits the jobs through the Apptainer profile.
