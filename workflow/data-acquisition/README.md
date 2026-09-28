# Data acquisition

`bam2fastq.sh` converts the three core-delivered HiFi BAMs under `$PROJECT_DATA/inputs/hifi/focal/bam/` to FASTQ in `inputs/hifi/focal/fastq/`. Submit it as a SLURM array. The public UA202013 FASTQ is already under `inputs/hifi/UA202013/`.

`get-oomycete-taxids.sh` prints descendants of NCBI taxid 4762 for the benchmarking BLAST screen. Redirect its output to `data/oomycete_taxids.txt` when refreshing that list.
