# Secretome and effectome

`secretome-effectome.sh` is a four-isolate SLURM array. It filters Helixer proteins through SignalP, TargetP, DeepTMHMM and NetGPI, then runs EffectorP3 and EffectorO on the soluble secretome. It reads `results/repeatmask-gene-prediction/focal/helixer/*.faa` and writes per-isolate FASTAs and ID lists under `results/secretome-effectome/`. The named mamba environments and licensed tools must be available on the cluster.

The combined array script was introduced during the September 2026 reorganization. Git history does not confirm an end-to-end cluster run; compare its output with the cluster result tree before using it as exact run provenance.
