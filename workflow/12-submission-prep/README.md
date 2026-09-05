# Stage 12 - GenBank submission preparation

GenBank does not accept contigs carrying long internal runs of `N` that stand in for
hard-masked (removed) sequence. This stage produces the submission-ready assembly by
splitting such contigs into their resolved segments, **removing only the `N` characters and
leaving every resolved base untouched**.

This is a submission-specific adjustment. Per the manuscript Methods, the assembly
statistics and all downstream annotation and comparative analyses were generated using the
**pre-submission** assembly (the one that still contains the hard-masked interval), so this
stage does **not** feed stages 04-11 - it is a terminal, deposition-only step.

## Scripts

| file | what it does |
|---|---|
| `split-n-gaps.py` | Split contigs at internal N-runs, dropping only the Ns; writes the submission FASTA and a per-segment TSV report. |

Runs in seconds on a login node; no scheduler needed.

```bash
python3 workflow/12-submission-prep/split-n-gaps.py \
  --in  contigs-renamed/cleaned/Pseudoperonospora_cubensis_SC1982.fasta.gz \
  --out submission/Pseudoperonospora_cubensis_SC1982.submission.fasta \
  --report submission/Pseudoperonospora_cubensis_SC1982.splits.tsv
```

Options: `--min-n` (minimum N-run length to split at, default 10) and `--min-segment`
(drop resolved segments below GenBank's 200-bp floor, default 200). The script verifies base
accounting (`bp_in - N_removed == bp_out`) and exits non-zero if it does not balance.

Segment naming: a contig split into *n* segments becomes `<contig>a`, `<contig>b`, ...;
contigs with no qualifying N-run keep their original name and sequence.

## Applied to *P. cubensis* SC1982

The only affected contig in this project. `Pcub-SC1982_002` (4,835,754 bp) carried a single
8,381-bp all-N interval at 4,523,547-4,531,927 - the region FCS-GX hard-masked as potential
contamination - and was split into:

| segment | source interval (1-based) | length |
|---|---|---|
| `Pcub-SC1982_002a` | 1 - 4,523,546 | 4,523,546 bp |
| `Pcub-SC1982_002b` | 4,531,928 - 4,835,754 | 303,827 bp |

Result, matching the Methods-reported submission assembly exactly:

| | contigs | total bp |
|---|---|---|
| pre-submission (cleaned) | 474 | 103,506,981 |
| N removed | | -8,381 |
| **submission-ready** | **475** | **103,498,600** |

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

| output | path | deposition |
|---|---|---|
| Submission FASTA | `submission/Pseudoperonospora_cubensis_SC1982.submission.fasta` | GenBank (this is the file to submit) |
| Split record | `submission/Pseudoperonospora_cubensis_SC1982.splits.tsv` (copy in `data/sc1982_submission_split/`) | in repo |

Paths are relative to the project data root on the compute system.
