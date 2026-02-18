#!/bin/bash
#SBATCH --cpus-per-task=24
#SBATCH --partition=bigmem,standard
#SBATCH --mem=500G

nextflow run nf-core/genomeqc \
   -r dev \
   -resume \
   -c fix_gffread.config \
   -profile singularity \
   --input ../data/samplesheet.csv \
   --busco_lineage stramenopiles_odb12 \
   --busco_lineages_path $HOME/busco_db/busco_downloads \
   --busco_clean \
   --gx_db $HOME/project_data/downy/fcs-db \
   --outdir $HOME/project_data/downy/genomeqc