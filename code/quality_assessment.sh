#!/bin/bash

# input folder argument
input_folder=$1
threads=32
BUSCO_DB="/data/run/yyang/project_data/downy/BUSCO_DB"
# get the fasta file full name
files=$(find ${input_folder} -name "*.fasta")
dirs=$(dirname ${files} | sort | uniq)

for dir in ${dirs}; do
    echo "Processing ${dir}"
    files=$(find ${dir} -name "*.fasta")
    for file in ${files}; do
        compleasm run --assembly_path ${file} \
                  --output_dir $(dirname ${file})/compleasm-eukaryota/$(basename ${file}) \
                  --library_path ${BUSCO_DB} \
                  --threads ${threads} \
                  --lineage eukaryota_odb10
        compleasm run --assembly_path ${file} \
                  --output_dir $(dirname ${file})/compleasm-stramenopiles/$(basename ${file}) \
                  --library_path ${BUSCO_DB} \
                  --threads ${threads} \
                  --lineage stramenopiles_odb10
    done
    quast.py --output-dir ${dir}/quast \
            --threads ${threads} \
            --eukaryote \
            ${files}
done


#    busco --in ${dir} \
#          --mode genome \
#          --auto-lineage-euk \
#          --download_path ${BUSCO_DB} \
#          --cpu ${threads} \
#          --force \
#          --tar