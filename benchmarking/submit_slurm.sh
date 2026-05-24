#!/bin/bash

set -euo pipefail

sbatch -p bigmem -w node95 --export=ALL,SAMPLE=p_effusa hifiasm.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=p_effusa hifiasm_blastn.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=p_effusa TEA.sh

sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1 hifiasm.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1 hifiasm_blastn.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1,METHOD=tea_no_downsample TEA.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1,METHOD=tea_downsample TEA.sh
