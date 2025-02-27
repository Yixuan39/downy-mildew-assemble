#!/bin/bash
#SBATCH --array=1-3
#SBATCH --cpus-per-task=24
#SBATCH --mem=0

EV=1e-10
threads=24

###########################################################################
# assemble with metaMDBG first, then classify sequence                    #
###########################################################################

INPUT_FOLDER=$HOME/project_data/downy/metaMDBG
FILES=(${INPUT_FOLDER}/*.fastq.gz)
FILE=$(basename "${FILES[$((SLURM_ARRAY_TASK_ID - 1))]}")

# assemble sequence first, then extract oomycota sequence use genome search

DB=$HOME/project_data/downy/ref-seq/oomycota-genome.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-oomycota-genome
mkdir -p ${RESULT_PATH}/${EV}

# run mmseqs2 on the assembly
mmseqs easy-search \
${INPUT_FOLDER}/${FILE} \
${DB} \
${RESULT_PATH}/${EV}/${FILE}.txt \
${RESULT_PATH}/${EV}/tmp \
-e ${EV} \
--max-accept 1 \
--search-type 3 \
--format-mode 4 \
--format-output query

seqkit grep \
--threads ${threads} \
--pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
--out-file ${RESULT_PATH}/${EV}/${FILE} \
${INPUT_FOLDER}/${FILE} 

rm ${RESULT_PATH}/${EV}/${FILE}.txt
rm -rf ${RESULT_PATH}/${EV}/tmp
