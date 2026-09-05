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
