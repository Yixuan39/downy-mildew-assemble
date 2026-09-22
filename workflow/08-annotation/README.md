# Stage 08 - Annotation and transcript support

RNA-seq support, functional annotation, secretome filtering and effectome prediction are parallel
analyses of the Helixer proteomes from stage 07. Their protein-level results are combined into the
annotation-support table after all inputs are available.

## Scripts

| group | scripts | output |
|---|---|---|
| RNA-seq support | `run-nfcore-rnaseq-{MSU1,OR502AA,SC1982}.sh` | Salmon gene counts and TPM estimates |
| Functional annotation | `protein-diamond-blastp.sh`, `protein-eggnog.sh`, `protein-interproscan.sh` | Function source and description |
| Secretome/effectome | `secretome-effectome.sh` | Soluble-secretome and EffectorP3/EffectorO predictions, plus their union |
| Summary | `summarize-functions.R` | Combined protein-level annotation/support table |

Run the three analysis groups independently. The summary step runs after the RNA-seq, functional
annotation and secretome/effectome outputs are complete.

## Outputs

Large tool outputs remain under `$HOME/project_data/downy/results/`. The derived tables in
`data/annotation_support.tsv` contain the functional annotation, maximum RNA-seq TPM,
soluble-secretome flag and effectome flag for each protein.

Secretome and effectome files are grouped under `results/secretome-effectome/<isolate>/`.
