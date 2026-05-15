#!/bin/bash
#SBATCH -c 32

orthofinder -f "$HOME/project_data/downy/genespace-contigs/tmp" -t 32 -X -o "$HOME/project_data/downy/genespace-contigs/orthofinder"
