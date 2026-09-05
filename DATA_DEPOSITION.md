# Data deposition and cleanup plan

Destination for every results directory under `$HOME/project_data/downy`, plus the
cleanup manifest for the cluster tree. This follows **Springer Nature's mandated-data
policy** (which *Nature Plants* applies): novel nucleotide sequence and genome
assemblies must go to an INSDC repository (NCBI), and anything without a dedicated
community repository goes to a general-purpose repository (Zenodo). Data that is already
public, or is a regenerable/working intermediate, is not deposited.

**Nothing on the cluster is renamed or deleted until you sign off on this plan.** The
sizes below are the live `du` figures at the time of writing.

## Destination table

| directory / output | size | destination | rationale |
|---|---|---|---|
| `GSL_Data/` (raw PacBio HiFi) | 160 GB | **NCBI SRA** | Raw reads for the three new isolates; INSDC-mandated. One BioSample per isolate under one BioProject. |
| `RNA-seq/` (raw Illumina RNA-seq) | 130 GB | **NCBI SRA** | Raw transcriptome reads supporting the annotation; INSDC-mandated. |
| `contigs-renamed/cleaned/` (4 assemblies) | 70 MB | **NCBI GenBank / WGS** | Novel genome assemblies (MSU1, SC1982, OR502AA, and the UA202013 reassembly); INSDC-mandated. |
| `contigs-renamed/mitochondiral/` (mito genomes) | 4 MB | **NCBI GenBank** | Novel organelle genomes, one per assembly (dir is misspelled — see cleanup). |
| `contigs-renamed/helixer/` (GFF3 + proteomes) | 88 MB | **Zenodo** | Helixer gene models and predicted proteomes; no INSDC home as unsubmitted annotation. |
| `downy-mildew-genomes/helixer/` | 272 MB | **Zenodo** | Like-for-like Helixer proteomes for the published genomes (used in synteny/orthology). |
| `contigs-renamed/blastp/` | 6 MB | **Zenodo** | DIAMOND-blastp-vs-nr functional-annotation tables. |
| `contigs-renamed/eggnog-mapper/` | 29 MB | **Zenodo** | eggNOG functional annotation. |
| `contigs-renamed/interproscan/` | ~5.5 GB | **Zenodo** | InterPro domains + GO. Consider depositing the summarized per-protein TSV rather than the full raw output to cut size. |
| `contigs-renamed/proteinfer/` | 33 MB | **Zenodo** | ProteInfer function predictions. |
| secretome / effectome tables (stage 10) | small | **Zenodo** | SignalP6/TargetP/DeepLoc/DeepTMHMM/RxLR/WY effector tables behind Table 3. |
| `k2_pfp/*.kreport` | 3 MB | **Zenodo** | Kraken2 PlusPFP classification reports (composition per library). |
| `genespace-contigs/` (orthofinder, results, syntenicHits, pangenes, bed, peptide, genomes) | ~3.3 GB | **Zenodo** | GENESPACE synteny + OrthoFinder orthology outputs behind Figure 6. |
| `genespace-contigs/riparian/` | 6.4 GB | **Zenodo (trim)** | Per-genome riparian PDFs + `rSourceData.rda` + `phasedBlks.csv`. Deposit the final riparian PDFs and phased-block CSVs; the bulk `.rda` source data can be dropped. |
| this repository | small | **Zenodo** | Tagged snapshot (code + committed derived tables), cited alongside the accessions. |
| `p_effusa/` (public UA202013 reads) | 4.1 GB | **not deposited** | Public reads used for the external-validation reassembly; cite the existing SRA accession. |
| `downy-mildew-genomes/*.fna.gz` | 2.1 GB | **not deposited** | Published comparison genomes, already in NCBI; cite their accessions. |
| `downy-mildew-genomes/hardmasked/` | 1.6 GB | **not deposited** | Regenerable RepeatMasker intermediate. |
| `mitochondrial-genome/KT072718.1.fna` | 44 KB | **not deposited** | Public reference mitochondrion; cite accession KT072718.1. |
| `Assembly/` | 42 GB | **not deposited** | targetasm working directories; the final assemblies are deposited from `cleaned/`. |
| `benchmarking/` | 114 GB | **not deposited** | Benchmark assemblies + timings; the summary table `data/benchmark_qc/` is in the repo. |
| `k2_pfp/*.kraken` | 9.6 GB | **not deposited** | Per-read Kraken2 calls; only the `.kreport` summaries are needed. |
| `contigs-renamed/hardmasked/` | 629 MB | **not deposited** | Regenerable RepeatMasker intermediate for the new assemblies. |
| `contigs-renamed/hardmasked-carlos/` + `.tar.gz` | 1.2 GB + 383 MB | **delete** | Abandoned combined-library masking; not used in the manuscript (see cleanup). |

Rough totals: **~290 GB to NCBI SRA**, a few MB to **NCBI GenBank**, **~15 GB to
Zenodo** (less if the interproscan raw output and riparian `.rda` are trimmed), and
**~174 GB not deposited** (working/intermediate/public).

## Draft Data Availability Statement

> The genome assemblies generated in this study have been deposited at
> DDBJ/ENA/GenBank under BioProject **PRJNA_XXXXXX** (accessions
> **JAXXXXXX000000**–**JAXXXXXX000000** for the nuclear assemblies and
> **PQXXXXXX**–**PQXXXXXX** for the mitochondrial genomes). The raw PacBio HiFi and
> Illumina RNA-seq reads are available in the NCBI Sequence Read Archive under the same
> BioProject. The publicly available *Peronospora effusa* UA202013 reads reanalysed here
> are available under SRA accession **SRRXXXXXXX**. Gene annotations, predicted proteomes,
> functional-annotation tables, secretome and effectome predictions, Kraken2 reports, and
> the GENESPACE/OrthoFinder outputs are deposited on Zenodo
> (https://doi.org/10.5281/zenodo.XXXXXXX). Analysis code is available at
> [repository URL] and archived on Zenodo (https://doi.org/10.5281/zenodo.XXXXXXX).

Fill the placeholders once the submissions return accessions.

## Cleanup manifest (cluster)

All paths under `$HOME/project_data/downy`. **Gated on your sign-off — none applied yet.**

### Renames (align the cluster tree to the repo vocabulary)

| current | proposed | note |
|---|---|---|
| `downy-mildew-genomes/` | `published-genomes/` | Matches the repo's `published-genomes` vocabulary. Repoint script input paths in the same change (stages 04, 05, 07 read this dir). |
| `p_effusa/` | `UA202013/` | Matches the isolate label; stages 01–02 already read a mix of `p_effusa` and `UA202013` paths — unify on `UA202013`. |
| `contigs-renamed/mitochondiral/` | `contigs-renamed/mitochondrial/` | Fix the misspelling; stage 04 output path. |
| `Peronospora_effusa_reassemble.*` (in cleaned/, mitochondiral/, helixer/, blastp/, eggnog-mapper/, interproscan/, proteinfer/) | decide at sign-off | Our reassembly of the public UA202013 reads. Renaming to `Peronospora_effusa_UA202013` would collide with the published genome of the same isolate in `downy-mildew-genomes/`; a suffix such as `_UA202013_reassembly` keeps them distinct. **Needs your call.** |

### Deletions

| path | size | reason |
|---|---|---|
| `contigs-renamed/hardmasked-carlos/` | 1.2 GB | Abandoned combined-library masking; not used in the manuscript. |
| `contigs-renamed/hardmasked-carlos.tar.gz` | 383 MB | Redundant tarball of the above. |
| `contigs-renamed/interproscan/*_tmp/` (4 dirs) | empty | Leftover InterProScan temp dirs. |
| `contigs-renamed/eggnog-mapper/*_tmp/` (4 dirs) | empty | Leftover eggNOG temp dirs. |

### Already resolved / not found

- `junk/` (the abandoned-attempt exploration scripts) is **not present** on the cluster — already removed.
- `oomycota-genome/` (the `ref-genome-quality.sh` input/output dir feeding the wider reference-genome QC) is **not present** on the cluster. The committed Supplementary Table S1 comes from the published-genome QC (`data/qc_published_genomes/`) instead — confirm whether `ref-genome-quality.sh`/`ref-genome-quality.Rmd` are still needed or are superseded by `qc-published-genomes.sh`.
