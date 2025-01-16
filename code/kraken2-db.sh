THREADS=32
REF_PATH=/data/run/yyang/project_data/downy/ref-seq/
# download kraken2 bacteria
kraken2-build --download-library bacteria --db $REF_PATH/genome/bacteria --threads ${THREADS} --use-ftp --no-masking
kraken2-build --download-library bacteria --db $REF_PATH/protein/bacteria --threads ${THREADS} --use-ftp --no-masking --protein
# download kraken2 fungi
kraken2-build --download-library fungi --db $REF_PATH/genome/fungi --threads ${THREADS} --use-ftp --no-masking
kraken2-build --download-library fungi --db $REF_PATH/protein/fungi --threads ${THREADS} --use-ftp --no-masking --protein
# download kraken2 human
kraken2-build --download-library human --db $REF_PATH/genome/human --threads ${THREADS} --use-ftp --no-masking
kraken2-build --download-library human --db $REF_PATH/protein/human --threads ${THREADS} --use-ftp --no-masking --protein

# combine genome files
FILES=$(find $REF_PATH/genome -name "*.fna")
cat FILES | pigz > $REF_PATH/genome-bfh.fna.gz
rm -rf $REFPATH/genome
# combine protein files
FILES=$(find $REF_PATH/protein -name "*.faa")
cat FILES | pigz > $REF_PATH/protein-bfh.faa.gz
rm -rf $REFPATH/protein