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

# assemble sequence first, then remove contamination sequence use genome search
cat $HOME/project_data/downy/ref-seq/contam-genome.fasta.gz \
    $HOME/project_data/downy/ref-seq/genome-bfh.fasta.gz > $HOME/project_data/downy/ref-seq/contam-large-genome.fasta.gz
DB=$HOME/project_data/downy/ref-seq/contam-large-genome.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/assemble-classify-contam-genome
mkdir -p ${RESULT_PATH}/${FILE}_tmp

# run mmseqs2 on the assembly
mmseqs easy-search \
${INPUT_FOLDER}/${FILE} \
${DB} \
${RESULT_PATH}/${FILE}.txt \
${RESULT_PATH}/${FILE}_tmp \
-e ${EV} \
--max-accept 1 \
--search-type 3 \
--format-mode 4 \
--format-output query

seqkit grep \
--invert-match \
--threads ${threads} \
--pattern-file ${RESULT_PATH}/${FILE}.txt \
--out-file ${RESULT_PATH}/${FILE} \
${INPUT_FOLDER}/${FILE} 

rm ${RESULT_PATH}/${FILE}.txt 
rm -rf ${RESULT_PATH}/${FILE}_tmp
