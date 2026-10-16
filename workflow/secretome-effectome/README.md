# Secretome and effectome

Run in order for the three focal isolates; outputs are in `results/secretome-effectome/<assembly>/`.

1. `secretome-effectome.sh`: Helixer proteins → SignalP 6 (cleavage site 10-40) → drop TargetP 2 mTP → drop DeepTMHMM TM helices after the cleavage site.
2. `netgpi.R` (env `ragp`; needs internet): NetGPI 1.1 web predictions.
3. `effectorp.sh`: drop GPI-anchored proteins → soluble secretome → EffectorP 3.
4. `secretome-counts.R`: proteins kept at each step → `secretome_counts.tsv`.
