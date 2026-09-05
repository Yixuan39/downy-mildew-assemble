#!/bin/bash
#SBATCH -c 32

# ----------------------------------------------------------------------------------------
# Purpose : Run OrthoFinder over the proteomes staged for GENESPACE, producing the orthogroups behind the
#           synteny figures.
# Inputs  : $HOME/project_data/downy/genespace-contigs/tmp/*.faa
# Outputs : $HOME/project_data/downy/genespace-contigs/orthofinder/
# Runs on : SLURM, 32 cores requested (OrthoFinder is called with -t 10)
# Usage   : sbatch workflow/11-synteny-orthology/orthofinder-contigs.sh
# ----------------------------------------------------------------------------------------

orthofinder -f "$HOME/project_data/downy/genespace-contigs/tmp" -t 10 -X -o "$HOME/project_data/downy/genespace-contigs/orthofinder"
