
# bash file that run all mmseqs scripts

EVALUES=(1e-5 1e-10 1e-15 1e-20)

for EVALUE in ${EVALUES}; do
    echo "Running mmseqs search with evalue ${EVALUE}"
    bash mmseqs2/asm-mmseq-contam-genome.sh ${EVALUE}
    bash mmseqs2/asm-mmseq-contam-protein.sh ${EVALUE}
    bash mmseqs2/asm-mmseq-extract-genome.sh ${EVALUE}
    bash mmseqs2/asm-mmseq-extract-protein.sh ${EVALUE}
done