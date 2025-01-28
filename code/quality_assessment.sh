#!/bin/bash

# input folder argument
input_folder=$1
threads=24
BUSCO_DB=$HOME/project_data/downy/BUSCO_DB
# get the fasta file full name
files=$(find ${input_folder} -name "*.fasta.gz")
dirs=$(dirname ${files} | sort | uniq)

for dir in ${dirs}; do
    mkdir -p ${dir}/quality
    echo "Processing ${dir}"
    files=$(find ${dir} -name "*.fasta.gz")
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
    mv ${dir}/compleasm-eukaryota/$(basename ${file})/summary.txt ${dir}/quality/compleasm-eukaryota-$(basename ${file}).txt
    mv ${dir}/compleasm-stramenopiles/$(basename ${file})/summary.txt ${dir}/quality/compleasm-stramenopiles-$(basename ${file}).txt
    done
    quast.py --output-dir ${dir}/quast \
            --threads ${threads} \
            --eukaryote \
            ${files}
    mv ${dir}/quast/report.tsv ${dir}/quality/quast.tsv
    rm -rf ${dir}/compleasm-eukaryota
    rm -rf ${dir}/compleasm-stramenopiles
    rm -rf ${dir}/quast
done