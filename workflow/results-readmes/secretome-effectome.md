# results/secretome-effectome/

Soluble secretome prediction and candidate effector catalogue for the four Helixer proteomes.
Produced by `workflow/10-secretome-effectome/` in the `downy-mildew-assemble` repo, following the
pipeline order in `manuscript/methods.md`: SignalP6 -> TargetP/DeepTMHMM/NetGPI exclusion ->
soluble secretome -> DeepLoc (supplementary) -> WY-motif/RXLR effector mining -> summary.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `01-signalp6/<ASM>.signalp_positive.faa` | SignalP 6 signal-peptide-positive set. | 02, 03, 04 | Zenodo (secretome tables) |
| `{02-targetp,03-deeptmhmm,04-netgpi}/<ASM>.*.ids` | Exclusion lists (mitochondrial-targeted, transmembrane, GPI-anchored) computed on the SignalP-positive set. | `05-soluble-secretome` | Zenodo (secretome tables) |
| `05-soluble-secretome/<ASM>_soluble_secretome.faa` | SignalP+ minus mTP minus TM minus GPI. | 06, 07, 08 | Zenodo (secretome tables) |
| `06-deeploc/<ASM>/results_*.csv` | DeepLoc 2.1 subcellular localization of the soluble secretome (supplementary, not a filter). | manuscript (supplementary) | Zenodo |
| `07-effectors/<ASM>/` | WY-domain (hmmsearch) and RXLR/RXLR-like (`find_*.pl`) effector calls over the soluble secretome. | `09-summarize`, manuscript table | Zenodo (effectome tables) |
| `secretome_summary.tsv` | Per-assembly effector/secretome counts for the manuscript table. | manuscript table | in the repo once copied to `data/` |

## Notes

**This stage is not run end-to-end yet.** The scripts require license-gated academic tools
(SignalP 6.0, TargetP 2.0, DeepTMHMM, NetGPI 1.1, DeepLoc 2.1) installed under
`$HOME/miniforge3/envs` before they can run - see `workflow/10-secretome-effectome/README.md` for
sources - and three parsing assumptions (SignalP prediction-table column, TargetP/NetGPI label
names, and DeepTMHMM's >40 aa post-cleavage TM filter) still need validating against a real run.
The manuscript Methods also describes several effectome analyses (EffectorP/EffectorO, CRN,
EffectR, NLPs, EPI/EPIC, SCRs, CAZymes/dbCAN3) with **no corresponding scripts** in this repo -
see "Methods steps NOT scripted" in the stage README before claiming full reproduction of the
effectome table.
