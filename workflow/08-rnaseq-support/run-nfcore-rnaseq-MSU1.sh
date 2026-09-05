#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Run nf-core/rnaseq 3.26.0 against the MSU1 assembly to get transcript-level evidence for the
#           predicted genes.
# Inputs  : workflow/08-rnaseq-support/config/samplesheet_MSU1.csv, workflow/08-rnaseq-support/config/custom.config, the MSU1 assembly + Helixer
#           GFF3
# Outputs : the nf-core/rnaseq outdir set inside the script
# Runs on : NCSU BRC login node - Nextflow submits its own SLURM jobs; apptainer profile
# Usage   : bash workflow/08-rnaseq-support/run-nfcore-rnaseq-MSU1.sh
# ----------------------------------------------------------------------------------------

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input workflow/08-rnaseq-support/config/samplesheet_MSU1.csv \
    --outdir $HOME/project_data/downy/RNA-seq_result/Pcub_MSU1 \
    --gff $HOME/project_data/downy/contigs-renamed/helixer/Pseudoperonospora_cubensis_MSU1.gff \
    --fasta $HOME/project_data/downy/contigs-renamed/cleaned/Pseudoperonospora_cubensis_MSU1.fasta.gz \
    --contaminant_screening 'kraken2_bracken' --kraken_db $HOME/db/kraken2/PlusPFP \
    --skip_biotype_qc true \
    --featurecounts_feature_type exon \
    --featurecounts_group_type gene_id \
    --min_mapped_reads 0 \
    -profile apptainer \
    -c workflow/08-rnaseq-support/config/custom.config 
