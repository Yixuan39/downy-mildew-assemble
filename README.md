# Contamination-aware genome assembly of downy mildew pathogens

Code, derived data and figures for the manuscript *Contamination-aware genome assembly enables
high-quality genomes of downy mildew pathogens*.

The project assembles chromosome-scale genomes from host-contaminated PacBio HiFi libraries using
[targetasm](https://github.com/Yixuan39/targetasm), then evaluates assembly quality, annotation and
comparative genome structure. This repository contains the supporting workflow and manuscript
outputs; targetasm itself is maintained separately.

| isolate | species |
|---|---|
| MSU1 | *Pseudoperonospora cubensis* MSU-1 |
| SC1982 | *Pseudoperonospora cubensis* SC1982 |
| OR502AA | *Pseudoperonospora humuli* OR502AA |
| UA202013 | *Peronospora effusa* UA202013 reassembly |

## Contents

| path | contents |
|---|---|
| [`workflow/`](workflow/) | Analysis scripts, grouped by workflow stage |
| [`analysis/`](analysis/) | R Markdown analyses for manuscript figures and tables |
| [`data/`](data/) | Derived tables and supporting evidence |
| [`figures/`](figures/) | Manuscript figures |
| [`env/`](env/) | Environment specifications for the main tools |
| [`ncbi-response/`](ncbi-response/) | Evidence and correspondence for the NCBI contamination review |

Start with [`workflow/README.md`](workflow/README.md) for the stage index. Scripts were run on a
SLURM cluster and list their main inputs, outputs and usage in their headers. Raw reads, large
intermediates and external reference databases are not included here.

## Data availability

Raw reads and final assemblies are deposited under the accessions reported in the manuscript.
This repository contains the analysis code, derived tables, figures and the evidence supporting the
SC1982 contamination review.
