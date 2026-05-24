#!/bin/bash
#SBATCH --array=0-3
#SBATCH -p gpu
#SBATCH -c 24

INPUT_DIR=$HOME/project_data/downy/contigs-renamed/hardmasked
RESULT_DIR=$HOME/project_data/downy/contigs-renamed/helixer
FILES=($(find "$INPUT_DIR" -type f -name "*.fasta.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
mkdir -p ${RESULT_DIR}
echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fasta.gz}
gzip -d -k ${FILE}

nvidia-smi

apptainer run --nv docker://gglyptodon/helixer-docker:helixer_v0.3.6_cuda_12.2.2-cudnn8 Helixer.py \
  --fasta-path ${FILE%.gz} --lineage fungi \
  --min-coding-length 150 \
  --gff-output-path ${RESULT_DIR}/${BASENAME}.gff
  
sed -i 's/ID=_/ID=/g; s/Parent=_/Parent=/g' ${RESULT_DIR}/${BASENAME}.gff

gffread \
  ${RESULT_DIR}/${BASENAME}.gff \
  -g ${FILE%.gz} \
  -y ${RESULT_DIR}/${BASENAME}.faa
  
rm ${FILE%.gz}
rm ${FILE%.gz}.fai
