#!/bin/bash

THREADS=24
INPUT_FOLDER=$HOME/project_data/downy/metaMDBG
FILES=$(find ${INPUT_FOLDER} -name "*.fasta.gz")
RESULT_PATH=$HOME/project_data/downy/simple-rm-contam-raw/
GX_DB=$HOME/project_data/downy/fcs-db/
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
export GX_NUM_CORES=$THREADS

for file in ${FILES}; do
    # check contamination in the genome, 4762 is the tax id for oomycota.
    run_gx.py --fasta ${file} \
              --tax-id 4762 \
              --gx-db ${GX_DB} \
              --out-dir ${RESULT_PATH} \
              --out-basename $(basename ${file%.fasta.gz})
    # exclude contam read...
    gx clean-genome \
              --input ${file} \
              --action-report ${RESULT_PATH}/$(basename ${file%.fasta.gz}).fcs_gx_report.txt \
              --output ${RESULT_PATH}/$(basename ${file%.gz})
    gzip ${RESULT_PATH}/$(basename ${file%.gz})
    # get quality report
    python quality_check.py \
              --input_file ${RESULT_PATH}/$(basename ${file}) \
              --output_dir ${RESULT_PATH} \
              --suffix $(basename ${file%.fasta.gz})
              --library_path ${BUSCO_DB} \
              --threads ${THREADS}
done

INPUT_FOLDER=$HOME/project_data/downy/data-fasta
FILES=$(find ${INPUT_FOLDER} -name "*.fasta.gz")
RESULT_PATH=$HOME/project_data/downy/simple-rm-contam-asm/

for file in ${FILES}; do
    # check contamination in the genome, 4762 is the tax id for oomycota.
    run_gx.py --fasta ${file} \
              --tax-id 4762 \
              --gx-db ${GX_DB} \
              --out-dir ${RESULT_PATH} \
              --out-basename $(basename ${file%.fasta.gz})
    # exclude contam read...
    gx clean-genome \
              --input ${file} \
              --action-report ${RESULT_PATH}/$(basename ${file%.fasta.gz}).fcs_gx_report.txt \
              --output ${RESULT_PATH}/$(basename ${file%.gz})
    gzip ${RESULT_PATH}/$(basename ${file%.gz})
    # get quality report
    python quality_check.py \
              --input_file ${RESULT_PATH}/$(basename ${file}) \
              --output_dir ${RESULT_PATH} \
              --suffix $(basename ${file%.fasta.gz})
              --library_path ${BUSCO_DB} \
              --threads ${THREADS}
done