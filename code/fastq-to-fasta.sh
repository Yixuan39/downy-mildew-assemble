#!/bin/bash

INPUT_FOLDER=$HOME/project_data/downy/data
FILES=$(find ${INPUT_FOLDER} -name "*.fastq.gz")
OUTPUT_FOLDER=$HOME/project_data/downy/data-fasta
mkdir -p $OUTPUT_FOLDER

for FILE in $FILES
do
    echo "Processing file $FILE"
    FILENAME=$(basename $FILE)
    FILENAME=${FILENAME%.fastq.gz}
    OUTPUT_FILE=$OUTPUT_FOLDER/$FILENAME.fasta
    seqtk seq -A $FILE > $OUTPUT_FILE
    gzip $OUTPUT_FILE
done