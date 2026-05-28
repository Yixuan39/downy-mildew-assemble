#!/bin/bash

nextflow run nf-core/rnaseq \
    --input samplesheet_SC1982.csv \
    --outdir $HOME/project_data/downy/RNAseq \
    --gtf $HOME/project_data/downy/contigs-renamed/helixer/Pseudoperonospora_cubensis_SC1982.gff \
    --fasta $HOME/project_data/downy/contigs-renamed/cleaned/Pseudoperonospora_cubensis_SC1982.fasta.gz \
    -profile apptainer \
    -c custom.config
