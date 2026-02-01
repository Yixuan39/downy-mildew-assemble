#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --cpus-per-task=24
#SBATCH --mem=220G

set -euo pipefail

# run Kraken2 on raw HIFI reads
INPUT_DIR=$HOME/project_data/downy/p_effusa/filtered
Kraken_DB=$HOME/project_data/downy/KrakenDB
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
THREADS=24

FILE=("$INPUT_DIR"/*.fastq.gz)

BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.fastq.gz}

echo "Processing: $FILE"
RESULT_DIR=$HOME/project_data/downy/k2
mkdir -p "$RESULT_DIR"
  
kraken2 \
--db $Kraken_DB \
--threads $THREADS \
--confidence 0 \
--report $RESULT_DIR/$BASENAME.kreport \
--output $RESULT_DIR/$BASENAME.kraken \
$FILE
