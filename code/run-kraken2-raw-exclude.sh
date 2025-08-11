#!/bin/bash
#SBATCH --job-name=kraken2
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

# set -euo pipefail

# after cleaning with fcs, verify and clean with Kraken2
INPUT_DIR="$HOME/project_data/downy/GSL_Data/fastq"
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
TAXID=4762
CONF=(0 0.25 0.5 0.75)
THREADS=32

FILES=("$INPUT_DIR"/*.fastq.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"

BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.fastq.gz}
BASENAME=${BASENAME%.fasta.gz}  

echo "Processing: $FILE"

# test for genomic database
Kraken_DB="$HOME/project_data/downy/KrakenDB/contam-genome"
for C in "${CONF[@]}"; do
  RESULT_DIR="$HOME/project_data/downy/Kraken2/raw/genomic-exclude-$C"
  mkdir -p "$RESULT_DIR"
  bash kraken2.sh \
    -i "$FILE" \
    -o "$RESULT_DIR" \
    -b "$BUSCO_DB" \
    -k "$Kraken_DB" \
    -m exclude \
    -t "$TAXID" \
    -c "$C" \
    -p "$THREADS"
  ASM_DIR=$RESULT_DIR/hifiasm
  bash hifiasm.sh \
  -i ${RESULT_DIR}/${BASENAME}.fasta.gz \
  -o ${ASM_DIR} \
  -b ${BUSCO_DB} \
  -p ${THREADS}
done

# test for protein database
Kraken_DB="$HOME/project_data/downy/KrakenDB/contam-protein"
for C in "${CONF[@]}"; do
  RESULT_DIR="$HOME/project_data/downy/Kraken2/raw/protein-exclude-$C"
  mkdir -p "$RESULT_DIR"
  bash kraken2.sh \
    -i "$FILE" \
    -o "$RESULT_DIR" \
    -b "$BUSCO_DB" \
    -k "$Kraken_DB" \
    -m exclude \
    -t "$TAXID" \
    -c "$C" \
    -p "$THREADS"
  ASM_DIR=$RESULT_DIR/hifiasm
  bash hifiasm.sh \
  -i ${RESULT_DIR}/${BASENAME}.fasta.gz \
  -o ${ASM_DIR} \
  -b ${BUSCO_DB} \
  -p ${THREADS}
done
