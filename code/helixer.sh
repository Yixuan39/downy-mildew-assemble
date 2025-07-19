#!/bin/bash
#SBATCH --array=0-2
#SBATCH --cpus-per-task=32

INPUT_DIR=$HOME/project_data/downy/hifiasm/fcs-gx/purge_dups
RESULT_DIR=$INPUT_DIR/helixer
FILES=($(find "$INPUT_DIR" -type f -name "*.fasta.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
BUSCO_DB="$HOME/project_data/downy/BUSCO_DB"
THREADS=32
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fasta.gz}
gzip -d -k ${FILE}

helixerlite \
  --cpus ${THREADS} \
  --lineage fungi \
  --fasta ${FILE%.gz} \
  --out ${RESULT_DIR}/${BASENAME}.gff

gffread \
  ${RESULT_DIR}/${BASENAME}.gff \
  -g ${FILE%.gz} \
  -y ${RESULT_DIR}/${BASENAME}.faa
  
gffread \
  ${RESULT_DIR}/${BASENAME}.gff \
  -g ${FILE%.gz} \
  -x ${RESULT_DIR}/${BASENAME}.fasta
  
gzip -f ${RESULT_DIR}/${BASENAME}.fasta
  
python quality-check.py \
  --input_file "${RESULT_DIR}/${BASENAME}.fasta.gz" \
  --output_dir "${RESULT_DIR}/compleasm" \
  --suffix ${BASENAME} \
  --library_path ${BUSCO_DB} \
  --threads ${THREADS}

seqkit fx2tab \
  "${RESULT_DIR}/${BASENAME}.fasta.gz" \
  -n -l -j ${THREADS} \
  -o "${RESULT_DIR}/compleasm/${BASENAME}.tsv.gz"

rm ${FILE%.gz}
rm ${FILE%.gz}.fai