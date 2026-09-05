#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Run nf-core/rnaseq 3.26.0 against the OR502AA assembly.
# Inputs  : config/rnaseq/samplesheet_OR502AA.csv, config/rnaseq/custom.config, the OR502AA assembly +
#           Helixer GFF3
# Outputs : the nf-core/rnaseq outdir set inside the script
# Runs on : NCSU BRC login node - Nextflow submits its own SLURM jobs; apptainer profile
# Usage   : bash workflow/08-rnaseq-support/run-nfcore-rnaseq-OR502AA.sh
# ----------------------------------------------------------------------------------------

nextflow run nf-core/rnaseq -r 3.26.0 \
    --input config/rnaseq/samplesheet_OR502AA.csv \
    --outdir $HOME/project_data/downy/RNA-seq_result/Phum_OR502AA \
    --gff $HOME/project_data/downy/contigs-renamed/helixer/Pseudoperonospora_humuli_OR502AA.gff \
    --fasta $HOME/project_data/downy/contigs-renamed/cleaned/Pseudoperonospora_humuli_OR502AA.fasta.gz \
    --contaminant_screening 'kraken2_bracken' --kraken_db $HOME/db/kraken2/PlusPFP \
    --skip_biotype_qc true \
    --featurecounts_feature_type exon \
    --featurecounts_group_type gene_id \
    --min_mapped_reads 0 \
    -profile apptainer \
    -c config/rnaseq/custom.config
