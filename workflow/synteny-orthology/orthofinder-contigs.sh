#!/bin/bash
#SBATCH -c 32

set -euo pipefail
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"

orthofinder -f "${PROJECT_DATA}/results/synteny-orthology/tmp" -t 10 -X -o "${PROJECT_DATA}/results/synteny-orthology/orthofinder"
