#!/bin/bash

REF_SEQ=$HOME/project_data/downy/fcs-db/all.fasta
KRAKEN_DB=$HOME/project_data/downy/KrakenDB/fcs-kraken2
THREADS=24
mkdir -p $KRAKEN_DB

kraken2-build \
    --build \
    --db $KRAKEN_DB \
    --add-to-library $REF_SEQ \
    --threads $THREADS 
    
kraken2-inspect \
    --db $KRAKEN_DB \
    --use-mpa-style \
    --threads $THREADS \
    > $HOME/project_data/downy/KrakenDB/fcs-kraken2.txt
    
kraken2-build \
    --db $KRAKEN_DB \
    --clean 