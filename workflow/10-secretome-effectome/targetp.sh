#!/bin/bash

#BSUB -J targetp_MSU1
#BSUB -n 1
#BSUB -R "rusage[mem=8]"
#BSUB -W 40:00
#BSUB -o /rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/05_secretome/03_targetp/logs/MSU1_targetp2.%J.out
#BSUB -e /rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/05_secretome/03_targetp/logs/MSU1_targetp2.%J.err

# ----------------------------------------------------------------------------------------
# Purpose : Run TargetP 2.0 on the Helixer protein sets to separate secretory signal peptides from
#           mitochondrial transit peptides.
# Inputs  : /rs1/.../02_helixer/<Species>_<isolate>.faa; local targetp-2.0 install under the stage workdir
# Outputs : TargetP 2.0 summary per isolate
# Runs on : LSF (bsub), 1 core / 8 GB / 40 h
# Usage   : bsub < workflow/10-secretome-effectome/targetp.sh
# ----------------------------------------------------------------------------------------

set -euo pipefail

WORKDIR="/rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/05_secretome/03_targetp"

TARGETP="${WORKDIR}/targetp-2.0/bin/targetp"

FASTA="/rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/02_helixer/Pseudoperonospora_cubensis_MSU1.faa"

OUTPUT="${WORKDIR}/results/MSU1.targetp2.txt"

mkdir -p "${WORKDIR}/results"

echo "Starting TargetP 2.0 for MSU1"
echo "Input FASTA: ${FASTA}"
echo "Input proteins: $(grep -c '^>' "${FASTA}")"
echo "Start time: $(date)"

"${TARGETP}" \
    -fasta "${FASTA}" \
    -org non-pl \
    -format short \
    > "${OUTPUT}"

echo "Finished TargetP 2.0 for MSU1"
echo "End time: $(date)"
echo "Output: ${OUTPUT}"
