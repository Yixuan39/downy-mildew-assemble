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
