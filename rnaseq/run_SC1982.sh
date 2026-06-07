#!/bin/bash

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input samplesheet_SC1982.csv \
    --outdir $HOME/project_data/downy/RNA-seq_result/Pcub_SC1982 \
    --gff $HOME/project_data/downy/contigs-renamed/helixer/Pseudoperonospora_cubensis_SC1982.gff \
    --fasta $HOME/project_data/downy/contigs-renamed/cleaned/Pseudoperonospora_cubensis_SC1982.fasta.gz \
    --contaminant_screening 'kraken2_bracken' --kraken_db $HOME/db/kraken2/PlusPFP \
    --skip_biotype_qc false \
    --featurecounts_feature_type exon \
    --featurecounts_group_type transcript_id \
    --save_align_intermeds \
    --min_mapped_reads 0 \
    -profile apptainer \
    -c custom.config
