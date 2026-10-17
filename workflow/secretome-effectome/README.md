# Secretome and effectome

Run in order for the three focal isolates; outputs are in `results/secretome-effectome/<assembly>/`.

1. `secretome-effectome.sh`: Helixer proteins → SignalP 6 (cleavage site 10-40) → drop TargetP 2 mTP → drop DeepTMHMM TM helices after the cleavage site.
2. `netgpi.R` (env `ragp`; needs internet): NetGPI 1.1 web predictions.
3. `effectorp.sh`: drop GPI-anchored proteins → soluble secretome → EffectorP 3.
4. `secretome-counts.R`: proteins kept at each step → `secretome_counts.tsv`.

Manuscript curation excludes `Pcub-MSU1_003_000782.1` as a suspected gene-model artifact: the final MSU1 secretome is 798 proteins rather than the raw pipeline's 799; the effector count remains 397. The exclusion is recorded in `data/gene_annotation_summary.xlsx` (`curation_note`). Raw prediction outputs are retained.
