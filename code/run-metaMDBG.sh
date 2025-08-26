#!/bin/bash
#SBATCH --job-name=metaMDBG
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24


INPUT_DIR=$HOME/project_data/downy/GSL_Data/filtered_fastq
RESULT_DIR=$HOME/project_data/downy/metaMDBG
FILES=($(find "$INPUT_DIR" -type f -name "*.fastq.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
THREADS=24

BASENAME=$(basename $FILE)  
BASENAME=${BASENAME%.fastq.gz}  
# Create output directories
mkdir -p "${RESULT_DIR}/${BASENAME}"
mkdir -p "${RESULT_DIR}/compleasm"

echo "Processing file: $FILE"
metaMDBG asm \
  --out-dir ${RESULT_DIR}/${BASENAME} \
  --in-hifi ${FILE} \
  --threads ${THREADS}
mv ${RESULT_DIR}/${BASENAME}/contigs.fasta.gz ${RESULT_DIR}/${BASENAME}.fasta.gz
rm -r ${RESULT_DIR}/${BASENAME}

echo "Running quality-check..."
python quality-check.py \
    --input_file "${RESULT_DIR}/${BASENAME}.fasta.gz" \
    --output_dir "${RESULT_DIR}/compleasm" \
    --suffix "${BASENAME}" \
    --library_path "${BUSCO_DB}" \
    --threads "${THREADS}"

echo "Generating seqkit summary..."
seqkit fx2tab \
    -n -l -j "${THREADS}" \
    "${RESULT_DIR}/${BASENAME}.fasta.gz" \
    | gzip > "${RESULT_DIR}/compleasm/${BASENAME}.tsv.gz"
