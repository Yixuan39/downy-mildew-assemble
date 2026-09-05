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
# Per-stage README so each results/<stage> folder documents itself without the repo alongside it.
# Generated directly here (like archive/README.md and inputs/README.md below) rather than
# copied from a repo-tracked file, so this documentation lives only in $PROJECT_DATA.
cat > "$results/read-filtering-screening/README.md" <<'EOF'
# results/read-filtering-screening/

Adapter-filtered HiFi reads and Kraken2 taxonomic-screening reports for the three new isolates
(MSU1, OR502AA, SC1982) plus the public *P. effusa* UA202013 dataset. Produced by
`workflow/01-read-filtering-screening/` in the `downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `reads/focal/*.filt.fastq.gz` | HiFiAdapterFilt output for MSU1/OR502AA/SC1982 - the reads that go into assembly. | `results/assembly/` | not deposited (derived from SRA reads) |
| `reads/UA202013/*.filt.fastq.gz` | Same filtering for the public *P. effusa* UA202013 reads. | `results/assembly/` | not deposited (derived from public reads) |
| `taxonomy/<sample>.kreport` | Kraken2 PlusPFP classification summary quantifying host/microbial composition per library. | `read-distribution.Rmd` (Figure 1) | Zenodo (Kraken2 reports) |
| `taxonomy/<sample>.kraken` | Per-read Kraken2 classification calls; large, only the `.kreport` summary is needed downstream. | - | not deposited (intermediate, ~9 GB) |

## Notes

Kraken2 loads the whole PlusPFP index into memory - reruns need a large-memory node (~220 GB).
EOF
cat > "$results/assembly/README.md" <<'EOF'
# results/assembly/

targetasm working directories, one per isolate (MSU1, OR502AA, SC1982, UA202013). Produced by
`workflow/02-assembly/` in the `downy-mildew-assemble` repo, which wraps the external
[targetasm](https://github.com/Yixuan39/targetasm) Nextflow pipeline.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `<isolate>/` | Full targetasm run per isolate (decontaminated primary assembly plus all intermediates). | `results/assembly-preparation/` (final assembly renamed/staged there) | not deposited (large working dirs; final assemblies deposited from `assembly-preparation/`) |

## Notes

`UA202013` is the public *P. effusa* dataset, run through the same pipeline to demonstrate it
generalizes beyond the isolates it was tuned on. The assembly pipeline was previously called `TEA`,
and before that `target-asm` - both older names are gone from the current scripts, but `tea*` still
appears as a benchmark method label under `results/benchmarking/`.
EOF
cat > "$results/benchmarking/README.md" <<'EOF'
# results/benchmarking/

The three-arm assembler comparison behind the benchmarking figure and table: plain hifiasm,
hifiasm plus a BLASTN contaminant-removal pass, and targetasm. Produced by
`workflow/03-benchmarking/` in the `downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `<sample>/<method>/` | One directory per arm x isolate (`hifiasm`, `hifiasm_blastn`, `tea`/`tea_no_downsample`/`tea_downsample`), each with `timing.tsv`. | `fasta-quality-table.sh` (repo) | not deposited (114 GB) |

Per-assembly compleasm + QUAST metrics collected across every benchmark run are committed in the
repo at `data/benchmark_qc/quality_all_benchmarking.tsv`, not duplicated here.

## Notes

`tea`, `tea_no_downsample` and `tea_downsample` are directory-name/method labels left over from
targetasm's former name (`TEA`). They are also the labels `analysis/benchmark.Rmd` matches on -
do not rename them without also renaming these directories and updating the notebook.
EOF
cat > "$results/assembly-preparation/README.md" <<'EOF'
# results/assembly-preparation/

Renamed contigs, nuclear/mitochondrial split, and the reference-genome mitochondrial BLASTN
hits / linkage figure. Produced by `workflow/04-mitochondrion/` and `workflow/05-assembly-qc/`
(renaming/splitting steps only - QC lives under `results/assembly-qc/`) in the
`downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `renamed/*.fasta.gz` | Full renamed assemblies straight out of `contigs-renamed/` (nuclear + mitochondrial contigs together), before the nuclear/mitochondrial split. | `nuclear/`, `mitochondrial/` | not deposited (intermediate) |
| `nuclear/*.fasta.gz` | Nuclear-only assemblies (mitochondrial contigs removed); identical to the copy in `results/assembly-qc/nuclear/`, which is the one downstream stages (06-11) actually read. | `results/assembly-qc/` | NCBI GenBank / WGS (post N-gap split, see `assembly-qc/`) |
| `mitochondrial/` | Split-out mitochondrial contigs/records per assembly. | mitochondrial genome reporting | Zenodo/GenBank as applicable |
| `mt-linkage/mt_linkage.{svg,pdf,png}` | BLASTN-based linkage figure between the assembled mitochondrial contigs and the reference mitochondrial genome (KT072718.1), plus per-record BLASTN hit tables. | manuscript figure | in the repo (also mirrored to `figures/`) |

## Notes

The `Peronospora_effusa_reassemble` file name is remapped to
`Peronospora_effusa_UA202013_star` when copied into this tree (the public-dataset assembly,
renamed for consistency with the other three isolates' naming convention).
EOF
cat > "$results/assembly-qc/README.md" <<'EOF'
# results/assembly-qc/

Final nuclear assemblies (post N-gap split) that every downstream stage (06-11) reads, plus the
compleasm/QUAST quality metrics tables. Produced by `workflow/05-assembly-qc/` in the
`downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `nuclear/*.fasta.gz` | The finalized nuclear assemblies, with the SC1982 internal N-gap contig (`Pcub-SC1982_002`) split into `Pcub-SC1982_002a`/`Pcub-SC1982_002b` (475 contigs, 103,498,600 bp total). This is the assembly used from here on - telomeres, repeat masking/gene prediction, functional annotation, secretome/effectome, synteny/orthology. | `results/telomeres/`, `results/repeatmask-gene-prediction/`, and all later stages | NCBI GenBank / WGS (this is the file to submit) |

Quality metrics (compleasm + QUAST) for these assemblies, the published downy mildew genomes, and
the wider oomycete reference set are committed directly in the repo, not duplicated on the
cluster: `data/qc_final_assemblies/`, `data/qc_published_genomes/`, and the SC1982 gap/tail
coverage evidence under `data/sc1982_gap_tail_coverage/` and `data/sc1982_submission_split/`.

## Notes

Splitting `Pcub-SC1982_002` changes SC1982's contig count, total length, and every
coordinate-bearing downstream output (Helixer GFF3, tidk telomere profiles, GENESPACE/OrthoFinder
BED) relative to anything generated from the pre-split assembly. All results under stages 06-11
in this tree are expected to be (re)generated against this split assembly.
EOF
cat > "$results/telomeres/README.md" <<'EOF'
# results/telomeres/

tidk telomere-repeat search output and the summary plot, over the final nuclear assemblies in
`results/assembly-qc/nuclear/`. Produced by `workflow/06-telomeres/` in the
`downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `<sample>/lengths.tsv` | Per-contig lengths for the sample's assembly, used to pick the top 20 longest contigs to plot. | `plot-tidk-telomeres.R` | in the repo (mirrored to `data/tidk_telomeres/`) |
| `<sample>/<sample>.TTTAGGG_telomeric_repeat_windows.tsv` | tidk `search` output: windowed TTTAGGG telomeric-repeat counts across each contig. | `plot-tidk-telomeres.R` | in the repo (mirrored to `data/tidk_telomeres/`) |
| `figures/tidk_telomere_profiles_top20_contigs.pdf` | Per-sample telomere-repeat density profiles along the 20 longest contigs. | manuscript figure | in the repo (mirrored to `figures/tidk_telomeres/`) |

## Notes

Runs on the cluster's `tidk` conda env (tidk 0.2.65, seqkit 2.13.0). The `tidk search` motif is
supplied explicitly (`TTTAGGG`), so the `tidk build`/clade-database warning on a fresh env is
harmless.
EOF
cat > "$results/repeatmask-gene-prediction/README.md" <<'EOF'
# results/repeatmask-gene-prediction/

RepeatModeler/RepeatMasker hardmasked genomes and Helixer gene models + predicted proteomes, for
both the three new assemblies and the published reference genomes. Produced by
`workflow/07-repeatmask-gene-prediction/` in the `downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `hardmasked/<assembly>/` | Per-assembly RepeatModeler library + RepeatMasker hard-masked FASTA for the three new assemblies. | `helixer/` (this stage) | not deposited (regenerable intermediate) |
| `helixer/<assembly>.gff` + `.faa` | Predicted gene structures (GFF3) and protein sequences (FASTA) for each new assembly, from Helixer (land_plant/fungi model, v0.3.6 CUDA container). | `results/rnaseq-support/`, `results/functional-annotation/`, `results/secretome-effectome/`, `results/synteny-orthology/` | Zenodo (annotations + predicted proteomes) |
| `published-genomes/hardmasked/` + `helixer/` | Like-for-like masking and gene prediction for the published downy mildew genomes, for the annotation comparison. | `results/synteny-orthology/` | Zenodo (predicted proteomes); masking not deposited |

## Notes

Helixer needs a GPU node (`apptainer run --nv`); the container tag is pinned in the launcher
script. RepeatModeler is the slow step - expect days per genome. An alternative
single-combined-library masking strategy (`hardmasked-carlos/` in the pre-reorganization tree) was
tried but is not used in the manuscript and was not carried into this tree.
EOF
cat > "$results/rnaseq-support/README.md" <<'EOF'
# results/rnaseq-support/

nf-core/rnaseq 3.26.0 output per isolate, giving transcript-level evidence for the Helixer gene
models. Produced by `workflow/08-rnaseq-support/` in the `downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `<isolate>/` | Full nf-core/rnaseq output (alignments, quantification, QC) for MSU1, OR502AA, and SC1982. | `gene-annotation-report.Rmd` (Figure 5 RNA-seq support) | not deposited (large intermediate; raw RNA-seq reads go to SRA) |

## Notes

These are Nextflow launchers - run from a login node (Nextflow submits its own SLURM jobs), not
via `sbatch`. Paths to the samplesheet and cluster resource config are repo-relative
(`workflow/08-rnaseq-support/config/`), so launch from the repository root.
EOF
cat > "$results/functional-annotation/README.md" <<'EOF'
# results/functional-annotation/

Three independent functional-annotation sources over the Helixer proteomes: eggNOG-mapper,
InterProScan, and DIAMOND blastp against nr. Produced by `workflow/09-functional-annotation/` in
the `downy-mildew-assemble` repo; combined into the per-gene support summary by
`analysis/gene-annotation-report.Rmd`.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `blastp/<genome>.tsv` | DIAMOND blastp of the Helixer proteins against NCBI nr (homology half of the annotation support table). | `gene-annotation-report.Rmd` (Table 2, Figure 5) | Zenodo (functional-annotation tables) |
| `eggnog-mapper/<genome>/` | eggNOG orthology-based functional annotation. | `gene-annotation-report.Rmd` | Zenodo (functional-annotation tables) |
| `interproscan/<genome>/` | InterPro domains and GO terms (InterProScan 5.77-108.0). | `gene-annotation-report.Rmd` | Zenodo (functional-annotation tables) |

## Notes

All three are SLURM arrays over the four proteomes and expect their databases under `$HOME/db`
(`eggnog`, `interproscan-5.77-108.0`, `nr.dmnd`). A fourth source (ProteInfer) was previously
part of this comparison but is not used in the manuscript and is not part of this results tree.
EOF
cat > "$results/secretome-effectome/README.md" <<'EOF'
# results/secretome-effectome/

Soluble secretome prediction and candidate effector catalogue for the four Helixer proteomes.
Produced by `workflow/10-secretome-effectome/` in the `downy-mildew-assemble` repo, following the
pipeline order in `manuscript/methods.md`: SignalP6 -> TargetP/DeepTMHMM/NetGPI exclusion ->
soluble secretome -> DeepLoc (supplementary) -> WY-motif/RXLR effector mining -> summary.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `01-signalp6/<ASM>.signalp_positive.faa` | SignalP 6 signal-peptide-positive set. | 02, 03, 04 | Zenodo (secretome tables) |
| `{02-targetp,03-deeptmhmm,04-netgpi}/<ASM>.*.ids` | Exclusion lists (mitochondrial-targeted, transmembrane, GPI-anchored) computed on the SignalP-positive set. | `05-soluble-secretome` | Zenodo (secretome tables) |
| `05-soluble-secretome/<ASM>_soluble_secretome.faa` | SignalP+ minus mTP minus TM minus GPI. | 06, 07, 08 | Zenodo (secretome tables) |
| `06-deeploc/<ASM>/results_*.csv` | DeepLoc 2.1 subcellular localization of the soluble secretome (supplementary, not a filter). | manuscript (supplementary) | Zenodo |
| `07-effectors/<ASM>/` | WY-domain (hmmsearch) and RXLR/RXLR-like (`find_*.pl`) effector calls over the soluble secretome. | `09-summarize`, manuscript table | Zenodo (effectome tables) |
| `secretome_summary.tsv` | Per-assembly effector/secretome counts for the manuscript table. | manuscript table | in the repo once copied to `data/` |

## Notes

**This stage is not run end-to-end yet.** The scripts require license-gated academic tools
(SignalP 6.0, TargetP 2.0, DeepTMHMM, NetGPI 1.1, DeepLoc 2.1) installed under
`$HOME/miniforge3/envs` before they can run - see `workflow/10-secretome-effectome/README.md` for
sources - and three parsing assumptions (SignalP prediction-table column, TargetP/NetGPI label
names, and DeepTMHMM's >40 aa post-cleavage TM filter) still need validating against a real run.
The manuscript Methods also describes several effectome analyses (EffectorP/EffectorO, CRN,
EffectR, NLPs, EPI/EPIC, SCRs, CAZymes/dbCAN3) with **no corresponding scripts** in this repo -
see "Methods steps NOT scripted" in the stage README before claiming full reproduction of the
effectome table.
EOF
cat > "$results/synteny-orthology/README.md" <<'EOF'
# results/synteny-orthology/

OrthoFinder orthogroups and GENESPACE synteny outputs over the staged Helixer proteomes. Produced
by `workflow/11-synteny-orthology/` in the `downy-mildew-assemble` repo.

## Contents

| path | what it is | consumed by | deposition |
|---|---|---|---|
| `orthofinder/` | Orthogroups across the staged proteomes and the OrthoFinder species tree. | `synteny-analysis.Rmd` (Figure 6) | Zenodo (orthology outputs) |
| `genespace/` (bed, results, syntenicHits, pangenes, riparian) | GENESPACE synteny: syntenic hits, pangenes, and per-genome riparian plots. | `synteny-analysis.Rmd` (Figure 6) | Zenodo (GENESPACE outputs; large riparian/results intermediates may be trimmed) |

## Notes

The proteomes must already be staged into a `genespace-contigs/tmp/`-equivalent layout before
running OrthoFinder. The launcher requests 32 cores but calls OrthoFinder with `-t 10`.
EOF
cp "$REPO_ROOT/workflow/RESULTS.md" "$PROJECT_DATA/README.md"
printf '# Original results\n\nOriginal files before the SC1982 gap split. Preserved on %s.\nresults/ holds independent copies of stages 0-3 (safe to edit/delete this archive once those copies\nare verified); inputs/ still symlinks here for the untouched raw reads and reference genomes.\nDo not edit archived files or include raw reads/assemblies in the Zenodo package.\n' "$(date -Iseconds)" > "$archive/README.md"
printf '# Inputs\n\nRaw HiFi and RNA-seq reads, published nuclear genomes and mitochondrial references.\nLinks resolve to the preserved original files in archive/previous-results/.\nThese files are excluded from the Zenodo package.\n' > "$PROJECT_DATA/inputs/README.md"
bash "$REPO_ROOT/workflow/05-assembly-qc/split-contigs.sh"
