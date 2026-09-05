# Stage 10 - Secretome and effector prediction

The secretome pipeline: SignalP 6 for secretion signals, DeepTMHMM to drop transmembrane proteins,
TargetP and DeepLoc for subcellular targeting, then WY-motif hmmsearch and the RXLR motif scripts
for effector classification.

## Scripts

| file | what it does | resources |
|---|---|---|
| `deeploc.sh` | DeepLoc 2.1 subcellular localisation of the SignalP-positive proteins. | LSF |
| `deeptmhmm.sh` | Screen the SignalP-positive proteins for transmembrane helices with DeepTMHMM, in 100-sequence chunks; proteins with TM helices are dropped from the soluble secretome. | LSF (bsub); paths hardcoded - see notes |
| `mining-rxlr.sh` | Loop the collaborator's find_*.pl motif scripts over the soluble secretome to annotate RXLR and RXLR-like effectors. | external system - see notes |
| `signalp6.sh` | SignalP 6 secretion-signal prediction over the Helixer proteomes - the first filter of the secretome pipeline. | LSF |
| `targetp.sh` | TargetP 2.0 subcellular-targeting prediction, used alongside SignalP to define the secretome. | LSF |
| `wy-motif-hmmsearch.sh` | hmmsearch the soluble secretome with the WY-motif HMM to identify WY-domain effector candidates. | external system - see notes |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| SignalP6 / TargetP | `per-isolate output directories` | Secretion signal-peptide predictions that define the secretome. | deeploc.sh, deeptmhmm.sh, mining-rxlr.sh, wy-motif-hmmsearch.sh | Zenodo (secretome tables) |
| DeepLoc / DeepTMHMM | `prediction tables / one result dir per 100-seq chunk` | Subcellular localization and transmembrane-helix filters applied to the SignalP-positive set. | final soluble secretome | Zenodo (secretome tables) |
| RxLR / WY effector calls | `motif_results/<sample>_<motif>.output; hmmsearch output` | RxLR and WY-motif effector candidates from the soluble secretome. | manuscript Table 3 | Zenodo (effectome tables) |

## Notes

**These scripts came from a collaborator and are recorded here for provenance, not for reuse
as-is.** They are LSF (`bsub`) rather than SLURM, and every path - inputs, outputs, conda
environments, model caches - is hardcoded to the collaborator's filesystem. They will
not run on our cluster without rewriting those paths. `mining-rxlr.sh` additionally needs the
`find_*.pl` scripts from the collaborator's `mining_RLXR` directory, which are not in this
repository.
