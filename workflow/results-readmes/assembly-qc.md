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
