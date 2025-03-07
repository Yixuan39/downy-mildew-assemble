#!/bin/bash
# This script convert fcs db to fasta

GX_DB=$HOME/project_data/downy/fcs-db/
INPUT="../3cols.txt"
GX_FASTA=$HOME/project_data/downy/fcs-db/all.fasta

gx get-fasta \
  --input $INPUT \
  --gx-db $GX_DB \
  --output $GX_FASTA