# Stage 06 - Telomere repeats

tidk search for the TTTAGGG telomere repeat along every contig >= 1 Mb, and the plot of repeat
density along those contigs that supports the chromosome-scale claim.

## Scripts

| file | what it does | resources |
|---|---|---|
| `plot-tidk-telomeres.R` | Plot the tidk telomere-repeat density along each long contig. Called at the end of tidk-telomere-long-contigs.sh. | local, R |
| `tidk-telomere-long-contigs.sh` | Search contigs >=1 Mb for the plant/oomycete telomere repeat TTTAGGG with tidk, then call the plotting script. Reads assemblies from a LOCAL path - edit the fasta glob before running elsewhere. | local workstation |

## Notes

Both scripts run **locally**, not on the cluster, and the shell script points at
`/Users/yixuanyang/project_data/downy/contigs-renamed/cleaned/`. Change that glob before running it
on another machine.
