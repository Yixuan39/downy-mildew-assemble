#!/bin/bash

# ----------------------------------------------------------------------------------------
# Purpose : Loop the collaborator's find_*.pl motif scripts over the final soluble secretome to annotate
#           RXLR and RXLR-like effectors.
# Inputs  : <isolate>_final_soluble_secretome.faa; find_*.pl under
#           /rs1/.../07_effector_annotation/mining_RLXR
# Outputs : motif_results/<sample>_<motif>.output
# Runs on : collaborator system, interactive shell (not a batch job); edit $input and $script_dir before
#           running
# Usage   : bash workflow/10-secretome-effectome/mining-rxlr.sh
# ----------------------------------------------------------------------------------------
## Loop for running the annotation of RXLRs and RXLR-like

input="OR502AA_final_soluble_secretome.faa"
script_dir="/rs1/researchers/t/tbadhika/cjmantil/2_paper_genomes/07_effector_annotation/mining_RLXR"

sample=$(basename "$input" .faa)

mkdir -p motif_results

for script in "$script_dir"/find_*.pl; do
    name=$(basename "$script" .pl)
    output="motif_results/${sample}_${name}.output"

    echo "Running $name..."
    printf "%s\n%s\n" "$input" "$output" | perl "$script"
done
