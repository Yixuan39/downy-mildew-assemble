# Contamination-aware genome assembly of downy mildew pathogens

Code, derived tables and figures for the manuscript *"Contamination-aware genome assembly enables
high-quality genomes of downy mildew pathogens"*.

Downy mildews are obligate biotrophs: they cannot be grown in pure culture, so sequencing libraries
made from infected host tissue contain only a small fraction of pathogen DNA. This project assembles
chromosome-scale genomes for three isolates from such libraries using **targetasm**, a
contamination-aware assembly pipeline, and benchmarks it against conventional approaches.

| isolate | species |
|---|---|
| MSU1 | *Pseudoperonospora cubensis* MSU-1 |
| SC1982 | *Pseudoperonospora cubensis* SC1982 |
| OR502AA | *Pseudoperonospora humuli* OR502AA |
| UA202013 | *Peronospora effusa* UA202013 (public reads; our reassembly is UA202013\*) |

The assembly pipeline itself lives in a separate repository:
**<https://github.com/Yixuan39/targetasm>**. This repository holds everything around it - read
preparation, the benchmark, QC, annotation, comparative analyses, and the notebooks that make the
figures.

## Layout

| path | contents |
|---|---|
| [`workflow/`](workflow/) | every batch script that produced a result, in 13 numbered stages |
| [`analysis/`](analysis/) | R Markdown notebooks that make the manuscript figures and tables |
| [`config/`](config/) | nf-core samplesheets, cluster configs, and the canonical data/database paths |
| [`env/`](env/) | how each stage gets its software (containers, conda, Nextflow profiles) |
| `data/` | small derived tables the notebooks read or write; committed so figures can be regenerated |
| `figures/` | manuscript figures as PDF/PNG/SVG/TIFF |
| `manuscript/` | manuscript text by section (not tracked in git) |
| `sources/` | literature search results collected while writing (not tracked in git) |
| [`MANUSCRIPT_CODE_MAP.md`](MANUSCRIPT_CODE_MAP.md) | which script and notebook produced each figure and table |

Start with [`workflow/README.md`](workflow/README.md) for the stage index. Every script begins with
a `Purpose / Inputs / Outputs / Runs on / Usage` header, and every stage directory has a README
covering what the stage does and its gotchas.

## Reproducing the analysis

The pipeline was run on the NCSU BRC cluster (SLURM). Large intermediate and final output lives
outside the repository, under `$HOME/project_data/downy`; reference databases live under `$HOME/db`
(see [`config/README.md`](config/README.md) for the full list).

    # 1. reads: BAM to FASTQ, adapter removal, read profiling
    sbatch workflow/00-data-acquisition/bam2fastq.sh
    sbatch workflow/01-read-filtering/run-hifiadapterfilt.sh
    sbatch workflow/01-read-filtering/kraken2-pluspfp.sh

    # 2. assembly - Nextflow submits its own jobs, so run from a login node, not sbatch
    bash workflow/02-assembly/assemble-MSU1.sh          # and SC1982, OR502AA, UA202013

    # 3. benchmark: three arms x two isolates, all on one node for a fair timing comparison
    bash workflow/03-benchmarking/submit-all.sh
    bash workflow/03-benchmarking/fasta-quality-table.sh

    # 4. downstream: QC, mitochondria, telomeres, annotation, synteny (stages 04-12, independent)
    bash workflow/05-assembly-qc/qc-final-assemblies.sh
    sbatch workflow/07-repeatmask-gene-prediction/hard-mask-contigs.sh
    sbatch workflow/07-repeatmask-gene-prediction/helixer-contigs.sh
    # ... see each stage README

    # 5. figures and tables
    Rscript -e 'rmarkdown::render("analysis/benchmark.Rmd")'

Three things to know before running anything:

1. **Nextflow launchers are not `sbatch` jobs.** Stages 02, 03 (`fasta-quality-table.sh`), 05 and 08
   call Nextflow, which submits its own SLURM jobs. Run those from a login node inside
   `tmux`/`screen`. Scripts with `#SBATCH` headers are the ones to submit with `sbatch`.
2. **Not everything runs on the cluster.** Stage 06 (telomeres) and stage 12 (coverage checks) run
   on a local macOS workstation and read from local paths, one of them an external drive. Stage 10
   (secretome/effectome) came from a collaborator and runs on their LSF system with their paths.
   Each script's `Runs on` header says which.
3. **The notebooks need the result tree.** Notebooks read large output from `~/project_data/downy`,
   so knit them on the cluster or on a machine where that tree is mirrored at the same path. Small
   tables under `data/` are committed, so most figures can be regenerated without it.

## Data availability

Raw HiFi reads, RNA-seq reads and the final assemblies are deposited under the accessions listed in
the manuscript. The *P. effusa* UA202013 reads are public and were reassembled here as an
independent test of the method.
