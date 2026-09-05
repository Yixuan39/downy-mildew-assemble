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
