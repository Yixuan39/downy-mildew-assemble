#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Submit all seven benchmark runs (3 arms x 2 isolates, plus the two MSU1 downsampling variants)
#           to the same node so the wall-time comparison is fair.
# Inputs  : the three arm scripts in this directory
# Outputs : seven queued SLURM jobs
# Runs on : NCSU BRC login node
# Usage   : bash workflow/03-benchmarking/submit-all.sh
# ----------------------------------------------------------------------------------------

set -euo pipefail

sbatch -p bigmem -w node95 --export=ALL,SAMPLE=UA202013 hifiasm.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=UA202013 hifiasm-blastn.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=UA202013 targetasm.sh

sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1 hifiasm.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1 hifiasm-blastn.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1,METHOD=tea_no_downsample targetasm.sh
sbatch -p bigmem -w node95 --export=ALL,SAMPLE=MSU1,METHOD=tea_downsample targetasm.sh
