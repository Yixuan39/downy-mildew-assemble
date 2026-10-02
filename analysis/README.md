# Manuscript analyses

The R Markdown reports read `data/` and `$PROJECT_DATA/results/` and write the manuscript tables in `data/` and figures in `figures/`. Render them with the `downy-report` environment (`env/report.yml`).

| Analysis | Source | Rendered report |
|---|---|---|
| Read distribution and taxonomy | [Rmd](read-distribution.Rmd) | [HTML](https://yixuan39.github.io/downy-mildew-assemble/analysis/read-distribution.html) |
| Assembly benchmarking | [Rmd](benchmark.Rmd) | [HTML](https://yixuan39.github.io/downy-mildew-assemble/analysis/benchmark.html) |
| Final assembly quality | [Rmd](final-assembly.Rmd) | [HTML](https://yixuan39.github.io/downy-mildew-assemble/analysis/final-assembly.html) |
| Gene annotation and RNA-seq support | [Rmd](gene-annotation-report.Rmd) | [HTML](https://yixuan39.github.io/downy-mildew-assemble/analysis/gene-annotation-report.html) |
| Reference genome quality | [Rmd](ref-genome-quality.Rmd) | [HTML](https://yixuan39.github.io/downy-mildew-assemble/analysis/ref-genome-quality.html) |
| Synteny and orthology | [Rmd](synteny-analysis.Rmd) | [HTML](https://yixuan39.github.io/downy-mildew-assemble/analysis/synteny-analysis.html) |

`test-read-kreport.R` checks the Kraken2 report parser used by `read-distribution.Rmd`.
