# Stage 05 - Assembly finalization and quality assessment

Two things happen here, in this order:

1. **Finalization.** One contig in the project, `Pcub-SC1982_002`, carries an internal run of `N`
   standing in for hard-masked (removed) sequence. `split-contigs.sh` cuts it into its two resolved
   segments, dropping only the `N` characters. The split assembly **replaces** the
   FCS-GX-cleaned assembly in `contigs-renamed/cleaned/`, so it is the assembly that the QC below and
   every downstream stage (06-11) read.
2. **Quality assessment.** compleasm (stramenopiles/eukaryota) plus QUAST for three genome sets: the
   new assemblies, the published downy mildew genomes, and the wider oomycete references. The first
   two use the quality workflow shipped with targetasm and write their tables into `data/`, which is
   what the notebooks read; `ref-genome-quality.sh` runs the same two tools directly through
   `quality-check.py` on the cluster.

The SC1982 gap/tail coverage check is also here. It is evidence *about* the split - it asks whether
the sequence downstream of the gap is genuine - so it necessarily runs on the **pre-split** contig
(see [Notes](#notes)).

## Scripts

| file | what it does | resources |
|---|---|---|
| `split-contigs.sh` | Split contigs at internal N-runs, dropping only the Ns. Run before the QC below. | login node or local; seconds, no scheduler |
| `qc-final-assemblies.sh` | Run the targetasm quality workflow (compleasm + QUAST) over the three final assemblies of this paper. | local or cluster; needs Nextflow with the docker profile |
| `qc-published-genomes.sh` | Same quality workflow over the published downy mildew genomes, so the new assemblies can be compared on identical metrics. | local or cluster; needs Nextflow with the docker profile |
| `quality-check.py` | Run compleasm (stramenopiles) and QUAST on one FASTA and write the merged metrics as quality.csv. Helper for ref-genome-quality.sh; not run directly. | inside the same job as ref-genome-quality.sh |
| `ref-genome-quality.sh` | Score the wider set of oomycete reference genomes with compleasm and QUAST, giving the clade-level context for the assembly quality figure. | SLURM, 24 cores |
| `check-sc1982-gap-tail-coverage.sh` | Map the SC1982 HiFi reads back to `Pcub-SC1982_002` to check read support across the gap and the contig tail. Runs on the pre-split contig. | local workstation, 16 threads |
| `summarize-sc1982-14-gene-support.R` | Summarize per-gene read support for the 14 genes in the post-gap tail, from the coverage output above. | local workstation |

## Splitting the N-gap contig

Long internal N-runs stand in for sequence that was hard-masked out, not for sequence of unknown
composition. They are not acceptable in a GenBank submission, and they carry no information for
repeat masking, gene prediction or synteny either, so they are removed here - before the QC and
before the downstream stages - rather than as a deposition-time adjustment.

`split-contigs.sh` does it in one line of `seqkit`: the assembly goes to tabular form, `awk` cuts
each sequence on its runs of `N`, and the segments go back out as FASTA. Nothing is hardcoded - any
contig with an internal N-run is split - so the script needs no coordinates and needs no edit if
another assembly ever picks up a gap. It needs `seqkit` on `PATH`.

The split assembly overwrites the cleaned assembly in place. Keep the pre-split FASTA: the gap
coverage check needs it, and it is the only record of the assembly as FCS-GX left it.

```bash
CLEANED="$HOME/project_data/downy/contigs-renamed/cleaned"
ARCHIVE="$HOME/project_data/downy/contigs-renamed/pre-split"
ASM="Pseudoperonospora_cubensis_SC1982.fasta.gz"
PRE="$ARCHIVE/Pseudoperonospora_cubensis_SC1982.pre-split.fasta.gz"

mkdir -p "$ARCHIVE"
cp "$CLEANED/$ASM" "$PRE"

bash workflow/05-assembly-qc/split-contigs.sh "$PRE" "$CLEANED/$ASM"

# verify: one more contig, exactly 8,381 fewer bases, and no N left in any assembly
seqkit stats -a -T "$PRE" "$CLEANED/$ASM"
seqkit fx2tab -n -l -B N "$CLEANED"/*.fasta.gz | awk -F'\t' '$3+0 > 0 {print "N remaining:", $1, $3"%"}'
```

Read from the archived copy and write to `cleaned/`, as above; the script refuses to run if the two
paths are the same, which would truncate the input mid-stream. Output is always gzipped because the
downstream `cleaned/*.fasta.gz` globs expect the compressed form.

The verification is the part worth running every time. `seqkit stats` should show one more contig and
exactly 8,381 fewer bases than the pre-split file, and the `awk` scan should print nothing:
`Pcub-SC1982_002` is the only contig in any of the four assemblies carrying an internal N-run, and
this is what confirms that still holds.

Two details of the naming, neither of which applies to SC1982. Segments shorter than GenBank's 200-bp
floor are dropped (`seqkit seq -m 200`), and segment letters index position within the source contig
- so a gap in the lettering (`a`, `c`) marks a short segment dropped between them.

### Applied to *P. cubensis* SC1982

The only affected contig in this project. `Pcub-SC1982_002` (4,835,754 bp) carried a single
8,381-bp all-N interval at 4,523,547-4,531,927 - the region FCS-GX hard-masked as potential
contamination - and was split into:

| segment | source interval (1-based) | length |
|---|---|---|
| `Pcub-SC1982_002a` | 1 - 4,523,546 | 4,523,546 bp |
| `Pcub-SC1982_002b` | 4,531,928 - 4,835,754 | 303,827 bp |

| | contigs | total bp |
|---|---|---|
| pre-split (FCS-GX cleaned) | 474 | 103,506,981 |
| N removed | | -8,381 |
| **split (the assembly used from here on)** | **475** | **103,498,600** |

No resolved base was altered: the two segments carry exactly the pre-split sequence either side of
the N-run.

### Why the post-gap tail was retained

The 303,827-bp segment downstream of the gap contains 14 genes with fungal BLAST hits, which
raised the question of whether it is contamination that should be trimmed rather than kept.
HiFi read evidence says it is genuine SC1982 sequence, so it was retained:

- the segment has uniform coverage over its full length (mean depth 230x MAPQ0 / 192x MAPQ20,
  covered fraction 1.000), comparable to the 2-Mb region upstream of the gap;
- all 14 genes are fully covered (covered fraction 1.000) with 24-80 full-gene-spanning
  reads each and 12-56 reads containing the gene plus 1-kb flanks on both sides.

Supporting tables are committed under `data/sc1982_gap_tail_coverage/`; the per-segment split
record is `data/sc1982_submission_split/`.

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| Split assembly | `contigs-renamed/cleaned/Pseudoperonospora_cubensis_SC1982.fasta.gz` | The finalized SC1982 assembly (475 contigs), written in place over the FCS-GX-cleaned file. | this stage's QC, stages 06-11, GenBank | NCBI GenBank / WGS (this is the file to submit) |
| Pre-split archive | `contigs-renamed/pre-split/Pseudoperonospora_cubensis_SC1982.pre-split.fasta.gz` | The assembly as FCS-GX left it, 474 contigs with the 8,381-bp N interval intact. | check-sc1982-gap-tail-coverage.sh | not deposited (superseded by the split assembly) |
| Split record | `data/sc1982_submission_split/Pseudoperonospora_cubensis_SC1982.splits.tsv (in repo)` | Per-segment record of the split as it was first run: source contig, action, source interval, lengths. Retained as provenance - the coordinates in it are the input to the seqkit commands above; re-running does not rewrite it. | provenance for the Methods | in the repo (committed) |
| Final-assembly QC | `data/qc_final_assemblies/quality_final_assemblies.tsv (in repo)` | compleasm + QUAST over the three final assemblies. | final-assembly.Rmd (Table 1) | in the repo (committed) |
| Published-genome QC | `data/qc_published_genomes/quality_published_genomes.tsv (in repo)` | Same workflow over the published downy mildew genomes, for the comparison. | ref-genome-quality.Rmd (Supp Table S1) | in the repo (committed) |
| SC1982 gap coverage | `data/sc1982_gap_tail_coverage/ (in repo)` | Read-depth support across the gap on the pre-split contig Pcub-SC1982_002 (target FASTA, primary-alignment BAM, depth table). | summarize-sc1982-14-gene-support.R (results text) | in the repo (committed) |
| Reference-genome QC (wider set) | `~/project_data/downy/oomycota-genome/compleasm/<genome>/quality.csv` | compleasm + QUAST over the wider oomycete reference set. NOTE: this directory is NOT present on the cluster - see stage notes; the committed Supp Table S1 comes from the published-genome QC above. | ref-genome-quality.Rmd | not deposited (intermediate; currently absent) |

## Notes

`qc-final-assemblies.sh` and `qc-published-genomes.sh` need Nextflow with the `docker` profile and a
checkout of targetasm (`TARGET_ASM_DIR`). `quality-check.py` is a helper - call it through
`ref-genome-quality.sh`, not directly.

**The gap coverage check runs on the pre-split contig.** `check-sc1982-gap-tail-coverage.sh` pulls
contig `Pcub-SC1982_002` out of the reference with `seqkit grep`, and that contig no longer exists in
the split assembly - it is now `Pcub-SC1982_002a` and `Pcub-SC1982_002b`, with the gap itself gone.
Point its `REFERENCE` at the pre-split archive above to re-run it; the committed output in
`data/sc1982_gap_tail_coverage/` was produced that way.

**Results that predate the split need regenerating.** Splitting one contig changes the SC1982 contig
count (474 to 475), total length (103,506,981 to 103,498,600 bp) and the contig-length distribution
behind N50/L50/N90, and it renames `Pcub-SC1982_002` in every coordinate-bearing downstream output
(Helixer GFF3, tidk telomere profiles, GENESPACE/OrthoFinder BED). Everything currently committed
under `data/` for stages 05-11, and the SC1982 column of Table 1, was generated from the pre-split
assembly. Re-run `qc-final-assemblies.sh` and the affected downstream stages against the split
assembly before quoting those numbers.
