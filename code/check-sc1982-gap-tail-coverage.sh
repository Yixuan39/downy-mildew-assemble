#!/usr/bin/env bash
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
echo "Run: Rscript code/summarize-sc1982-14-gene-support.R"
