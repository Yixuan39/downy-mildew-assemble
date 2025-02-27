#!/bin/bash
#SBATCH --array=1-3
#SBATCH --cpus-per-task=24
#SBATCH --mem=0

EV=1e-10
threads=24

###########################################################################
# classify sequence first, then assemble with metaMDBG                    #
###########################################################################

INPUT_FOLDER=$HOME/project_data/downy/data
FILES=(${INPUT_FOLDER}/*.fastq.gz)
FILE=$(basename "${FILES[$((SLURM_ARRAY_TASK_ID - 1))]}")

# assemble sequence first, then remove contamination sequence use protein search
cat $HOME/project_data/downy/ref-seq/contam-protein.fasta.gz \
    $HOME/project_data/downy/ref-seq/protein-bfh.fasta.gz > $HOME/project_data/downy/ref-seq/contam-large-protein.fasta.gz
DB=$HOME/project_data/downy/ref-seq/contam-large-protein.fasta.gz
RESULT_PATH=$HOME/project_data/downy/mmseqs_result/classify-assemble-contam-protein
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
--invert-match \
--threads ${threads} \
--pattern-file ${RESULT_PATH}/${EV}/${FILE}.txt \
--out-file ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz \
${INPUT_FOLDER}/${FILE}

metaMDBG asm \
    --out-dir ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm \
    --in-hifi ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz \
    --threads ${threads}
    
mv ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm/contigs.fasta.gz ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz
rm -rf ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.fasta.gz_asm
rm ${RESULT_PATH}/${EV}/${FILE%.fastq.gz}.tmp.fasta.gz
rm ${RESULT_PATH}/${EV}/${FILE}.txt 
rm -rf ${RESULT_PATH}/${EV}/tmp
    