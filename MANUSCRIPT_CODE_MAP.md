# Manuscript to code map

Which script and which notebook produced each figure and table. `-` means that step does not exist:
some figures are drawn directly by a shell script with no notebook, and Table 3 was assembled by
hand from the collaborator's secretome output.

| item | what it shows | workflow script(s) | notebook | committed data | figure file |
|---|---|---|---|---|---|
| Figure 1 | Taxonomic composition of HiFi read sets (Kraken2, phylum level) | `workflow/01-read-filtering/kraken2-pluspfp.sh` | `analysis/read-distribution.Rmd` | `data/figure1_read_totals.tsv; data/oomycete_taxids.txt` | `figures/taxonomy-composition-bar.*` |
| Figure 2 | Overview of the targetasm workflow (schematic) | none - drawn by hand | - | - | `figures/target-asm-pipeline.drawio.*` |
| Figure 3 | Benchmark of assembly strategies for P. effusa and MSU-1 | `workflow/03-benchmarking/{hifiasm.sh,hifiasm-blastn.sh,targetasm.sh,submit-all.sh,fasta-quality-table.sh}` | `analysis/benchmark.Rmd` | `data/benchmark_qc/quality_all_benchmarking.tsv` | `figures/benchmark-method-matrix.*` |
| Figure 4 | Effect of read downsampling on targetasm performance (MSU-1) | `workflow/03-benchmarking/targetasm.sh (METHOD=tea_downsample / tea_no_downsample)` | `analysis/benchmark.Rmd` | `data/benchmark_qc/quality_all_benchmarking.tsv` | `figures/benchmark-target-asm-sensitivity.*` |
| Fig. 5 (mitochondrial) | Mitochondrial genome synteny across 14 oomycetes | `workflow/04-mitochondrion/{blastn-find-mito.sh,mt-linkage-plot.sh,gbdraw-wide.py}` | - | `data/mt_linkage/14_mitochondrial_genomes.gb; workflow/04-mitochondrion/mt-label-orf-only.tsv` | `data/mt_linkage/mt_linkage.{svg,pdf,png}` |
| Figure 5 (annotation) | Functional annotation and RNA-seq support for Helixer genes | `workflow/09-functional-annotation/*.sh; workflow/08-rnaseq-support/*.sh` | `analysis/gene-annotation-report.Rmd` | `data/protein_function_by_isolate/*.tsv` | `figures/gene-annotation-rnaseq-support.*` |
| Figure 6 | Comparative synteny and species relationships across 15 genomes | `workflow/11-synteny-orthology/orthofinder-contigs.sh` | `analysis/synteny-analysis.Rmd` | - | `figures/synteny-contigs-tree-riparian.*` |
| Table 1 | Assembly statistics for the mitochondrial-filtered nuclear assemblies | `workflow/05-assembly-qc/qc-final-assemblies.sh` | `analysis/final-assembly.Rmd` | - (computed on the cluster QC output, not committed) | `figures/final-assembly-top-contigs.* (companion)` |
| Table 2 | Repeat masking, gene prediction and transcript support | `workflow/07-repeatmask-gene-prediction/*.sh; workflow/08-rnaseq-support/*.sh` | `analysis/gene-annotation-report.Rmd` | `data/repeatmasker/` | - |
| Table 3 | Secretome and effectome summary (EffectorP + EffectorO union) | `workflow/10-secretome-effectome/*.sh` | none - assembled by hand | - | - |
| Supp. Fig. S1 | Read-length distributions of Oomycota vs non-Oomycota reads | `workflow/01-read-filtering/kraken2-pluspfp.sh` | `analysis/read-distribution.Rmd` | `data/oomycete_taxids.txt` | `figures/supp-read-length-distribution.*` |
| Supp. Fig. S2 | TTTAGGG telomeric-repeat profiles, 20 longest contigs | `workflow/06-telomeres/{tidk-telomere-long-contigs.sh,plot-tidk-telomeres.R}` | - | `data/tidk_telomeres/` | `figures/tidk_telomeres/tidk_telomere_profiles_top20_contigs.pdf` |
| Supp. Table S1 | Assembly quality for the additional oomycete genomes | `workflow/05-assembly-qc/{qc-published-genomes.sh,ref-genome-quality.sh,quality-check.py}` | `analysis/ref-genome-quality.Rmd` | `data/qc_published_genomes/quality_published_genomes_table.{tsv,md,docx}` | - |
| Supp. Table S2 | Prioritized per-protein functional annotation summaries | `workflow/09-functional-annotation/{protein-eggnog.sh,protein-interproscan.sh,protein-diamond-blastp.sh}` | `analysis/gene-annotation-report.Rmd (via analysis/lib/check-annotation.R)` | `data/protein_function_by_isolate/*.tsv` | - |
| Supp. Table S3 | ProteInfer predictions at the 0.9 threshold | `workflow/09-functional-annotation/protein-proteinfer.sh` | - | - | - |
| Supp. Table S4 | RepeatMasker summary for P. effusa UA202013* | `workflow/07-repeatmask-gene-prediction/hard-mask-*.sh` | - | `data/repeatmasker/Peronospora_effusa_UA202013_star_repeatmasker_summary.tsv` | - |
| Results text - SC1982 gap | Read support across the Pcub-SC1982_002 gap and contig tail | `workflow/05-assembly-qc/{check-sc1982-gap-tail-coverage.sh,summarize-sc1982-14-gene-support.R}` | - | `data/sc1982_gap_tail_coverage/` | - (only the coverage/support evidence tables are committed) |

Also available as [`MANUSCRIPT_CODE_MAP.csv`](MANUSCRIPT_CODE_MAP.csv).

## Note on figure numbering

The manuscript currently uses **Figure 5 twice**: once for the mitochondrial synteny plot
(captioned `**Fig. 5.**`, in the mitochondrial genomes section) and once for the functional
annotation and RNA-seq support panel (captioned `**Figure 5.**`, in the gene support section). Both
are listed above and distinguished by a parenthetical. Worth fixing in the manuscript before
submission.
