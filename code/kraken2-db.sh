THREADS=32
REF_PATH=/data/run/yyang/project_data/downy/ref-seq/
# download kraken2 bacteria
kraken2-build --download-library bacteria --db ${REF_PATH}/genome --threads ${THREADS} --use-ftp --no-masking
kraken2-build --download-library bacteria --db ${REF_PATH}/protein --threads ${THREADS} --use-ftp --no-masking --protein
# download kraken2 fungi
kraken2-build --download-library fungi --db ${REF_PATH}/genome --threads ${THREADS} --use-ftp --no-masking
kraken2-build --download-library fungi --db ${REF_PATH}/protein --threads ${THREADS} --use-ftp --no-masking --protein
# download kraken2 human
kraken2-build --download-library human --db ${REF_PATH}/genome --threads ${THREADS} --use-ftp --no-masking
kraken2-build --download-library human --db ${REF_PATH}/protein --threads ${THREADS} --use-ftp --no-masking --protein

# combine genome files
FILES=$(find ${REF_PATH}/genome -name "*.fna")
cat FILES | pigz > ${REF_PATH}/genome-bfh.fna.gz
# rm -rf ${REF_PATH}/genome
# combine protein files
FILES=$(find ${REF_PATH}/protein -name "*.faa")
cat FILES | pigz > ${REF_PATH}/protein-bfh.faa.gz
# rm -rf ${REF_PATH}/protein