#!/bin/bash
#SBATCH --job-name=minimap2
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

set -euo pipefail

# after cleaning with fcs, verify and clean with Kraken2
INPUT_DIR="$HOME/project_data/downy/flye/fcs-gx/kraken2"
RESULT_DIR="$INPUT_DIR/minimap2"
THREADS=32

mkdir -p "$RESULT_DIR"

FILES=("$INPUT_DIR"/*.fasta.gz)
FILE="${FILES[$SLURM_ARRAY_TASK_ID]}"
# get base name
BASENAME=$(basename "$FILE")  
BASENAME=${BASENAME%.fasta.gz}
QUERY="$HOME/project_data/downy/GSL_Data/filtered_fastq/$BASENAME.fastq.gz"
echo "Base name: $BASENAME"
echo "input: $FILE"
echo "query: $QUERY"

minimap2 -x map-hifi --secondary=no -a -t $THREADS $FILE $QUERY \
| samtools view -b -F 0x904 -q 30 \
| samtools fastq -n - \
| gzip > "${RESULT_DIR}/${BASENAME}.fastq.gz"

