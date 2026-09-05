# Migration notes (November 2025 reorganization)

The repository was reorganized from four loosely-themed script folders (`code/`, `benchmarking/`,
`nextflow/`, `rnaseq/`) plus an untracked `junk/` into a numbered `workflow/` tree. If you have an
older checkout or a bookmark into the old layout, this table says where everything went.

All moves were done with `git mv`, so `git log --follow <new path>` shows the full history of each
file.

## What changed

- **61 files moved** into 13 numbered stage directories under `workflow/`, plus
  `config/` (samplesheets and cluster configs) and `analysis/lib/` (shared R helpers).
- **Headers added** to 38 scripts that had none: `Purpose / Inputs / Outputs / Runs on / Usage`.
- **Documentation written**: root `README.md`, `workflow/README.md`, one README per stage,
  `analysis/README.md`, `config/README.md`, `env/README.md`, `CONTRIBUTING.md`, and
  `MANUSCRIPT_CODE_MAP.md`.
- **Retired work removed**: `junk/` (67 exploration scripts from abandoned assembly attempts) and an
  unused `.venv-gbdraw/` were moved to Trash, along with 12 stray `.DS_Store` files. The emptied
  `code/`, `benchmarking/`, `nextflow/` and `rnaseq/` directories followed.
- **One duplicate deleted**: `code/p_effusa-preprocess/run-kraken2-PlusPFP.sh` was identical in
  intent to `code/kraken2-pluspfp.sh`; the *P. effusa* variant kept under
  `workflow/01-read-filtering/p_effusa/` is the one that differs from the multi-isolate version.
- **Renames**: the assembly pipeline was renamed upstream from `target-asm`/`TEA` to `targetasm`,
  and every reference to `$HOME/software/target-asm` and `~/Projects/target-asm` was updated.
  Database roots that pointed at `project_data/downy/fcs-db` and `project_data/downy/BUSCO_DB` -
  neither of which exists any more - were repointed at `$HOME/db/fcs-gx` and `$HOME/db/compleasm`.

## What deliberately did not change

The benchmark `METHOD` labels `tea`, `tea_no_downsample` and `tea_downsample` still carry the
pipeline's old short name. They are the names of result directories that already exist under
`$HOME/project_data/downy/benchmarking`, and `analysis/benchmark.Rmd` matches on them. Renaming them
would mean renaming those directories and re-running nothing useful, so the old name survives as a
label only. Same for the `hifiasm_blastn` method label.

## The cluster working copy

`~/Projects/downy-mildew-assemble` on NCSU BRC has been fast-forwarded to the reorganized layout
(`7b793a3`) and has no uncommitted tracked changes. Four uncommitted resource tweaks that existed
there (`-c 24` -> `-c 8` in the two Helixer scripts, 24 -> 32 threads in ProteInfer, and two
benchmark arms commented out in the submit driver) and a local deletion of
`analysis/synteny-deepspace.Rmd` were discarded; the committed values are the record.

Two untracked paths that the incoming commits would have overwritten were moved to
`~/dm-preexisting-20260904-214832/` rather than deleted: `figures/` and
`code/blastn-find-mito-others.sh` (identical to `workflow/04-mitochondrion/blastn-find-mito.sh`).

The old script directories still exist there as untracked leftovers, because they hold things the
local repository never had:

| path | size | what it is |
|---|---|---|
| `benchmarking/work/`, `rnaseq/work/`, `work/` | 229 GB + 341 GB + 4.4 GB | Nextflow work caches; only needed to `-resume` a run |
| `code/` | 1.5 GB, 85 scripts | cluster-only scripts from abandoned assembly attempts, plus RepeatModeler run directories |
| `junk/` | 29 MB, 30 scripts | the cluster's copy of the retired exploration scripts |
| `nextflow/` | 36 KB | one leftover log |

Nothing in the paper depends on them. The 570 GB of Nextflow caches are the obvious thing to
reclaim once you are sure no run needs resuming.

## Old path to new path

| old | new |
|---|---|
| `analysis/benchmark-downsample.Rmd` | `analysis/benchmark-downsample.Rmd` |
| `analysis/benchmark.Rmd` | `analysis/benchmark.Rmd` |
| `analysis/final_result.Rmd` | `analysis/final_result.Rmd` |
| `analysis/gene_annotation_report.Rmd` | `analysis/gene_annotation_report.Rmd` |
| `analysis/check-annotation.R` | `analysis/lib/check-annotation.R` |
| `analysis/figure-utils.R` | `analysis/lib/figure-utils.R` |
| `analysis/read_distribution.Rmd` | `analysis/read_distribution.Rmd` |
| `analysis/ref-genome-quality.Rmd` | `analysis/ref-genome-quality.Rmd` |
| `analysis/synteny-analysis-contigs.Rmd` | `analysis/synteny-analysis-contigs.Rmd` |
| `analysis/synteny-deepspace-all.Rmd` | `analysis/synteny-deepspace-all.Rmd` |
| `analysis/synteny-deepspace.Rmd` | `analysis/synteny-deepspace.Rmd` |
| `rnaseq/custom.config` | `config/rnaseq/custom.config` |
| `rnaseq/samplesheet_MSU1.csv` | `config/rnaseq/samplesheet_MSU1.csv` |
| `rnaseq/samplesheet_OR502AA.csv` | `config/rnaseq/samplesheet_OR502AA.csv` |
| `rnaseq/samplesheet_SC1982.csv` | `config/rnaseq/samplesheet_SC1982.csv` |
| `code/bam2fastq.sh` | `workflow/00-data-acquisition/bam2fastq.sh` |
| `data/get_oomycete_ids.sh` | `workflow/00-data-acquisition/get-oomycete-taxids.sh` |
| `code/kraken2-PlusPFP.sh` | `workflow/01-read-filtering/kraken2-pluspfp.sh` |
| `code/p_effusa-preprocess/kraken2-PlusPFP.sh` | `workflow/01-read-filtering/p_effusa/kraken2-pluspfp.sh` |
| `code/p_effusa-preprocess/run-hifiadapterfilt.sh` | `workflow/01-read-filtering/p_effusa/run-hifiadapterfilt.sh` |
| `code/run-hifiadapterfilt.sh` | `workflow/01-read-filtering/run-hifiadapterfilt.sh` |
| `nextflow/Quesada_SQIIe_MSU1.sh` | `workflow/02-assembly/assemble-MSU1.sh` |
| `nextflow/Quesada_SQIIe_Phumuli.sh` | `workflow/02-assembly/assemble-OR502AA.sh` |
| `nextflow/Quesada_SQIIe_SC1982.sh` | `workflow/02-assembly/assemble-SC1982.sh` |
| `nextflow/p_effusa.sh` | `workflow/02-assembly/assemble-p_effusa.sh` |
| `benchmarking/fasta_quality_table.sh` | `workflow/03-benchmarking/fasta-quality-table.sh` |
| `benchmarking/hifiasm_blastn.sh` | `workflow/03-benchmarking/hifiasm-blastn.sh` |
| `benchmarking/hifiasm.sh` | `workflow/03-benchmarking/hifiasm.sh` |
| `benchmarking/submit_slurm.sh` | `workflow/03-benchmarking/submit-all.sh` |
| `benchmarking/target-asm.sh` | `workflow/03-benchmarking/target-asm.sh` |
| `code/blastn-find-mito-others.sh` | `workflow/04-mitochondrion/blastn-find-mito.sh` |
| `code/gbdraw-wide.py` | `workflow/04-mitochondrion/gbdraw-wide.py` |
| `code/mt-label-orf-only.tsv` | `workflow/04-mitochondrion/mt-label-orf-only.tsv` |
| `code/mt-linkage-plot.sh` | `workflow/04-mitochondrion/mt-linkage-plot.sh` |
| `code/qc-final-assemblies.sh` | `workflow/05-assembly-qc/qc-final-assemblies.sh` |
| `code/qc-other-genomes.sh` | `workflow/05-assembly-qc/qc-published-genomes.sh` |
| `junk/scaffold/quality-check.py` | `workflow/05-assembly-qc/quality-check.py` |
| `code/ref-genome-quality.sh` | `workflow/05-assembly-qc/ref-genome-quality.sh` |
| `code/plot-tidk-telomeres.R` | `workflow/06-telomeres/plot-tidk-telomeres.R` |
| `code/tidk-telomere-long-contigs.sh` | `workflow/06-telomeres/tidk-telomere-long-contigs.sh` |
| `code/hard_mask-carlos.sh` | `workflow/07-repeatmask-gene-prediction/hard-mask-combined-library.sh` |
| `code/hard_mask-contigs.sh` | `workflow/07-repeatmask-gene-prediction/hard-mask-contigs.sh` |
| `code/hard_mask-others.sh` | `workflow/07-repeatmask-gene-prediction/hard-mask-published-genomes.sh` |
| `code/helixer-contigs.sh` | `workflow/07-repeatmask-gene-prediction/helixer-contigs.sh` |
| `code/helixer-others.sh` | `workflow/07-repeatmask-gene-prediction/helixer-published-genomes.sh` |
| `rnaseq/run_MSU1.sh` | `workflow/08-rnaseq-support/run-nfcore-rnaseq-MSU1.sh` |
| `rnaseq/run_OR502AA.sh` | `workflow/08-rnaseq-support/run-nfcore-rnaseq-OR502AA.sh` |
| `rnaseq/run_SC1982.sh` | `workflow/08-rnaseq-support/run-nfcore-rnaseq-SC1982.sh` |
| `code/protein-blastp.sh` | `workflow/09-functional-annotation/protein-diamond-blastp.sh` |
| `code/protein-eggnog.sh` | `workflow/09-functional-annotation/protein-eggnog.sh` |
| `code/protein-interproscan.sh` | `workflow/09-functional-annotation/protein-interproscan.sh` |
| `code/protein-proteinfer.sh` | `workflow/09-functional-annotation/protein-proteinfer.sh` |
| `code/Scripts/deeploc.sh` | `workflow/10-secretome-effectome/deeploc.sh` |
| `code/Scripts/deeptmhmm.sh` | `workflow/10-secretome-effectome/deeptmhmm.sh` |
| `code/Scripts/mining_RXLR` | `workflow/10-secretome-effectome/mining-rxlr.sh` |
| `code/Scripts/signalp6.sh` | `workflow/10-secretome-effectome/signalp6.sh` |
| `code/Scripts/MSU1_targetp.sh` | `workflow/10-secretome-effectome/targetp.sh` |
| `code/Scripts/WY_motif.sh` | `workflow/10-secretome-effectome/wy-motif-hmmsearch.sh` |
| `code/orthofinder-contigs.sh` | `workflow/11-synteny-orthology/orthofinder-contigs.sh` |
| `code/check-sc1982-gap-tail-coverage.sh` | `workflow/12-coverage-checks/check-sc1982-gap-tail-coverage.sh` |
| `code/summarize-sc1982-14-gene-support.R` | `workflow/12-coverage-checks/summarize-sc1982-14-gene-support.R` |
