#!/bin/bash

nextflow run nf-core/rnaseq \
    --input samplesheet_MSU1.csv \
    --outdir $HOME/project_data/downy/RNAseq \
    --gtf $HOME/project_data/downy/contigs-renamed/helixer/Pseudoperonospora_cubensis_MSU1.gff \
    --fasta $HOME/project_data/downy/contigs-renamed/cleaned/Pseudoperonospora_cubensis_MSU1.fasta.gz \
    -profile apptainer \
    -c custom.config
