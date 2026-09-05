#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --cpus-per-task=24
#SBATCH --mem=220G

# ----------------------------------------------------------------------------------------
# Purpose : Same Kraken2 PlusPFP classification for the public P. effusa reads, which live in their own
#           directory and are a single file (no array).
# Inputs  : $HOME/project_data/downy/UA202013/filtered/*.fastq.gz; Kraken2 PlusPFP at
#           $HOME/db/kraken2/PlusPFP
# Outputs : $HOME/project_data/downy/k2_pfp/<sample>.{kraken,report}
# Runs on : SLURM, 24 cores / 220 GB
# Usage   : sbatch workflow/01-read-filtering/UA202013/kraken2-pluspfp.sh
# ----------------------------------------------------------------------------------------

set -euo pipefail

# run Kraken2 on raw HIFI reads
INPUT_DIR=$HOME/project_data/downy/UA202013/filtered
Kraken_DB=$HOME/db/kraken2/PlusPFP
BUSCO_DB=$HOME/db/compleasm
THREADS=24

FILE=("$INPUT_DIR"/*.fastq.gz)

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
