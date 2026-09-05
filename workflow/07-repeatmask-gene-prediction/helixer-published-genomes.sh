#!/bin/bash
#SBATCH --array=0-10
#SBATCH -p gpu
#SBATCH -c 24

# ----------------------------------------------------------------------------------------
# Purpose : Same Helixer prediction for the published genomes, giving a like-for-like gene set for the
#           annotation comparison.
# Inputs  : $HOME/project_data/downy/downy-mildew-genomes/hardmasked/*.fna.gz
# Outputs : $HOME/project_data/downy/downy-mildew-genomes/helixer/
# Runs on : NCSU BRC GPU partition, SLURM array 0-10, 24 cores, apptainer --nv
# Usage   : sbatch workflow/07-repeatmask-gene-prediction/helixer-other-genomes.sh
# ----------------------------------------------------------------------------------------

INPUT_DIR=$HOME/project_data/downy/downy-mildew-genomes/hardmasked
RESULT_DIR=$HOME/project_data/downy/downy-mildew-genomes/helixer
FILES=($(find "$INPUT_DIR" -type f -name "*.fna.gz"))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

echo "Processing: $FILE"
BASENAME=$(basename ${FILE})  
BASENAME=${BASENAME%.fna.gz}
gzip -d -k ${FILE}
mkdir -p ${RESULT_DIR}/${BASENAME}

nvidia-smi
# apptainer run --nv ~/helixer-docker_helixer_v0.3.6_cuda_12.2.2-cudnn8.sif Helixer.py \
apptainer run --nv docker://gglyptodon/helixer-docker:helixer_v0.3.6_cuda_12.2.2-cudnn8 Helixer.py \
  --fasta-path ${FILE%.gz} --lineage fungi \
  --min-coding-length 150 \
  --gff-output-path ${RESULT_DIR}/${BASENAME}/${BASENAME}.gff
  
sed -i 's/ID=_/ID=/g; s/Parent=_/Parent=/g' ${RESULT_DIR}/${BASENAME}/${BASENAME}.gff

gffread \
  ${RESULT_DIR}/${BASENAME}/${BASENAME}.gff \
  -g ${FILE%.gz} \
  -y ${RESULT_DIR}/${BASENAME}/${BASENAME}.faa
  


rm ${FILE%.gz}
rm ${FILE%.gz}.fai
