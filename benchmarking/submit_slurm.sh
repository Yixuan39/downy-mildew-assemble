#!/bin/bash

set -euo pipefail

sbatch -p bigmem -w node95 --export=ALL,SAMPLE=p_effusa hifiasm.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=p_effusa hifiasm_blastn.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=p_effusa target-asm.sh

sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1 hifiasm.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1 hifiasm_blastn.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1,METHOD=tea_no_downsample target-asm.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1,METHOD=tea_downsample target-asm.sh
