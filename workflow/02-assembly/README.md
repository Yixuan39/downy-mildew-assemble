# Stage 02 - Assembly with targetasm

One launcher per isolate. Each is a thin wrapper that calls the **targetasm** Nextflow pipeline,
which lives outside this repository at <https://github.com/Yixuan39/targetasm> (installed on the
cluster at `$HOME/software/targetasm`). The launchers only supply the reads, the databases and the
isolate-specific parameters; the assembly logic, versions and containers are all defined in that
repository.

`assemble-UA202013.sh` runs the public *P. effusa* dataset, which is what shows the method is not
tuned to our own libraries.

## Scripts

| file | what it does | resources |
|---|---|---|
| `assemble-MSU1.sh` | Run the targetasm pipeline on P. cubensis MSU1: HiFi reads in, decontaminated primary assembly out. | login node - the pipeline submits its own SLURM jobs, so do not sbatch this script |
| `assemble-OR502AA.sh` | Run the targetasm pipeline on P. humuli OR502AA. | login node - the pipeline submits its own SLURM jobs |
| `assemble-SC1982.sh` | Run the targetasm pipeline on P. cubensis SC1982. | login node - the pipeline submits its own SLURM jobs |
| `assemble-UA202013.sh` | Run the targetasm pipeline on the public P. effusa reads, the external dataset used to show the method generalises. | login node - the pipeline submits its own SLURM jobs |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| targetasm working dir | `~/project_data/downy/Assembly/<isolate>/` | Full targetasm run per isolate (decontaminated primary assembly plus all intermediates). The final assembly is copied to contigs-renamed/ in stage 04. | 04-mitochondrion, 05-assembly-qc | not deposited (42 GB working dirs; final assemblies deposited from contigs-renamed/cleaned/) |

## Notes

These scripts are **not** submitted with `sbatch`. Nextflow submits its own SLURM jobs, so run
them from a login node (inside `tmux`/`screen`) and let the pipeline schedule the work.

The pipeline was previously called `TEA`, and before that `target-asm`. Both older names are gone
from the scripts, but `tea*` still appears as a benchmark method label - see stage 03.
