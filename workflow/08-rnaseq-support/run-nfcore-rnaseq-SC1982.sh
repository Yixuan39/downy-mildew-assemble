#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Run nf-core/rnaseq 3.26.0 against the SC1982 assembly.
# Inputs  : workflow/08-rnaseq-support/config/samplesheet_SC1982.csv, workflow/08-rnaseq-support/config/custom.config, the SC1982 assembly + Helixer
#           GFF3
# Outputs : the nf-core/rnaseq outdir set inside the script
# Runs on : login node - Nextflow submits its own SLURM jobs; apptainer profile
# Usage   : bash workflow/08-rnaseq-support/run-nfcore-rnaseq-SC1982.sh
# ----------------------------------------------------------------------------------------

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input workflow/08-rnaseq-support/config/samplesheet_SC1982.csv \
    --outdir $HOME/project_data/downy/RNA-seq_result/Pcub_SC1982 \
    --gff $HOME/project_data/downy/contigs-renamed/helixer/Pseudoperonospora_cubensis_SC1982.gff \
    --fasta $HOME/project_data/downy/contigs-renamed/cleaned/Pseudoperonospora_cubensis_SC1982.fasta.gz \
    --contaminant_screening 'kraken2_bracken' --kraken_db $HOME/db/kraken2/PlusPFP \
    --skip_biotype_qc true \
    --featurecounts_feature_type exon \
    --featurecounts_group_type gene_id \
    --min_mapped_reads 0 \
    -profile apptainer \
    -c workflow/08-rnaseq-support/config/custom.config
