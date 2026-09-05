#!/usr/bin/env bash
# One-time migration of the original ~/project_data/downy tree. Preserves originals by moving them
# into archive/previous-results, then builds a self-contained results/<stage> tree (real copies, not
# links) plus an inputs/ tree (symlinks back to archive/, since raw reads/references are never modified).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/paths.sh"
archive="$PROJECT_DATA/archive/previous-results"
[[ ! -e "$archive" && ! -e "$PROJECT_DATA/results" && ! -e "$PROJECT_DATA/inputs" ]] || {
    echo "An organized result tree already exists; refusing to archive it again." >&2; exit 1;
}
for required in GSL_Data RNA-seq contigs-renamed downy-mildew-genomes genespace-contigs; do
    [[ -d "$PROJECT_DATA/$required" ]] || { echo "Missing legacy input: $required" >&2; exit 1; }
done
mkdir -p "$archive"
# Move the original tree without rewriting its contents. No deletion, recompression or hard links.
for name in GSL_Data RNA-seq RNA-seq_result contigs-renamed downy-mildew-genomes genespace-contigs Assembly benchmarking k2_pfp mitochondrial-genome p_effusa UA202013; do
    [[ ! -e "$PROJECT_DATA/$name" ]] || mv "$PROJECT_DATA/$name" "$archive/$name"
done
mkdir -p "$PROJECT_DATA/inputs/hifi/focal" "$PROJECT_DATA/inputs/hifi/UA202013" "$PROJECT_DATA/inputs/reference-genomes"
ln -s "$archive/GSL_Data/5Feb24" "$PROJECT_DATA/inputs/hifi/focal/bam"
ln -s "$archive/GSL_Data/fastq" "$PROJECT_DATA/inputs/hifi/focal/fastq"
ln -s "$archive/RNA-seq" "$PROJECT_DATA/inputs/rnaseq"
ln -s "$archive/mitochondrial-genome" "$PROJECT_DATA/inputs/reference-mitochondria"
for fasta in "$archive/downy-mildew-genomes"/*.fna.gz; do
    ln -s "$fasta" "$PROJECT_DATA/inputs/reference-genomes/$(basename "$fasta")"
done
public="$archive/p_effusa"
[[ ! -d "$archive/UA202013" ]] || public="$archive/UA202013"
for fasta in "$public"/*.fastq.gz; do
    [[ ! -e "$fasta" ]] || ln -s "$fasta" "$PROJECT_DATA/inputs/hifi/UA202013/UA202013.fastq.gz"
done
results="$PROJECT_DATA/results"
mkdir -p "$results/read-filtering-screening/reads" "$results/assembly" "$results/benchmarking"
# results/ is a self-contained tree: real copies, not links back into archive/. archive/ stays as the
# separately-preserved original in case anything here needs to be re-derived.
cp -a "$archive/GSL_Data/fastq/filtered" "$results/read-filtering-screening/reads/focal"
cp -a "$public/filtered" "$results/read-filtering-screening/reads/UA202013"
cp -a "$archive/k2_pfp" "$results/read-filtering-screening/taxonomy"
for dir in "$archive/Assembly"/*; do
    name=$(basename "$dir"); [[ "$name" != p_effusa ]] || name=UA202013
    cp -a "$dir" "$results/assembly/$name"
done
for dir in "$archive/benchmarking"/*; do cp -a "$dir" "$results/benchmarking/$(basename "$dir")"; done
mkdir -p "$results/assembly-preparation/renamed" "$results/assembly-preparation/nuclear" "$results/assembly-preparation/mitochondrial" "$results/assembly-qc/nuclear"
for fasta in "$archive/contigs-renamed/cleaned"/*.fasta.gz; do
    name=$(basename "$fasta"); name=${name/Peronospora_effusa_reassemble/Peronospora_effusa_UA202013_star}
    cp "$fasta" "$results/assembly-preparation/nuclear/$name"
    cp "$fasta" "$results/assembly-qc/nuclear/$name"
done
for fasta in "$archive/contigs-renamed"/*.fasta.gz; do
    name=$(basename "$fasta"); name=${name/Peronospora_effusa_reassemble/Peronospora_effusa_UA202013_star}
    cp "$fasta" "$results/assembly-preparation/renamed/$name"
done
for file in "$archive/contigs-renamed/mitochondiral"/*; do
    name=$(basename "$file"); name=${name/Peronospora_effusa_reassemble/Peronospora_effusa_UA202013_star}
    cp -a "$file" "$results/assembly-preparation/mitochondrial/$name"
done
for stage in assembly-qc telomeres repeatmask-gene-prediction rnaseq-support functional-annotation secretome-effectome synteny-orthology; do
    mkdir -p "$results/$stage"
done
cp "$REPO_ROOT/workflow/RESULTS.md" "$PROJECT_DATA/README.md"
printf '# Original results\n\nOriginal files before the SC1982 gap split. Preserved on %s.\nresults/ holds independent copies of stages 0-3 (safe to edit/delete this archive once those copies\nare verified); inputs/ still symlinks here for the untouched raw reads and reference genomes.\nDo not edit archived files or include raw reads/assemblies in the Zenodo package.\n' "$(date -Iseconds)" > "$archive/README.md"
printf '# Inputs\n\nRaw HiFi and RNA-seq reads, published nuclear genomes and mitochondrial references.\nLinks resolve to the preserved original files in archive/previous-results/.\nThese files are excluded from the Zenodo package.\n' > "$PROJECT_DATA/inputs/README.md"
bash "$REPO_ROOT/workflow/05-assembly-qc/split-contigs.sh"
