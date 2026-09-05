# `env/` — software environments for the downy mildew assembly workflow

This directory documents every compute environment behind `workflow/00-*` through
`workflow/11-*`, as observed on the cluster (`ssh:ncsu-brc`, conda = miniforge3,
scheduler = SLURM, containers = Singularity/Apptainer) at the time of this audit.
It is **documentation only** — nothing in the repo or on the cluster was modified to
produce it.

## How the mapping below was built

Most stage scripts do **not** contain an explicit `conda activate` / `module load` line —
only one script in the whole tree (`04-mitochondrion/mt-linkage-plot.sh`) does. Where a
script names its environment (`mamba run -n <env>`, an `apptainer exec <image>.sif`, or a
Nextflow `container = '...'` directive), that is authoritative and is reported directly.
Everywhere else, the tool binaries the script calls were matched against the package
contents of every project-relevant conda environment on the cluster, and against the
default login-shell `PATH` (`~/software/*` standalone installs). Assignments made this way
are marked **(inferred)** below — they are the best-supported explanation, not a confirmed
fact, because SLURM inherits whatever environment was active in the submitting shell at
`sbatch` time, which cannot be reconstructed from script text alone.

## Stage → environment map

| Stage | What runs | Environment source |
|---|---|---|
| `00-data-acquisition` | `bam2fastq.sh` (SLURM array), `get-oomycete-taxids.sh` (taxonkit) | **downy** (inferred — only env with `bam2fastq` and `taxonkit`) |
| `01-read-filtering` | `run-hifiadapterfilt.sh`, `kraken2-pluspfp.sh` | standalone installs on `PATH`: `~/software/HiFiAdapterFilt-3.0.0` (adapter filtering); **kraken2** conda env for `kraken2` itself — the `~/software/kraken2_2.1.6` directory named on `PATH` no longer exists on disk (stale reference, see Infrastructure notes) |
| `02-assembly` | `assemble-*.sh` — submits the `targetasm` Nextflow pipeline from the login node | per-process **Singularity/biocontainers** pinned in `~/software/targetasm/nextflow.config` (see table below); Nextflow itself runs on Java supplied by the **downy** env (see Infrastructure notes) |
| `03-benchmarking` | `hifiasm.sh`, `hifiasm-blastn.sh`, `targetasm.sh` (direct hifiasm/blastn/gfatools calls); `fasta-quality-table.sh` (Nextflow) | direct-call scripts: **downy** (inferred — only env with matching `hifiasm 0.25.0` + `gfatools 0.5.5` + `blast`); `fasta-quality-table.sh`: same biocontainers as stage 02 |
| `04-mitochondrion` | `blastn-find-mito.sh` (SLURM); `mt-linkage-plot.sh` + `gbdraw-wide.py` (local workstation) | `blastn-find-mito.sh`: **downy** (inferred, `blast 2.16.0`); `mt-linkage-plot.sh`: local conda env `gbdraw` — **not present on this cluster**, local-only |
| `05-assembly-qc` | `ref-genome-quality.sh` (SLURM + `quality-check.py`); `qc-final-assemblies.sh`/`qc-published-genomes.sh` (Nextflow); `check-sc1982-gap-tail-coverage.sh` (local); `summarize-sc1982-14-gene-support.R` (local) | SLURM script: **downy**/system Python (inferred); Nextflow scripts: same biocontainers as stage 02; two scripts run on the local macOS workstation, not this cluster |
| `06-telomeres` | `tidk-telomere-long-contigs.sh`, `plot-tidk-telomeres.R` | **local macOS workstation** per script header — `tidk` is not installed anywhere discoverable on this cluster (not in any conda env, not on `PATH`), consistent with it being a local-only tool |
| `07-repeatmask-gene-prediction` | `hard-mask-*.sh` (RepeatModeler/RepeatMasker, SLURM); `helixer-*.sh` (GPU, apptainer) | hard-mask scripts: **downy** (inferred — only env with `repeatmodeler`/`repeatmasker`/`rmblast`); helixer scripts: `apptainer run --nv docker://gglyptodon/helixer-docker:helixer_v0.3.6_cuda_12.2.2-cudnn8` (pulled by tag at run time; cached locally as `~/software/helixer-docker_helixer_v0.3.6_cuda_12.2.2-cudnn8.sif`) |
| `08-rnaseq-support` | `run-nfcore-rnaseq-*.sh` — `nextflow run nf-core/rnaseq -r 3.26.0 -profile apptainer` | pipeline release **nf-core/rnaseq 3.26.0**, its own per-process biocontainers (not this repo's conda envs); Nextflow launched under the **downy** env's Java (see Infrastructure notes) |
| `09-functional-annotation` | `protein-diamond-blastp.sh`, `protein-eggnog.sh`, `protein-interproscan.sh`, `protein-proteinfer.sh` | explicit in-script: `mamba run -n diamond`, `mamba run -n eggnog-mapper`, `mamba run -n proteinfer`; `protein-interproscan.sh` runs `apptainer exec $HOME/software/interproscan_5.77-108.0.sif` |
| `10-secretome-effectome` | `01-signalp6.sh` … `09-summarize-secretome.sh` (rewritten from the collaborator LSF scripts to SLURM) | license-gated tools (SignalP6, TargetP2, DeepTMHMM, NetGPI, DeepLoc2) are **not installed on this cluster**; the conda envs those scripts name (`signalp6`/`deeptmhmm`/`netgpi`/`deeploc2`/`hmmer`) must be created on install — see the stage-10 README |
| `11-synteny-orthology` | `orthofinder-contigs.sh` (direct `orthofinder` call, SLURM) | **downy** or the dedicated **orthofinder** env (inferred — both pin OrthoFinder 2.5.5, so the ambiguity doesn't change the reported version) |

### Container/image pins actually driving stages 02/03/05 (from `~/software/targetasm/nextflow.config`)

| Process | Container |
|---|---|
| `metamdbg_assemble` | `quay.io/biocontainers/metamdbg:1.2--h077b44d_0` |
| `minimap2_run` | `quay.io/biocontainers/minimap2:2.28--h577a1d6_4` |
| `samtools_filter` | `quay.io/biocontainers/samtools:1.22.1--h96c455f_0` |
| `rasusa_subset` | `quay.io/biocontainers/rasusa:2.2.2--hc1c3326_0` |
| `hifiasm_run` | `quay.io/biocontainers/hifiasm:0.25.0--h5ca1c30_0` |
| `gfatools_convert` | `quay.io/biocontainers/gfatools:0.5.5--h577a1d6_0` |
| `compleasm_run` | `quay.io/biocontainers/compleasm:0.2.7--pyh7e72e81_1` |
| `quast_run` | `quay.io/biocontainers/quast:5.3.0--py313pl5321h5ca1c30_2` |
| `fcs_gx_clean` | `quay.io/biocontainers/ncbi-fcs-gx:0.5.5--h9948957_0` |

These containers, not the legacy `TEA`/`TEA_quality` conda environments, are the
authoritative version source for the targetasm-driven parts of stages 02/03/05 — see
Infrastructure notes.

## Exported YAML files

For every environment still present on the cluster, both a full (`conda env export
--no-builds`) and a from-history (`conda env export --from-history`) YAML were captured:

`R`, `busco`, `diamond`, `downy`, `eggnog-mapper`, `helixer`, `interproscan`, `kraken2`,
`orthofinder`, `proteinfer` → `env/<name>.full.yml` / `env/<name>.from-history.yml`

`TEA` and `TEA_quality` **could not be exported** — see Infrastructure notes below.
Their last-known package lists are preserved as
`env/TEA.historical-snapshot.txt` / `env/TEA_quality.historical-snapshot.txt`.

## Infrastructure notes

- **`ssh:ncsu-brc` is a shared, multi-project account.** `conda env list` also shows
  environments unrelated to this workflow (`cat`, `epilepsy`, `metaprot`, `mmseqs2`,
  `parchment`, `pridepy`, `proposal`, `translate`) — evidence that other work runs on the
  same login, and that the environment set is not static.
- **`TEA` and `TEA_quality` were live at the start of this session and gone by the time of
  YAML export.** Both were queried and their package lists captured early in the audit;
  by the export step, `conda env list` no longer listed either, and `conda env export -n
  TEA` returned an empty (no-`dependencies:`) stub rather than an error. This is most
  consistent with the environments having been removed by another process on the shared
  account during the session, not by any action taken here (no `conda remove`/`env
  remove` command was issued from this audit). Their names trace to the assembly
  pipeline's former short name — a comment inside a stage-03 benchmarking script explains
  that benchmarking labels still use that old name deliberately, to avoid breaking an
  existing figure-generation script's label matching. Practically, this has **no effect
  on reproducibility of the current pipeline**: `TEA` carried no bioinformatics package at
  all (bare Python 3.12 + font/rendering libraries), and `TEA_quality`'s four packages
  (blast 2.16.0, compleasm 0.2.7, minimap2 2.30, quast 5.3.0) are superseded by the
  biocontainers pinned in `targetasm/nextflow.config` (compleasm 0.2.7, quast 5.3.0,
  minimap2 2.28) — nothing in stages 00–11 depends on `TEA`/`TEA_quality` being present
  today.
- **Several `PATH` entries point at directories that no longer exist.** The default
  login-shell `PATH` lists `~/software/kraken2_2.1.6`, `~/software/ncbi-blast-2.15.0+/bin`
  and `~/software/krakenuniq`, but none of these directories exist under `~/software` any
  more (confirmed via `ls -la ~/software/`). Real, working standalone installs on `PATH`
  are `HiFiAdapterFilt-3.0.0`, `fcs-gx-0.5.4`, and `Bracken` (present, but not called by
  any stage-01 script — `kraken2-pluspfp.sh` invokes only `kraken2`, not `bracken`).
  kraken2 itself resolves via the **kraken2** conda env (2.17) once the stale `PATH`
  entry is accounted for.
- **No conda environment auto-activates by default.** `~/.bashrc` sources the conda/mamba
  shell hooks but contains no `conda activate` line and no `auto_activate_base` setting —
  base itself is not put on `PATH` by default. Any stage script that calls a
  bioinformatics binary with no in-script activation is implicitly relying on whatever
  environment the user had manually activated in the submitting shell at `sbatch` time;
  this cannot be recovered from script text and is the basis for every "(inferred)" call
  above.
- **Nextflow resolved.** `~/.local/bin/nextflow` fails against the login node's default
  Java (`/usr/bin/java` → OpenJDK 11.0.27; only 8 and 11 are installed system-wide, no
  environment-modules system exists to supply a newer one). It runs successfully as
  **Nextflow 25.10.4 (build 11173)** once pointed at the **downy** conda env's bundled
  `openjdk 25.0.1-internal` — consistent with `downy` being the environment meant to be
  active for the login-node Nextflow-launching scripts in stages 02/03/05/08.
- **`interproscan` conda env vs. the Singularity image actually used**: the conda env
  installs InterProScan **5.59_91.0**, but stage 09's script runs the pipeline via
  `apptainer exec $HOME/software/interproscan_5.77-108.0.sif` — a substantially newer
  version. The Singularity image is what stage 09 actually executes; the conda env's
  InterProScan is not on the code path for this workflow.
- **`helixer` conda env vs. the container actually used**: the conda env installs
  `helixer 0.3.5`, but both helixer stage scripts pull
  `docker://gglyptodon/helixer-docker:helixer_v0.3.6_cuda_12.2.2-cudnn8` (cached as
  `helixer-docker_helixer_v0.3.6_cuda_12.2.2-cudnn8.sif`) — again a newer version than the
  conda env, and the one on the actual code path.
- **Stage 06 (`tidk`) and part of stage 04/05 run on the user's local macOS workstation,
  not this cluster** — per each script's own `Runs on` header. Searches on the cluster
  for `tidk`/`gbdraw` found nothing, which is expected: they were never meant to be here.
  Their versions must be confirmed on the local machine, not from this SSH session.
- **Stage 10 (secretome/effectome) runs entirely on a collaborator system under LSF**, per
  every script's own header — out of scope for `ssh:ncsu-brc`, no conda environment for it
  exists on this cluster.
- **The cluster's `R` conda env (r-base 4.4.3) is not actually used by this workflow.**
  Every R script in the repo (`05-assembly-qc/summarize-sc1982-14-gene-support.R`,
  `06-telomeres/plot-tidk-telomeres.R`) declares `Runs on : local, R` — so the R version
  that matters for the manuscript's numbers is whatever is installed on the user's local
  machine, not the cluster's `R` env (also 4.4.3) or the standalone `~/software/R-4.4.1`.

## Version reconciliation

The Methods-section version numbers checked against are quoted directly below. **Source:
`manuscript/methods.md` in this repo** — a Markdown snapshot of the manuscript Methods, not
the live Google Doc, so re-confirm against the current manuscript before publication.
Note that `methods.md` itself cites R twice with different versions (`R v4.5.1` and
`R software v4.6.1`); the discrepancy is flagged in the table and TODO below.

| Tool | Methods states | Found on cluster / in containers | Agreement? |
|---|---|---|---|
| RepeatModeler2 | 2.0.7 | `downy` env: repeatmodeler **2.0.7** | ✅ match |
| OrthoFinder | 2.5.5 | `downy` / `orthofinder` envs: **2.5.5**; but `helixer` env carries OrthoFinder **3.0.1b1** (unused by this workflow's OrthoFinder step, which is the direct `orthofinder-contigs.sh` call — flagged so the mismatch isn't mistaken for the one actually used) | ✅ match (for the version actually invoked) |
| HMMER | 3.4 | `busco`/`eggnog-mapper`/`interproscan` envs: **3.4**; `downy` env carries an older **3.1b2** | ✅ match for eggnog-mapper/InterProScan's internal HMMER use; ⚠️ `downy`'s bundled HMMER is stale but is not what those two stages call |
| SignalP | 6.0 | not verifiable — stage 10 runs on a collaborator system, out of scope for this cluster | ❓ unresolved here |
| TargetP | 2.0 | not verifiable — same as above | ❓ unresolved here |
| DeepTMHMM | 1.0.57 | not verifiable — same as above | ❓ unresolved here |
| DeepLoc | 2.0 | not verifiable — same as above | ❓ unresolved here |
| NetGPI | 1.1 | not verifiable — same as above | ❓ unresolved here |
| EffectorP | 3.0 | not verifiable — same as above | ❓ unresolved here |
| R | 4.6.1 (also cites 4.5.1 elsewhere in Methods) | cluster `R` env / `downy` env: **4.4.3**; standalone `~/software/R-4.4.1` | ⚠️ mismatch + internal inconsistency — `methods.md` gives both 4.5.1 and 4.6.1; and the workflow's R scripts run on the **local** workstation, not this cluster, so the version that matters is whichever R is installed locally |

## Reconciliation TODO (for the user)

1. Confirm the actual local R version used to run `summarize-sc1982-14-gene-support.R`
   and `plot-tidk-telomeres.R` — none of the cluster's R installs (4.4.3) match the
   Methods-stated version, and the scripts never ran on the cluster. Also resolve the
   Methods internal inconsistency: `methods.md` cites both `R v4.5.1` and `R software v4.6.1`.
2. Confirm the local `tidk` and `gbdraw` versions (macOS workstation) — not discoverable
   from the cluster.
3. Confirm SignalP/TargetP/DeepTMHMM/DeepLoc/NetGPI/EffectorP versions directly against
   the collaborator system that runs stage 10 — this cluster has no record of them.
4. Decide whether the now-vanished `TEA`/`TEA_quality` conda environments should be
   recreated, or whether the Methods text should simply cite the targetasm biocontainer
   pins instead (recommended, since those are what the pipeline currently runs).
5. If reproducibility of stages 00/03/04/07/11 needs to be pinned precisely, add an
   explicit `conda activate downy` line to those scripts — today they rely on whatever
   environment happens to be active on the submitting shell, which this audit could infer
   but not confirm.
