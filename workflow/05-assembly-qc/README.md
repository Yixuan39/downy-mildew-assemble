# Stage 05 - Assembly finalization and quality assessment

This stage finalizes the assemblies before downstream analysis:

- `ncbi-screen.sh` splits the internal N-run in SC1982 and removes the two whole contigs flagged by
  NCBI as bacterial contamination (`Pcub-SC1982_037` and `Pcub-SC1982_071`).
- `qc-final-assemblies.sh` and `qc-published-genomes.sh` run compleasm and QUAST.

The NCBI reply and the evidence supporting retention of the disputed internal spans are in
[`../../ncbi-response/`](../../ncbi-response/). They document the same contamination review as the
finalization step here.

## Scripts

| file | purpose |
|---|---|
| `ncbi-screen.sh` | Create the finalized SC1982 assembly before QC and stages 06-09. |
| `qc-final-assemblies.sh` | Quality metrics for the three focal assemblies. |
| `qc-published-genomes.sh` | Matching quality metrics for published downy mildew genomes. |

## SC1982 finalization

The pre-split assembly has 474 contigs and 103,506,981 bp. The internal 8,381-bp N-run is removed,
and the two NCBI-flagged bacterial contigs are dropped, giving the finalized assembly used by all
downstream stages: 473 contigs and 102,862,537 bp.

`ncbi-screen.sh` checks that `Pcub-SC1982_002` is still the original contig and writes the gzipped
finalized FASTA to `results/assembly-qc/nuclear/`.

## Outputs

| output | path |
|---|---|
| Finalized SC1982 assembly | `results/assembly-qc/nuclear/Pseudoperonospora_cubensis_SC1982.fasta.gz` |
| Pre-split SC1982 assembly | `results/assembly-qc/nuclear-presplit/Pseudoperonospora_cubensis_SC1982.fasta.gz` |
| Final-assembly QC | `data/qc_final_assemblies/quality_final_assemblies.tsv` |
| Published-genome QC | `data/qc_published_genomes/quality_published_genomes.tsv` |
