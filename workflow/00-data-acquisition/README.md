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
