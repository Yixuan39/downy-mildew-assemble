# Contamination-aware genome assembly of downy mildew pathogens

Code, derived data and figures for the manuscript *Contamination-aware genome assembly enables high-quality genomes of downy mildew pathogens*. The assemblies were generated with [targetasm](https://github.com/Yixuan39/targetasm).

| Isolate | Species |
|---|---|
| MSU1 | *Pseudoperonospora cubensis* |
| SC1982 | *Pseudoperonospora cubensis* |
| OR502AA | *Pseudoperonospora humuli* |
| UA202013 | *Peronospora effusa* |

- [workflow/](workflow/README.md): scripts from read processing through assembly, annotation and comparison
- [analysis/](analysis/README.md): manuscript analyses
- [data/](data/): derived tables and evidence
- [figures/](figures/): manuscript figures
- [env/](env/): tool environments
- [ncbi-response/](ncbi-response/README.md): SC1982 contamination review

Cluster inputs and full results use `$PROJECT_DATA` (default `$HOME/project_data/downy`); manuscript tables and figures are under `data/` and `figures/`. Sequence accessions are listed in the manuscript.
