#!/bin/bash

#BSUB -J DeepLoc2_OR502AA
#BSUB -n 4
#BSUB -R "span[hosts=1]"
#BSUB -R "rusage[mem=8GB]"
#BSUB -W 12:00
#BSUB -o DeepLoc2_OR502AA.%J.out
#BSUB -e DeepLoc2_OR502AA.%J.err

source /usr/local/apps/conda/miniconda3/26.3.2/etc/profile.d/conda.sh
conda activate /rs1/researchers/t/tbadhika/cjmantil/envs/deeploc21_env

export HF_HOME=/rs1/researchers/t/tbadhika/cjmantil/deeploc_cache/huggingface
export TRANSFORMERS_CACHE=/rs1/researchers/t/tbadhika/cjmantil/deeploc_cache/huggingface
export TORCH_HOME=/rs1/researchers/t/tbadhika/cjmantil/deeploc_cache/torch
export MPLCONFIGDIR=/rs1/researchers/t/tbadhika/cjmantil/deeploc_cache/matplotlib
export XDG_CACHE_HOME=/rs1/researchers/t/tbadhika/cjmantil/deeploc_cache
export TMPDIR=/rs1/researchers/t/tbadhika/cjmantil/tmp

INPUT="/rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/05_secretome/01_signalp6/Pseudoperonospora_humuli_OR502AA/OR502AA_signalp_positive.faa"

OUTDIR="/rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/05_secretome/05_deeploc/Pseudoperonospora_humuli_OR502AA"

mkdir -p "$OUTDIR"

deeploc2 \
  --fasta "$INPUT" \
  --output "$OUTDIR" \
  --model Fast
