#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24
#SBATCH --mem=220G

# ----------------------------------------------------------------------------------------
# Purpose : Classify the adapter-filtered HiFi reads against Kraken2 PlusPFP to quantify host/microbial
#           content before assembly (Fig. 1 read composition).
# Inputs  : $HOME/project_data/downy/GSL_Data/fastq/filtered/*.fastq.gz; Kraken2 PlusPFP at
#           $HOME/db/kraken2/PlusPFP
# Outputs : $HOME/project_data/downy/k2_pfp/<sample>.{kraken,report}
# Runs on : SLURM array 0-2, 24 cores / 220 GB (the PlusPFP index is loaded into RAM)
# Usage   : sbatch workflow/01-read-filtering/kraken2-pluspfp.sh
# ----------------------------------------------------------------------------------------

set -euo pipefail

# run Kraken2 on raw HIFI reads
INPUT_DIR=$HOME/project_data/downy/GSL_Data/fastq/filtered
Kraken_DB=$HOME/db/kraken2/PlusPFP
BUSCO_DB=$HOME/db/compleasm
THREADS=24

FILES=("$INPUT_DIR"/*.fastq.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"

BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.fastq.gz}

echo "Processing: $FILE"
RESULT_DIR=$HOME/project_data/downy/k2_pfp
mkdir -p "$RESULT_DIR"

kraken2 \
--db $Kraken_DB \
--threads $THREADS \
--confidence 0 \
--report $RESULT_DIR/$BASENAME.kreport \
--output $RESULT_DIR/$BASENAME.kraken \
$FILE
