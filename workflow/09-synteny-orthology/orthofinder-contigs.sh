#!/bin/bash
#SBATCH -c 32

# Purpose : Run OrthoFinder over the proteomes staged for GENESPACE, producing the orthogroups behind the
#           synteny figures.
# Inputs  : ${PROJECT_DATA}/results/synteny-orthology/tmp/*.faa
# Outputs : ${PROJECT_DATA}/results/synteny-orthology/orthofinder/
# Runs on : SLURM, 32 cores requested (OrthoFinder is called with -t 10)
# Usage   : sbatch workflow/09-synteny-orthology/orthofinder-contigs.sh

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"

orthofinder -f "${PROJECT_DATA}/results/synteny-orthology/tmp" -t 10 -X -o "${PROJECT_DATA}/results/synteny-orthology/orthofinder"
