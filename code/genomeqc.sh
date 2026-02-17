#!/bin/bash
#SBATCH -c 24
#SBATCH -mem=500G

nextflow run nf-core/genomeqc \
   -r dev \
   -profile singularity \
   --input ../data/samplesheet.csv \
   --busco_lineage stramenopiles_odb12 \
   --busco_clean \
   --gx_db $HOME/project_data/downy/fcs-db \
   --outdir $HOME/project_data/downy/genomeqc