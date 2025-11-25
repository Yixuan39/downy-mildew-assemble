#!/bin/bash
#SBATCH --job-name=hifiasm_meta
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

INPUT_DIR=$HOME/project_data/downy/GSL_Data/fastq/filtered
RESULT_DIR=$HOME/project_data/downy/hifiasm-meta
FILES=($(find "$INPUT_DIR" -type f -name "*.fastq.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
THREADS=32
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB

mkdir -p "${RESULT_DIR}/${BASENAME}"
mkdir -p "${RESULT_DIR}/compleasm"

echo "Processing: $FILE"
hifiasm_meta \
    -t "${THREADS}" \
    -o "${RESULT_DIR}/${BASENAME}/${BASENAME}.asm" \
    "${FILE}"

echo "Converting GFA to FASTA..."
gfatools gfa2fa \
    "${RESULT_DIR}/${BASENAME}/${BASENAME}.asm.p_ctg.gfa" \
    > "${RESULT_DIR}/${BASENAME}/${BASENAME}.asm.p_ctg.fa"

gzip -c "${RESULT_DIR}/${BASENAME}/${BASENAME}.asm.p_ctg.fa" \
    > "${RESULT_DIR}/${BASENAME}.fasta.gz"

echo "Running quality-check..."
python quality-check.py \
    --input_file "${RESULT_DIR}/${BASENAME}.fasta.gz" \
    --output_dir "${RESULT_DIR}/compleasm" \
    --suffix "${BASENAME}" \
    --library_path "${BUSCO_DB}" \
    --threads "${THREADS}"
