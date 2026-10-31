# Secretome and effectome

Run in order for the three focal isolates and *P. effusa* UA202013*; outputs are in `results/secretome-effectome/<assembly>/`.

1. `secretome-effectome.sh`: Helixer proteins → SignalP 6 (cleavage site 10-40) → drop TargetP 2 mTP → drop DeepTMHMM TM helices after the cleavage site.
2. `netgpi.R` (env `ragp`; needs internet): NetGPI 1.1 web predictions.
3. `effectorp.sh`: drop GPI-anchored proteins → soluble secretome → EffectorP 3.
4. `../functional-annotation/build-gene-table.R` (env `R`): proteins kept at each step → `secretome_counts.tsv`, and the secretome columns of `data/gene_annotation_summary.xlsx`.

`build-gene-table.R` excludes `Pcub-MSU1_003_000782.1` as a suspected gene-model artifact (`curated_out` in `secretome_counts.tsv`, `curation_note` in the workbook): the final MSU1 secretome is 798 proteins rather than the raw pipeline's 799; the effector count remains 397. Raw prediction outputs are retained.
