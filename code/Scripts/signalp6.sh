#!/bin/bash
#BSUB -J signalp6
#BSUB -n 2
#BSUB -R "rusage[mem=4]"
#BSUB -R "span[hosts=1]"
#BSUB -W 24:00
#BSUB -o signalp6.%J.out
#BSUB -e signalp6.%J.err

set -eo pipefail

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate /rs1/researchers/t/tbadhika/cjmantil/envs/signalp6_env

signalp6 \
    --fastafile /rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/02_helixer/Pseudoperonospora_humuli_OR502AA.faa \
    --organism eukarya \
    --output_dir /rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/05_secretome/01_signalp6/Pseudoperonospora_humuli_OR502AA \
    --format none \
    --mode fast \
    --torch_num_threads 2

echo "SignalP analysis completed."
