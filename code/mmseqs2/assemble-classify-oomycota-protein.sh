#!/bin/bash
#SBATCH --array=0-2
#SBATCH --cpus-per-task=24
#SBATCH --mem=0

EV=1e-10
threads=24

###########################################################################
# assemble with metaMDBG first, then classify sequence                    #
###########################################################################

INPUT_FOLDER=$HOME/project_data/downy/metaMDBG
FILES=($(ls ${INPUT_FOLDER}/*.fasta.gz 2>/dev/null))
FILE=${FILES[$SLURM_ARRAY_TASK_ID]} 
FILE=$(basename $FILE)

# assemble sequence first, then extract oomycota sequence use protein search

DB=$HOME/project_data/downy/ref-seq/oomycota-protein.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-oomycota-protein
mkdir -p ${RESULT_PATH}/${EV}

# run mmseqs2 on the assembly
mmseqs easy-search \
${INPUT_FOLDER}/${FILE} \
${DB} \
${RESULT_PATH}/${EV}/${FILE}.txt \
${RESULT_PATH}/${EV}/tmp \
-e ${EV} \
--max-accept 1 \
--search-type 2 \
--translation-mode 1 \
--format-mode 4 \
--format-output query

seqkit grep \
--threads ${threads} \
--pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
--out-file ${RESULT_PATH}/${EV}/${FILE} \
${INPUT_FOLDER}/${FILE} 

rm ${RESULT_PATH}/${EV}/${FILE}.txt 
rm -rf ${RESULT_PATH}/${EV}/tmp
