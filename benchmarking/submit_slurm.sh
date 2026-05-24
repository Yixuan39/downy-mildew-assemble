#!/bin/bash

set -euo pipefail

sbatch --export=ALL,SAMPLE=p_effusa benchmarking/hifiasm.sh
sbatch --export=ALL,SAMPLE=p_effusa benchmarking/hifiasm_blastn.sh
sbatch -p bigmem -w node 95 --export=ALL,SAMPLE=p_effusa benchmarking/TEA.sh

sbatch --export=ALL,SAMPLE=MSU1 benchmarking/hifiasm.sh
sbatch --export=ALL,SAMPLE=MSU1 benchmarking/hifiasm_blastn.sh
sbatch -p bigmem -w node 95 --export=ALL,SAMPLE=MSU1,METHOD=tea_no_downsample benchmarking/TEA.sh
sbatch -p bigmem -w node 95 --export=ALL,SAMPLE=MSU1,METHOD=tea_downsample benchmarking/TEA.sh
