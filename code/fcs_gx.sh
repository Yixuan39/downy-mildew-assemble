#!/bin/bash

# input folder argument
export GX_NUM_CORES=24
input_folder=$HOME/project_data/downy/Kraken-result/
GX_DB=$HOME/project_data/downy/fcs-db/
# get the fasta file full name
files=$(find ${input_folder} -name "*.fasta.gz")
dirs=$(dirname ${files} | sort | uniq)

for dir in ${dirs}; do
    out_dir=${dir}/verification
    mkdir -p ${out_dir}
    echo "Processing ${dir}"
    files=$(find ${dir} -name "*.fasta.gz")
    for file in ${files}; do
        # check contamination in the genome, 4762 is the tax id for oomycota.
        run_gx.py --fasta ${file} \
                  --tax-id 4762 \
                  --gx-db ${GX_DB} \
                  --out-dir ${out_dir} \
                  --out-basename $(basename ${file%.fasta.gz}) 
        # exclude contam read...
        gx clean-genome \
                  --input ${file} \
                  --action-report ${out_dir}/$(basename ${file%.fasta.gz}).fcs_gx_report.txt \
                  --output ${out_dir}/$(basename ${file})
    done
done

# the gx database was retrieved using this command:
# sync_files.py get --mft=https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/database/latest/all.manifest --dir fcs-db/