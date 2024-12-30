#!/bin/bash

KrakenDB="/data/run/yyang/project_data/downy/KrakenDB-whole-protein"
oomycetePath="/data/run/yyang/project_data/downy/ref-seq-prot"
contamPath="/data/run/yyang/project_data/downy/contam-prot"
threads=32

# Here we are not using the --protein flag, because we use protein sequences translated from the nucleotide sequences
kraken2-build --download-taxonomy --db ${KrakenDB} --use-ftp --threads ${threads}
# download bacterial, fungi, human protein sequences to the Kraken2 database
kraken2-build --download-library bacteria --db ${KrakenDB} --protein --use-ftp --threads ${threads}
kraken2-build --download-library fungi --db ${KrakenDB} --protein --use-ftp --threads ${threads}
kraken2-build --download-library human --db ${KrakenDB} --protein --use-ftp --threads ${threads}

# add oomycete protein sequences to the Kraken2 database
oomyceteFiles=$(ls ${oomycetePath})
for FILE in ${oomyceteFiles}; do
    echo "adding ${FILE}..."
    kraken2-build --add-to-library ${oomycetePath}/${FILE} --db ${KrakenDB} --protein --threads ${threads}
done
# add possible contaminant protein sequences to the Kraken2 database
contamFiles=$(ls ${contamPath})
for FILE in ${contamFiles}; do
    echo "adding ${FILE}..."
    kraken2-build --add-to-library ${contamPath}/${FILE} --db ${KrakenDB} --protein --threads ${threads}
done

kraken2-build --build --db ${KrakenDB} --protein --threads ${threads}

# build for genomic database

KrakenDB="/data/run/yyang/project_data/downy/KrakenDB-whole-genome"
oomycetePath="/data/run/yyang/project_data/downy/ref-seq"
contamPath="/data/run/yyang/project_data/downy/contam"
threads=32

# Here we are not using the --protein flag, because we use protein sequences translated from the nucleotide sequences
kraken2-build --download-taxonomy --db ${KrakenDB} --use-ftp --threads ${threads}
# download bacterial, fungi, human protein sequences to the Kraken2 database
kraken2-build --download-library bacteria --db ${KrakenDB} --use-ftp --threads ${threads}
kraken2-build --download-library fungi --db ${KrakenDB} --use-ftp --threads ${threads}
kraken2-build --download-library human --db ${KrakenDB} --use-ftp --threads ${threads}

# add oomycete protein sequences to the Kraken2 database
oomyceteFiles=$(ls ${oomycetePath})
for FILE in ${oomyceteFiles}; do
    echo "adding ${FILE}..."
    kraken2-build --add-to-library ${oomycetePath}/${FILE} --db ${KrakenDB} --threads ${threads}
done
# add possible contaminant protein sequences to the Kraken2 database
contamFiles=$(ls ${contamPath})
for FILE in ${contamFiles}; do
    echo "adding ${FILE}..."
    kraken2-build --add-to-library ${contamPath}/${FILE} --db ${KrakenDB} --threads ${threads}
done

kraken2-build --build --db ${KrakenDB} --threads ${threads}

