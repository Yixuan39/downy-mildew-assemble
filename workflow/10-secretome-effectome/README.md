# Stage 10 - Secretome and effectome prediction

Predict the soluble secretome and catalogue candidate effectors for the four Helixer
proteomes (`Pseudoperonospora_cubensis_MSU1`, `Pseudoperonospora_cubensis_SC1982`,
`Pseudoperonospora_humuli_OR502AA`, and the `Peronospora_effusa` reassembly).

Order and roles follow the manuscript Methods (`manuscript/methods.md`):

```
SECRETOME
  01 SignalP 6       N-terminal signal peptide            -> SignalP-positive set (primary filter)
  02 TargetP 2.0     exclude mitochondrial (mTP)          \
  03 DeepTMHMM       drop transmembrane helices            } remove from SignalP-positive
  04 NetGPI 1.1      remove GPI-anchored proteins         /   -> 05 SOLUBLE SECRETOME
  06 DeepLoc 2.1     subcellular localization (SUPPLEMENTARY, not a filter)

EFFECTOME (over the soluble secretome)
  07 WY hmmsearch    WY-domain effectors (HMMER)
  08 RXLR mining     RXLR / RXLR-like effectors (find_*.pl)
  09 summarize       counts for the manuscript table
```

Steps 02-04 run on the SignalP-positive set and are independent (submit together); 05 waits
for 01-04; 06-08 run on the soluble secretome; 09 tallies.

## Scripts

SLURM array jobs over the four assemblies (`--array=0-3`); submit from the repo root. Names
encode pipeline order.

| file | what it does |
|---|---|
| `01-signalp6.sh` | SignalP 6 (Fast); writes the signal-peptide-positive set. |
| `02-targetp.sh` | TargetP 2.0 on the SignalP-positive set; lists mTP proteins to exclude. |
| `03-deeptmhmm.sh` | DeepTMHMM (100-seq chunks) on the SignalP-positive set; lists TM-bearing proteins. |
| `04-netgpi.sh` | NetGPI 1.1 on the SignalP-positive set; lists GPI-anchored proteins. |
| `05-combine-soluble-secretome.sh` | SignalP+ minus mTP minus TM minus GPI = soluble secretome. |
| `06-deeploc.sh` | DeepLoc 2.1 (Fast) localization of the soluble secretome (supplementary). |
| `07-wy-motif-hmmsearch.sh` | hmmsearch the soluble secretome with the WY HMM. |
| `08-mining-rxlr.sh` | `find_*.pl` RXLR / RXLR-like mining over the soluble secretome. |
| `09-summarize-secretome.sh` | Per-assembly counts into `secretome_summary.tsv`. |

## Methods steps NOT scripted in this repo

The Methods "Effectome annotation" describes several analyses for which **no scripts were
provided** with this project (the original stage-10 scripts covered only SignalP/TargetP/
DeepTMHMM/DeepLoc and WY + RXLR mining). To fully reproduce the manuscript's effectome, the
following still need scripts/inputs:

- **EffectorP 3.0** and **EffectorO** - ML effector prediction; effectome = union of both.
- **CRN effectors** - HMMER search with the published CRN HMM (Haas et al. 2009).
- **EffectR** (R package) - complements RXLR and CRN predictions (Methods: R v4.6.1).
- **NLPs** - BLASTp vs characterized *P. infestans* proteins + GHRHDWE-motif screen.
- **Kazal-like (EPI) / cystatin-like (EPIC)** protease inhibitors - BLASTp vs *P. infestans*.
- **SCRs** (small cysteine-rich proteins) - custom length/cysteine-content script.
- **CAZymes** - dbCAN3.

These are listed so the gap between the Methods text and the available scripts is explicit;
supply the scripts (or confirm they ran on the collaborator system) before claiming full
reproduction of the effectome table.

## Required tools

License-gated academic downloads (free for academic use, registration required), not bundled
here. Install each into the conda env its script names, under `$HOME/miniforge3/envs`:

| tool | env / location | how to obtain |
|---|---|---|
| SignalP 6.0 | `signalp6` | DTU Health Tech (SignalP 6.0); `pip install` the package into the env. |
| TargetP 2.0 | `$HOME/software/targetp-2.0` | DTU Health Tech; unpack there (script points to it). |
| DeepTMHMM 1.0.57 | `deeptmhmm` | `pip install pybiolib`; needs internet + a BioLib account/token. |
| NetGPI 1.1 | `netgpi` | DTU Health Tech; `pip install` into the env. Confirm the CLI/output columns. |
| DeepLoc 2.1 | `deeploc2` | DTU Health Tech; `pip install` into the env. |
| HMMER 3.4 + seqkit | `hmmer` | `conda create -n hmmer -c bioconda hmmer=3.4 seqkit` (`seqkit` used by 01/03/05). |
| RXLR `find_*.pl` | `$HOME/software/mining_RLXR` | Collaborator motif scripts (Win et al. 2007); not redistributable here. |
| WY HMM | `$SECR/WY_motif.hmm` | Published WY profile HMM (Boutemy et al. 2011). |

## Outputs

Paths under `$HOME/project_data/downy` on the cluster. Deposition column feeds `DATA_DEPOSITION.md`.

| output | path | consumed by | deposition |
|---|---|---|---|
| SignalP-positive set | `contigs-renamed/secretome/01-signalp6/<ASM>.signalp_positive.faa` | 02, 03, 04 | Zenodo (secretome tables) |
| Exclusion lists | `contigs-renamed/secretome/{02-targetp,03-deeptmhmm,04-netgpi}/<ASM>.*.ids` | 05-combine | Zenodo (secretome tables) |
| Soluble secretome | `contigs-renamed/secretome/05-soluble-secretome/<ASM>_soluble_secretome.faa` | 06, 07, 08 | Zenodo (secretome tables) |
| Localization | `contigs-renamed/secretome/06-deeploc/<ASM>/results_*.csv` | manuscript (supplementary) | Zenodo |
| Effector calls | `contigs-renamed/secretome/07-effectors/<ASM>/` | 09-summarize, manuscript table | Zenodo (effectome tables) |
| Summary | `contigs-renamed/secretome/secretome_summary.tsv` | manuscript table | in repo once copied to `data/` |

## Status

These scripts are rewritten from a collaborator's original LSF/`bsub` scripts (hardcoded to
another filesystem, one isolate at a time) into SLURM array jobs over the four assemblies using
this project's paths and conda envs, with the filter order corrected to the Methods. **They have
not been run end-to-end on this cluster** - the license-gated tools above must be installed
first, and three parsing assumptions must be validated against a real run: the SignalP
prediction-table column, the TargetP/NetGPI prediction labels, and (per Methods) restricting the
DeepTMHMM removal to TM helices >40 aa downstream of the signal cleavage site (the current
`03` list is all TM-bearing proteins). See "Methods steps NOT scripted" for the effectome gap.
