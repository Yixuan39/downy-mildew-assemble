#!/usr/bin/env bash

# ----------------------------------------------------------------------------------------
# Purpose : Map the SC1982 HiFi reads back to contig Pcub-SC1982_002 to check read support across the gap
#           and the contig tail - the coverage evidence behind the SC1982 assembly-gap discussion. Reads
#           live on an external drive; edit REFERENCE/READS before running.
# Inputs  : the SC1982 assembly and filtered reads (currently /Volumes/YY3/downy/...)
# Outputs : data/sc1982_gap_tail_coverage/ (target FASTA, primary-alignment BAM, depth table)
# Runs on : local macOS workstation, 16 threads
# Usage   : bash workflow/12-coverage-checks/check-sc1982-gap-tail-coverage.sh
# ----------------------------------------------------------------------------------------
set -euo pipefail

REFERENCE="/Volumes/YY3/downy/contigs-renamed/cleaned/Pseudoperonospora_cubensis_SC1982.fasta.gz"
READS="/Volumes/YY3/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_SC1982.fastq.gz"
CONTIG="Pcub-SC1982_002"
OUTDIR="data/sc1982_gap_tail_coverage"
THREADS=16

TARGET_FASTA="${OUTDIR}/${CONTIG}.fasta"
BAM="${OUTDIR}/SC1982_hifi_to_${CONTIG}.primary.bam"

mkdir -p "${OUTDIR}"

# Extract one nucleotide contig, then align the original PacBio HiFi reads to it.
seqkit grep -p "${CONTIG}" "${REFERENCE}" > "${TARGET_FASTA}"

minimap2 -t "${THREADS}" -ax map-hifi --secondary=no "${TARGET_FASTA}" "${READS}" |
    samtools view -@ "${THREADS}" -u -F 2308 - |
    samtools sort -@ "${THREADS}" -o "${BAM}" -

samtools index -@ "${THREADS}" "${BAM}"

echo "Created ${BAM}"
echo "Run: Rscript workflow/12-coverage-checks/summarize-sc1982-14-gene-support.R"
