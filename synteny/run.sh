#!/bin/bash
#SBATCH -J cactus


snakemake \
-j 24 \
-e slurm \
--directory "$HOME" \
-s "$HOME"/software/cactus-snakemake/cactus.smk \
--configfile ./config.yaml
