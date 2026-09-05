#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Screen the SignalP-positive proteins for transmembrane helices with DeepTMHMM, in 100-sequence
#           chunks; proteins with TM helices are dropped from the soluble secretome.
# Inputs  : SignalP6 output chunked to *.faa
# Outputs : one DeepTMHMM result directory per chunk
# Runs on : collaborator system, LSF (bsub); all paths under /rs1/researchers/t/tbadhika/cjmantil
# Usage   : bsub < workflow/10-secretome-effectome/deeptmhmm.sh
# ----------------------------------------------------------------------------------------
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
