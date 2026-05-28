#!/bin/bash

nextflow run nf-core/rnaseq \
    --input samplesheet_OR502AA.csv \
    --outdir $HOME/project_data/downy/RNAseq \
    --gtf $HOME/project_data/downy/contigs-renamed/helixer/Pseudoperonospora_humuli_OR502AA.gff \
    --fasta $HOME/project_data/downy/contigs-renamed/cleaned/Pseudoperonospora_humuli_OR502AA.fasta.gz \
    -profile apptainer \
    -c custom.config
