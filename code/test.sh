EV=$1
threads=32
INPUT_FOLDER=/data/run/yyang/project_data/downy/metaMDBG
FILES=$(ls ${INPUT_FOLDER}/*.fasta.gz 2>/dev/null | xargs -n 1 basename)

# assemble sequence first, then extract oomycota sequence use genome search

DB=/data/run/yyang/project_data/downy/ref-seq/oomycota-genome.fasta.gz
RESULT_PATH=/data/run/yyang/project_data/downy/mmseqs_result/test
mkdir -p ${RESULT_PATH}

for FILE in ${FILES}; do
    # run mmseqs2 on the assembly
    mmseqs easy-search \
    ${INPUT_FOLDER}/${FILE} \
    ${DB} \
    ${RESULT_PATH}/${FILE}.tmp \
    tmp \
    -e 1e-3 \
    --search-type 3 \
    --sort-results 1 \
    --db-output 1
    
    mmseqs filterdb ${RESULT_PATH}/${FILE}.tmp ${RESULT_PATH}/${FILE}.best.tmp --extract-lines 1
    
    mmseqs convert2fasta ${RESULT_PATH}/${FILE}.best.tmp ${RESULT_PATH}/${FILE%.gz}

done