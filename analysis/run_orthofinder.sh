#!/bin/bash
#SBATCH -p bigmem
#SBATCH -c 32
#SBATCH --mem=0


orthofinder -f "$HOME/project_data/downy/genespace/tmp" -t 32 -X -o "$HOME/project_data/downy/genespace/orthofinder"