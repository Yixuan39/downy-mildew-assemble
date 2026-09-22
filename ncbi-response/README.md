# ncbi-response/

Evidence and reply for the NCBI foreign-contamination flags on submission SUB16446400. This is the
evidence record referenced by workflow stage 05, which performs the corresponding final assembly
cleanup on the three *Pseudoperonospora* assemblies: MSU1, SC1982 and OR502AA. The response accepts
NCBI's removal of two bacterial contigs and requests manual review and retention of six
internal fungal-affinity spans. Primary HiFi alignments, a CIGAR-aware follow-up audit,
and local depth support their retention; protein similarity alone does not establish
host membership or horizontal transfer.

## Contents

- `ncbi_reply.Rmd`, `ncbi_reply.pdf` - the reply letter. The Rmd reads the coverage, junction, full-span, CIGAR-audit, and internal best-hit
  tables at render time. It verifies best hits against the raw searches and checks
  agreement between the original interval counts and the CIGAR audit.
- `scripts/` - the actual commands run on the cluster to generate the evidence:
  - `map_and_measure.sh` - core script: map an isolate's HiFi reads against its full assembly,
    retain primary alignments on flagged contigs, then compute per-base depth around each flagged
    span and per-read alignment intervals across it.
  - `submit_mapping_MSU1.sh`, `submit_mapping_SC1982.sh`, `submit_mapping_OR502AA.sh` -
    the per-isolate SLURM job bodies that called `map_and_measure.sh` and staged its
    outputs. Kept as a historical record of exactly what ran (absolute cluster paths);
    not meant to be re-run verbatim elsewhere.
  - `blastp_two_arm.sh` - the two-arm diamond blastp search (unrestricted nr vs.
    Oomycota-restricted) of every span gene, which documents fungal and oomycete protein similarities.
    The two arms alone do not distinguish contamination from genomic integration.
  - `audit-cigar-support.py` - read-only verification of the existing indexed BAMs,
    counting distinct reads with actual aligned flanks and excluding large CIGAR gaps.
    Includes a runnable `--self-test` for coordinate and CIGAR edge cases.
- `data/` - inputs and derived evidence tables:
  - `spans.tsv` - the flagged-span coordinates, manually transcribed from NCBI's
    contamination report.
  - `span_genes.tsv`, `span_composition.tsv` - per-span gene lists and GC/repeat
    composition.
  - `query_proteins.faa`, `query_proteins_archived_besthit.tsv` - the span + flank-control
    protein set and their previously archived best-hit annotations.
  - `blastp_arm_unrestricted.tsv.gz`, `blastp_arm_oomycota.tsv` - raw diamond blastp
    output for the two arms above.
  - `ncbi_flag_coverage_evidence.tsv`, `ncbi_flag_junction_evidence.tsv`,
    `ncbi_flag_homology_evidence.tsv`, `ncbi_flag_composition_evidence.tsv`,
    `ncbi_flag_fullspan_evidence.tsv` - historical evidence summaries.
  - `ncbi_flag_cigar_audit.tsv` - independently rechecked coordinate and CIGAR-aware
    counts; the latter are now quoted in the letter.
  - `review_blastp_span_besthits.tsv` - internal best-hit summary used to build the
    letter tables; not a proposed NCBI attachment.
- `figures/ncbi_flag_coverage.png` - archived per-span depth-profile figure; not
  included in the current PDF.

Large BAM and genome-wide depth intermediates remain on the cluster; only the small tables
used by the reply are committed here.
