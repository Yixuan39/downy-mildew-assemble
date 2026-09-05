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

## Notes

**These scripts came from a collaborator and are recorded here for provenance, not for reuse
as-is.** They are LSF (`bsub`) rather than SLURM, and every path - inputs, outputs, conda
environments, model caches - is hardcoded to the collaborator's filesystem. They will
not run on our cluster without rewriting those paths. `mining-rxlr.sh` additionally needs the
`find_*.pl` scripts from the collaborator's `mining_RLXR` directory, which are not in this
repository.
