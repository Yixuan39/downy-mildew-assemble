#!/bin/bash

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input samplesheet_OR502AA.csv \
    --outdir $HOME/project_data/downy/RNA-seq_result/Phum_OR502AA \
    --gff $HOME/project_data/downy/contigs-renamed/helixer/Pseudoperonospora_humuli_OR502AA.gff \
    --fasta $HOME/project_data/downy/contigs-renamed/cleaned/Pseudoperonospora_humuli_OR502AA.fasta.gz \
    --contaminant_screening 'kraken2_bracken' --kraken_db $HOME/db/kraken2/PlusPFP \
    --featurecounts_group_type gene_id \
    --save_align_intermeds \
    --skip_biotype_qc \
    --min_mapped_reads 0 \
    -profile apptainer \
    -c custom.config
