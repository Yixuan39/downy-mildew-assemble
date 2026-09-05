# Conventions

Notes for anyone adding to this repository - including future me.

## Where things go

- A batch script that produces a result goes in the numbered stage it belongs to under `workflow/`.
  If it does not fit an existing stage, add a new numbered directory with its own `README.md`.
- A script that only supports another script (a plotting call, a per-genome helper) goes next to the
  script that calls it, not in a shared `bin/`.
- Helpers shared by several notebooks go in `analysis/lib/`.
- Exploratory work that is not part of the paper does not go in `workflow/`. Keep it outside the
  repository or in a clearly named scratch directory that is gitignored.

## Naming

- Lowercase with hyphens: `hard-mask-contigs.sh`, not `hard_mask_contigs.sh` or `hardMask.sh`.
- Name the action, then the target: `helixer-contigs.sh`, `helixer-other-genomes.sh`.
- Directories are `NN-topic`, two digits, hyphenated.

## Script header

Every script starts with a header block, after the shebang and any scheduler directives:

    #!/bin/bash
    #SBATCH --job-name=kraken2
    #SBATCH --cpus-per-task=24

    # ----------------------------------------------------------------------------------------
    # Purpose : one or two sentences - what this produces and why it exists
    # Inputs  : concrete paths, including databases
    # Outputs : concrete paths
    # Runs on : NCSU BRC (SLURM) / local macOS / collaborator LSF - and the resources needed
    # Usage   : the exact command, from the repository root
    # ----------------------------------------------------------------------------------------

    set -euo pipefail

Say where it runs. Roughly a quarter of the scripts here do not run on the cluster, and that was
the single most confusing thing about the repository before the headers existed.

## Paths

Scripts hardcode their paths rather than sourcing a shared config, so that any one of them can be
read and run on its own. The cost is that a moved directory has to be fixed in several places, so:

- Cluster data goes under `$HOME/project_data/downy`, databases under `$HOME/db`. Both are listed in
  `config/README.md` - update that table when anything moves.
- Reference a sibling script relative to the calling script (`"$(dirname "$0")/helper.sh"`), never
  by the old repository-relative path.
- In notebooks, reference repository files through `here()` and never with an absolute path.

## Notebooks

- Source the shared theme: `source(here("analysis", "lib", "figure-utils.R"))`.
- Write figures to `figures/` and derived tables to `data/`, both via `here()`.
- Commit the knitted `.html` next to the `.Rmd` so a reader can see the output without R.

## Result labels

Some identifiers are baked into result directories that already exist - notably the benchmark
`METHOD` values `tea`, `tea_no_downsample` and `tea_downsample`, which predate the pipeline's rename
to `targetasm`. Renaming an identifier like that means renaming result directories and updating the
notebook that reads them. Leave it and document it instead, which is what
`workflow/03-benchmarking/README.md` does.
