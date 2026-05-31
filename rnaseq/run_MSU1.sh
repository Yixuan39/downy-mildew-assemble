#!/bin/bash

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input samplesheet_MSU1.csv \
    --outdir $HOME/project_data/downy/RNA-seq_result/Pcub_MSU1 \
    --gff $HOME/project_data/downy/contigs-renamed/helixer/Pseudoperonospora_cubensis_MSU1.gff \
    --fasta $HOME/project_data/downy/contigs-renamed/cleaned/Pseudoperonospora_cubensis_MSU1.fasta.gz \
    --contaminant_screening 'kraken2_bracken' --kraken_db $HOME/db/kraken2/PlusPFP \
    --featurecounts_group_type gene_id \
    --save_align_intermeds \
    --skip_biotype_qc \
    -profile apptainer \
    -c custom.config
