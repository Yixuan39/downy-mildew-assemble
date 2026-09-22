# Stage 00 - Data acquisition

Turns the raw deliverables into the files every later stage assumes: PacBio HiFi BAMs
from the sequencing core become gzipped FASTQ, and the NCBI oomycete taxid list used by the
contamination screens is generated here.

Sequencing data for the three new isolates is staged under `inputs/hifi/focal/bam/`. The public
*P. effusa* reads are already FASTQ under `inputs/hifi/UA202013/`, so they enter the workflow at
stage 01.

## Scripts

| file | what it does | resources |
|---|---|---|
| `bam2fastq.sh` | Convert the PacBio HiFi BAMs delivered by the sequencing core into gzipped FASTQ, one array task per BAM. | SLURM array 0-2 (one task per isolate BAM) |
| `get-oomycete-taxids.sh` | List every NCBI taxid under Oomycota (taxid 4762); used to build the -taxidlist filter for the BLAST contamination screens. | anywhere taxonkit is installed |

## Outputs

| output | path | what it is | consumed by |
|---|---|---|---|
| HiFi FASTQ | `~/project_data/downy/inputs/hifi/focal/fastq/<run>.fastq.gz` | Raw PacBio HiFi reads converted from the core's BAMs, one file per SMRT run. | 01-read-filtering |
| Oomycete taxid list | `stdout (redirect to a file)` | Every NCBI taxid under Oomycota (4762); builds the `-taxidlist` filter for the contaminant BLAST. | 03-benchmarking |
