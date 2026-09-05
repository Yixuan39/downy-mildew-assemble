#!/bin/bash
#SBATCH -c 32

# Purpose : Run OrthoFinder over the proteomes staged for GENESPACE, producing the orthogroups behind the
#           synteny figures.
# Inputs  : ${PROJECT_DATA}/results/synteny-orthology/tmp/*.faa
# Outputs : ${PROJECT_DATA}/results/synteny-orthology/orthofinder/
# Runs on : SLURM, 32 cores requested (OrthoFinder is called with -t 10)
# Usage   : sbatch workflow/11-synteny-orthology/orthofinder-contigs.sh

set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

orthofinder -f "${PROJECT_DATA}/results/synteny-orthology/tmp" -t 10 -X -o "${PROJECT_DATA}/results/synteny-orthology/orthofinder"
