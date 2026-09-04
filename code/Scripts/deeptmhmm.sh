source /usr/local/apps/conda/miniconda3/26.3.2/etc/profile.d/conda.sh
conda activate /rs1/researchers/t/tbadhika/cjmantil/envs/deeptmhmm_env

export HOME=/rs1/researchers/t/tbadhika/cjmantil/biolib_home

CHUNKDIR="/rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/05_secretome/02_deeptmhmm/SC1982_chunks_100"
OUTBASE="/rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/05_secretome/02_deeptmhmm/SC1982_results"

mkdir -p "$OUTBASE"

for fasta in "$CHUNKDIR"/*.faa
do
    chunk=$(basename "$fasta" .faa)
    outdir="$OUTBASE/$chunk"

    mkdir -p "$outdir"

    if [[ -f "$outdir/COMPLETED.ok" ]]; then
        echo "Skipping completed chunk: $chunk"
        continue
    fi

    echo "Starting $chunk"
    date

    cp "$fasta" "$outdir/input.faa"
    cd "$outdir"

    if biolib run DTU/DeepTMHMM --fasta input.faa
    then
        touch COMPLETED.ok
        echo "Finished $chunk"
    else
        echo "FAILED: $chunk"
        rm -f COMPLETED.ok
        break
    fi

    date
done

echo "Loop finished."
