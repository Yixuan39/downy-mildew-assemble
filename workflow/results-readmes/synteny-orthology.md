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
