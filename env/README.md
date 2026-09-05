# env/

Software environments used by the workflow. Nothing here is a lockfile - the record of what was
actually run is in each script's header and in the version pins below.

## How each stage gets its software

| stage | mechanism |
|---|---|
| 02 assembly, 03 benchmarking, 05 QC | the **targetasm** Nextflow pipeline (`$HOME/software/targetasm`), which defines its own containers; profiles `apptainer` on the cluster, `docker` locally |
| 07 gene prediction | apptainer, pinned container `docker://gglyptodon/helixer-docker:helixer_v0.3.6_cuda_12.2.2-cudnn8` |
| 08 RNA-seq | `nextflow run nf-core/rnaseq -r 3.26.0 -profile apptainer` |
| 09 InterProScan | apptainer, InterProScan 5.77-108.0 |
| 01, 04, 06, 09 (others), 11, 12 | conda environments on the cluster / workstation |
| 10 secretome | the collaborator's own conda environments under `/rs1/researchers/t/tbadhika/cjmantil/envs` |

## Conda environments

Created with miniforge (`~/miniforge3`). The environment used by each script is named in its header
where it matters; `gbdraw` is the only one a script activates explicitly:

    conda create -n gbdraw -c conda-forge -c bioconda gbdraw biopython
    conda activate gbdraw

`workflow/04-mitochondrion/gbdraw-wide.py` patches gbdraw 0.13's hardcoded canvas width; it is not
compatible with arbitrary later versions.

## R

The notebooks in `analysis/` need `tidyverse`, `data.table`, `here`, `gt`, `ggtree`, `GENESPACE`
and their dependencies. The `.Rproj` at the repository root sets the project root that `here()`
resolves against.
