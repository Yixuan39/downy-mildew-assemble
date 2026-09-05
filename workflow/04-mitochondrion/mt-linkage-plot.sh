#!/usr/bin/env bash

# ----------------------------------------------------------------------------------------
# Purpose : Draw the linear synteny/linkage plot of the 14 oomycete mitochondrial genomes with gbdraw. Row
#           order mirrors the nuclear synteny figure (analysis/synteny-analysis-contigs.Rmd), whose rows
#           come from the GENESPACE SpeciesTree_rooted.txt tip order.
# Inputs  : a multi-record GenBank file of the 14 mitochondrial genomes (data/14 documents from Mt genome
#           comparison-1.gb); mt-label-orf-only.tsv for the ORF-only labels
# Outputs : data/mt_linkage/mt_linkage.{svg,pdf,png} plus per-record split/ and blast/ intermediates
# Runs on : local workstation; needs `conda activate gbdraw` and the gbdraw-wide.py width patch alongside it
# Usage   : bash workflow/04-mitochondrion/mt-linkage-plot.sh 'data/14 documents from Mt genome
#           comparison-1.gb'
# ----------------------------------------------------------------------------------------
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
GB="${1:?usage: mt-linkage-plot.sh <multi-record.gb> [outdir]}"
OUT="${2:-$HERE/../data/mt_linkage}"
mkdir -p "$OUT/split" "$OUT/blast"

source ~/miniforge3/etc/profile.d/conda.sh
conda activate gbdraw

# 1. split into per-record .gb/.fna, renamed + reordered (order = chain order in the plot)
python - "$GB" "$OUT/split" <<'PY'
import sys
from Bio import SeqIO

gb, outdir = sys.argv[1], sys.argv[2]

# LOCUS name -> (row, label). Row order follows the nuclear synteny figure's tip
# order; the four taxa with no nuclear counterpart (P. viticola, Peronosclerospora,
# and the two extra NCBI Pseudoperonospora references) sit beside their congeners.
PLAN = {
    "NC_027966":                             (1,  "Pythium_insidiosum_NC_027966"),
    "NC_063805":                             (2,  "Plasmopara_halstedii_NC_063805"),
    "NC_045922":                             (3,  "Plasmopara_viticola_NC_045922"),
    "NC_040179":                             (4,  "Bremia_lactucae_NC_040179"),
    "NC_070108":                             (5,  "Peronosclerospora_sorghi_NC_070108"),
    "Phum_-_annotated_by_Tim_2-16-26":       (6,  "Pseudoperonospora_humuli_OR502AA"),
    "NC_042478":                             (7,  "Pseudoperonospora_humuli_NC_042478"),
    "Pcub_clade1_-_annotated_by_Tim_2-16-26":(8,  "Pseudoperonospora_cubensis_SC1982"),
    "Pcub_clade2_annotated_by_Tim_2-16-26":  (9,  "Pseudoperonospora_cubensis_MSU1"),
    "NC_027859":                             (10, "Pseudoperonospora_cubensis_NC_027859"),
    "NC_063790":                             (11, "Peronospora_belbahrii_NC_063790"),
    "KT893455":                              (12, "Peronospora_tabacina_KT893455"),
    "NC_009384":                             (13, "Phytophthora_ramorum_NC_009384"),
    "AY898627":                              (14, "Phytophthora_infestans_AY898627"),
}

recs = list(SeqIO.parse(gb, "genbank"))
missing = [r.name for r in recs if r.name not in PLAN]
if missing:
    sys.exit(f"LOCUS names not in PLAN, update the table: {missing}")

for rec in sorted(recs, key=lambda r: PLAN[r.name][0]):
    row, label = PLAN[rec.name]
    rec.id = label              # gbdraw prints this beside the track
    rec.name = f"seq{row:02d}"  # LOCUS: GenBank caps this at 16 chars
    rec.description = label
    # gbdraw labels from /product; for CDS and rRNA prefer the short /gene symbol
    # ("nad9", not "NADH dehydrogenase subunit 9") or the figure blows up vertically.
    for ft in rec.features:
        if ft.type in ("CDS", "rRNA") and ft.qualifiers.get("gene"):
            ft.qualifiers["product"] = ft.qualifiers["gene"]
        elif ft.type == "rRNA":  # records with no /gene: "large subunit ribosomal RNA" -> rnl
            prod = ft.qualifiers.get("product", [""])[0].lower()
            if "large" in prod or "23s" in prod:  ft.qualifiers["product"] = ["rnl"]
            elif "small" in prod or "16s" in prod: ft.qualifiers["product"] = ["rns"]
    base = f"{outdir}/{row:02d}"
    SeqIO.write(rec, base + ".gb", "genbank")
    SeqIO.write(rec, base + ".fna", "fasta")
    print(f"{row:2d}  {len(rec):>6} bp  {label}")
PY

cd "$OUT"
GBS=(split/*.gb); FNAS=(split/*.fna)

# 2. blastn each adjacent pair. dc-megablast, not the megablast default: these
#    genomes are cross-genus and megablast misses most of the homology.
BLASTS=()
for ((i=0; i<${#FNAS[@]}-1; i++)); do
  q="${FNAS[i]}"; s="${FNAS[i+1]}"
  b="blast/$(basename "${q%.fna}")_$(basename "${s%.fna}").tsv"
  blastn -task dc-megablast -query "$q" -subject "$s" -outfmt 6 \
         -evalue 1e-5 -max_target_seqs 5000 > "$b"
  BLASTS+=("$b")
done
wc -l blast/*.tsv | tail -1

# 3. draw
# Only accessory ORFs are labelled. Labelling every gene symbol needs 308 mm of
# height at this font size, which no Nature page fits.
#
# Sized for Nature Plants: at the 180 mm double-column width this renders label
# text at 5.2 pt (their range is 5-7 pt) in a 174 mm tall figure. Font size is in
# canvas units, so it only means anything relative to GBDRAW_WIDTH: printed pt =
# font/svg_width*180/25.4*72. Raising the width or lowering the font drops below
# their 5 pt floor -- 2800/41 is the limit, and this is already near it.
# gbdraw 0.13 hardcodes that canvas width at 2000 px; gbdraw-wide.py makes it settable.
GBDRAW_WIDTH="${GBDRAW_WIDTH:-2700}" GBDRAW_LABEL_STROKE=2.2 python "$HERE/gbdraw-wide.py" \
  --gbk "${GBS[@]}" -b "${BLASTS[@]}" \
  --align_center --separate_strands \
  --show_labels all --resolve_overlaps \
  --label_whitelist "$HERE/mt-label-orf-only.tsv" \
  --identity 60 --alignment_length 300 \
  --comparison_height 10 --feature_height 20 \
  --block_stroke_width 0 --line_stroke_width 2 \
  --label_font_size 41 --definition_font_size 41 \
  --scale_font_size 35 --legend_font_size 37 \
  -o "mt_linkage"

# 4. patch the SVG: retypeset in Arial and bold the three genomes assembled here.
#    gbdraw's --definition_line_style sets a whole line for every record, so there
#    is no per-record bold switch. Their names are shorter than the longest label,
#    so bolding cannot overflow left.
#    The font-family rewrite is what makes bold render at all: gbdraw emits a
#    QUOTED list led by 'Liberation Sans', and cairosvg will not fall through that
#    to Arial's bold face when Liberation Sans is not installed -- the weight is
#    silently ignored. Arial is metrically identical, so no glyph shifts, and it is
#    what Nature asks for anyway.
python - <<'PY2'
import re

STUDY = (
    "Pseudoperonospora_humuli_OR502AA",
    "Pseudoperonospora_cubensis_SC1982",
    "Pseudoperonospora_cubensis_MSU1",
)

svg = open("mt_linkage.svg").read()

svg, n = re.subn(r'font-family="[^"]*"', 'font-family="Arial, Helvetica, Liberation Sans, sans-serif"', svg)
assert n, "no font-family attributes found"

for name in STUDY:
    svg, n = re.subn(
        r'(<text[^>]*)font-weight="normal"([^>]*>%s</text>)' % re.escape(name),
        r'\1font-weight="bold"\2',
        svg,
    )
    assert n == 1, f"expected 1 label for {name}, patched {n}"
open("mt_linkage.svg", "w").write(svg)
PY2

# gbdraw's own PNG is transparent; render both outputs from the patched SVG
python -c "import cairosvg; cairosvg.svg2png(url='mt_linkage.svg', write_to='mt_linkage.png', background_color='white', scale=1.2); cairosvg.svg2pdf(url='mt_linkage.svg', write_to='mt_linkage.pdf')"

echo "-> $OUT/mt_linkage.svg (+ .png)"
