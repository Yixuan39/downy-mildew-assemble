# Stage 00 - Data acquisition

Turns the raw deliverables into the files every later stage assumes: PacBio HiFi BAMs
from the sequencing core become gzipped FASTQ, and the NCBI oomycete taxid list used by the
contamination screens is generated here.

Sequencing data for the three new isolates was delivered as one BAM per SMRT cell under
`GSL_Data/5Feb24/`. The public *P. effusa* reads were downloaded separately and are already FASTQ,
so they enter the workflow at stage 01.

## Scripts

| file | what it does | resources |
|---|---|---|
| `bam2fastq.sh` | Convert the PacBio HiFi BAMs delivered by the sequencing core into gzipped FASTQ, one array task per BAM. | SLURM array 0-2 (one task per isolate BAM) |
| `get-oomycete-taxids.sh` | List every NCBI taxid under Oomycota (taxid 4762); used to build the -taxidlist filter for the BLAST contamination screens. | anywhere taxonkit is installed |

## Outputs

Paths are under `$HOME/project_data/downy` on the cluster unless marked *(in repo)*. The Deposition column feeds the data-availability plan (see repo root `DATA_DEPOSITION.md`).

| output | path | what it is | consumed by | deposition |
|---|---|---|---|---|
| HiFi FASTQ | `~/project_data/downy/GSL_Data/fastq/<run>.fastq.gz` | Raw PacBio HiFi reads converted from the core's BAMs, one file per SMRT run. | 01-read-filtering | NCBI SRA (raw reads) |
| Oomycete taxid list | `stdout (redirect to a file)` | Every NCBI taxid under Oomycota (4762); builds the -taxidlist filter for the contaminant BLAST. | 03-benchmarking (hifiasm-blastn) | not deposited (regenerable from NCBI taxonomy) |
