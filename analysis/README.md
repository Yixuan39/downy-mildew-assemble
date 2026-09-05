# analysis/

R Markdown notebooks that turn the pipeline output into the figures and tables of the manuscript.
Each notebook is self-contained: knit it and it writes its figures into `figures/` and its tables
into `data/`.

| notebook | produces |
|---|---|
| `read_distribution.Rmd` | Figure 1 (taxonomic composition), Supplementary Figure S1 (read-length distributions) |
| `benchmark.Rmd` | Figure 3 (benchmark matrix), Figure 4 (downsampling sensitivity) |
| `benchmark-downsample.Rmd` | exploratory precursor to Figure 4; kept for the record |
| `final_result.Rmd` | Table 1 (assembly statistics), `final-assembly-top-contigs` |
| `gene_annotation_report.Rmd` | Table 2, Figure 5 (functional annotation and RNA-seq support) |
| `ref-genome-quality.Rmd` | Supplementary Table S1 (quality metrics for the comparison genomes) |
| `synteny-analysis.Rmd` | Figure 6 (GENESPACE riparian plot + OrthoFinder species tree) |
| `synteny-deepspace.Rmd`, `synteny-deepspace-all.Rmd` | alternative DeepSpace synteny views; not used in the manuscript |

`lib/` holds the shared helpers: `figure-utils.R` (the figure theme, palette and save helper every
notebook sources) and `check-annotation.R`.

## Where the notebooks read from

Notebooks locate repository files with `here()`, so they work from any working directory inside the
project. Large pipeline output is **not** in the repository - the notebooks read it from
`~/project_data/downy/...`, which means they must be knitted either on the cluster or on a machine
where that tree is mirrored at the same path. Small derived tables that the notebooks depend on are
committed under `data/`, so figures can be regenerated without the full result tree in most cases.

Two known rough edges: `benchmark-downsample.Rmd` contains an absolute `/home5/yyang55/...` path,
and it is the only notebook that does not source `lib/figure-utils.R`.
